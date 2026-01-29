import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/alat.dart';

class AlatService {
  final _sb = Supabase.instance.client;

  Future<List<Alat>> fetchAlat() async {
    final data = await _sb
        .from('alat_sepeda_motor')
        .select('id,nama_alat,kategori_id,stok,harga_per_hari,kondisi,status,kategori(id,nama_kategori)')
        .order('nama_alat');

    return (data as List).map((e) => Alat.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> updateStok(int alatId, int stokBaru) async {
    await _sb.from('alat_sepeda_motor').update({'stok': stokBaru}).eq('id', alatId);
  }
}
