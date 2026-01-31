import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/alat.dart';

class AlatService {
  final SupabaseClient _sb = Supabase.instance.client;

  /// Ambil semua alat
  Future<List<Alat>> fetchAlat() async {
    final data = await _sb
        .from('alat_sepeda_motor')
        .select('id,nama_alat,kategori_id,stok,harga_per_hari,kondisi,status')
        .order('nama_alat');

    return (data as List)
        .map((e) => Alat.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Ambil stok alat
  Future<int> getStok(int alatId) async {
    final data = await _sb
        .from('alat_sepeda_motor')
        .select('stok')
        .eq('id', alatId)
        .single();

    return (data['stok'] as num).toInt();
  }

  /// Update stok alat
  Future<void> updateStok(int alatId, int stokBaru) async {
    if (stokBaru < 0) {
      throw Exception("Stok tidak boleh minus");
    }

    await _sb
        .from('alat_sepeda_motor')
        .update({'stok': stokBaru})
        .eq('id', alatId);
  }
}
