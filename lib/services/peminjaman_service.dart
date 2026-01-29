import 'package:supabase_flutter/supabase_flutter.dart';
import 'alat_service.dart';
import 'log_service.dart';
import '../models/peminjaman.dart';

class PeminjamanService {
  final _sb = Supabase.instance.client;
  final _alat = AlatService();
  final _log = LogService();

  String _toDate(DateTime dt) =>
      '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  Future<int> buatPeminjaman({
    required String userId,
    required int alatId,
    required int hargaPerHari,
    required int jumlah,
    required DateTime tanggalPinjam,
    required DateTime tanggalKembaliRencana,
    required int stokSaatIni,
  }) async {
    final hari = tanggalKembaliRencana.difference(tanggalPinjam).inDays;
    final durasi = hari <= 0 ? 1 : hari;
    final total = durasi * hargaPerHari * jumlah;

    final inserted = await _sb
        .from('peminjaman')
        .insert({
          'user_id': userId,
          'tanggal_pinjam': _toDate(tanggalPinjam),
          'tanggal_kembali_rencana': _toDate(tanggalKembaliRencana),
          'status': 'dipinjam',
          'total_harga': total,
          'alat_id': alatId,
        })
        .select('id')
        .single();

    final peminjamanId = inserted['id'] as int;

    await _sb.from('detail_peminjaman').insert({
      'peminjaman_id': peminjamanId,
      'barangmotor_id': alatId, // diasumsikan mengarah ke alat_sepeda_motor.id
      'jumlah': jumlah,
      'harga': hargaPerHari,
    });

    await _alat.updateStok(alatId, stokSaatIni - jumlah);
    await _log.log(userId, 'Buat peminjaman #$peminjamanId (alat=$alatId qty=$jumlah total=$total)');

    return peminjamanId;
  }

  Future<List<Peminjaman>> peminjamanSaya(String userId) async {
    final data = await _sb
        .from('peminjaman')
        .select('id,user_id,tanggal_pinjam,tanggal_kembali_rencana,status,total_harga')
        .eq('user_id', userId)
        .order('id', ascending: false);

    return (data as List).map((e) => Peminjaman.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> kembalikan({
    required String userId,
    required int peminjamanId,
    required int alatId,
    required int qty,
    required DateTime tanggalKembaliRencana,
    required DateTime tanggalKembaliReal,
    required int stokSaatIni,
    required String kondisi,
    int dendaPerHari = 5000,
  }) async {
    final telatHari = tanggalKembaliReal.difference(tanggalKembaliRencana).inDays;
    final terlambat = telatHari > 0 ? telatHari : 0;
    final denda = terlambat * dendaPerHari;

    await _sb.from('pengembalian').insert({
      'peminjaman_id': peminjamanId,
      'tanggal_kembali_real': _toDate(tanggalKembaliReal),
      'terlambat': terlambat,
      'denda': denda,
      'kondisi': kondisi,
    });

    await _sb.from('peminjaman').update({'status': 'selesai'}).eq('id', peminjamanId);
    await _alat.updateStok(alatId, stokSaatIni + qty);

    await _log.log(userId, 'Pengembalian #$peminjamanId (telat=$terlambat denda=$denda)');
  }
}
