import 'package:supabase_flutter/supabase_flutter.dart';

class SeedService {
  final _sb = Supabase.instance.client;

  Future<void> seedKategoriDanAlatJikaKosong() async {
    final cek = await _sb.from('kategori').select('id').limit(1);
    if ((cek as List).isNotEmpty) return;

    // 1) kategori
    final kategori = await _sb.from('kategori').insert([
      {'nama_kategori': 'Perkakas Tangan Dasar'},
      {'nama_kategori': 'Alat Ukur Presisi'},
      {'nama_kategori': 'Alat Khusus Bengkel'},
      {'nama_kategori': 'Alat Elektronik'},
      {'nama_kategori': 'Mesin/Kompressor'},
    ]).select('id,nama_kategori');

    int idByName(String name) =>
        (kategori as List).firstWhere((k) => k['nama_kategori'] == name)['id'] as int;

    final kTangan = idByName('Perkakas Tangan Dasar');
    final kPresisi = idByName('Alat Ukur Presisi');
    final kKhusus = idByName('Alat Khusus Bengkel');
    final kElektronik = idByName('Alat Elektronik');
    final kMesin = idByName('Mesin/Kompressor');

    // 2) alat_sepeda_motor (contoh jurusan sepeda motor)
    await _sb.from('alat_sepeda_motor').insert([
      // Perkakas tangan dasar
      {
        'nama_alat': 'Kunci Pas/Ring Set',
        'kategori_id': kTangan,
        'stok': 10,
        'harga_per_hari': 5000,
        'kondisi': 'baik',
        'status': 'tersedia',
      },
      {
        'nama_alat': 'Obeng (+/-) Set',
        'kategori_id': kTangan,
        'stok': 12,
        'harga_per_hari': 3000,
        'kondisi': 'baik',
        'status': 'tersedia',
      },
      {
        'nama_alat': 'Tang Kombinasi',
        'kategori_id': kTangan,
        'stok': 8,
        'harga_per_hari': 3000,
        'kondisi': 'baik',
        'status': 'tersedia',
      },

      // Alat ukur presisi
      {
        'nama_alat': 'Jangka Sorong (Vernier Caliper)',
        'kategori_id': kPresisi,
        'stok': 6,
        'harga_per_hari': 8000,
        'kondisi': 'baik',
        'status': 'tersedia',
      },
      {
        'nama_alat': 'Mikrometer Sekrup',
        'kategori_id': kPresisi,
        'stok': 4,
        'harga_per_hari': 10000,
        'kondisi': 'baik',
        'status': 'tersedia',
      },
      {
        'nama_alat': 'Feeler Gauge',
        'kategori_id': kPresisi,
        'stok': 10,
        'harga_per_hari': 5000,
        'kondisi': 'baik',
        'status': 'tersedia',
      },
      {
        'nama_alat': 'Pengukur Kompresi',
        'kategori_id': kPresisi,
        'stok': 3,
        'harga_per_hari': 12000,
        'kondisi': 'baik',
        'status': 'tersedia',
      },

      // Alat khusus
      {
        'nama_alat': 'Torque Wrench',
        'kategori_id': kKhusus,
        'stok': 2,
        'harga_per_hari': 15000,
        'kondisi': 'baik',
        'status': 'tersedia',
      },
      {
        'nama_alat': 'Treker (Puller)',
        'kategori_id': kKhusus,
        'stok': 3,
        'harga_per_hari': 12000,
        'kondisi': 'baik',
        'status': 'tersedia',
      },
      {
        'nama_alat': 'Tire Changer Manual',
        'kategori_id': kKhusus,
        'stok': 1,
        'harga_per_hari': 25000,
        'kondisi': 'baik',
        'status': 'tersedia',
      },

      // Elektronik
      {
        'nama_alat': 'Multimeter Digital',
        'kategori_id': kElektronik,
        'stok': 5,
        'harga_per_hari': 10000,
        'kondisi': 'baik',
        'status': 'tersedia',
      },

      // Mesin
      {
        'nama_alat': 'Kompresor Udara',
        'kategori_id': kMesin,
        'stok': 1,
        'harga_per_hari': 30000,
        'kondisi': 'baik',
        'status': 'tersedia',
      },
    ]);
  }
}
