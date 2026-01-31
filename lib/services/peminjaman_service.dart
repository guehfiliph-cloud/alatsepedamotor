import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/peminjaman.dart';
import 'alat_service.dart';
import 'log_service.dart';

class PeminjamanService {
  final SupabaseClient _sb = Supabase.instance.client;

  final AlatService _alat = AlatService();
  final LogService _log = LogService();

  // ===============================
  // BUAT PEMINJAMAN
  // ===============================
  Future<int> buatPeminjaman({
    required String userId,
    required int alatId,
    required int jumlah,
    required DateTime tanggalKembaliRencana,
  }) async {
    // 1. Ambil stok saat ini
    final stokSaatIni = await _alat.getStok(alatId);

    if (stokSaatIni < jumlah) {
      throw Exception("Stok tidak cukup!");
    }

    // 2. Ambil harga alat
    final alatData = await _sb
        .from('alat_sepeda_motor')
        .select('harga_per_hari')
        .eq('id', alatId)
        .single();

    final hargaPerHari = (alatData['harga_per_hari'] as num).toInt();

    // 3. Hitung total harga
    final total = jumlah * hargaPerHari;

    // 4. Insert ke tabel peminjaman
    final peminjamanInsert = await _sb
        .from('peminjaman')
        .insert({
          'user_id': userId,
          'tanggal_pinjam': DateTime.now().toIso8601String(),
          'tanggal_kembali_rencana': tanggalKembaliRencana.toIso8601String(),
          'total_harga': total,
          'alat_id': alatId,
          'status': 'dipinjam',
        })
        .select('id')
        .single();

    final peminjamanId = (peminjamanInsert['id'] as num).toInt();

    // 5. Insert detail peminjaman
    await _sb.from('detail_peminjaman').insert({
      'peminjaman_id': peminjamanId,
      'barangmotor_id': alatId,
      'jumlah': jumlah,
      'harga': hargaPerHari,
    });

    // 6. Kurangi stok alat
    await _alat.updateStok(alatId, stokSaatIni - jumlah);

    // 7. Log aktivitas
    await _log.log(
      userId,
      "Buat peminjaman #$peminjamanId (alat=$alatId qty=$jumlah total=$total)",
    );

    return peminjamanId;
  }

  // ===============================
  // LIST PEMINJAMAN USER
  // ===============================
  Future<List<Peminjaman>> peminjamanSaya(String userId) async {
    final data = await _sb
        .from('peminjaman')
        .select()
        .eq('user_id', userId)
        .order('id', ascending: false);

    return (data as List)
        .map((e) => Peminjaman.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ===============================
  // PENGEMBALIAN + DENDA
  // ===============================
  Future<void> kembalikan({
    required String userId,
    required int peminjamanId,
    required int alatId,
    required DateTime tanggalKembaliRencana,
    required DateTime tanggalKembaliReal,
    required int stokSaatIni,
    required String kondisi,
    int dendaPerHari = 5000,
  }) async {
    // Hitung keterlambatan
    final telatHari = tanggalKembaliReal
        .difference(tanggalKembaliRencana)
        .inDays;

    final terlambat = telatHari > 0 ? telatHari : 0;
    final denda = terlambat * dendaPerHari;

    // Insert tabel pengembalian
    await _sb.from('pengembalian').insert({
      'peminjaman_id': peminjamanId,
      'tanggal_kembali_real': tanggalKembaliReal.toIso8601String(),
      'terlambat': terlambat,
      'denda': denda,
      'kondisi': kondisi,
    });

    // Update status peminjaman
    await _sb
        .from('peminjaman')
        .update({'status': 'kembali'})
        .eq('id', peminjamanId);

    // Tambah stok alat kembali
    await _alat.updateStok(alatId, stokSaatIni + 1);

    // Log aktivitas
    await _log.log(
      userId,
      "Pengembalian peminjaman #$peminjamanId (denda=$denda)",
    );
  }
}
