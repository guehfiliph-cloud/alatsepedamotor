import 'kategori.dart';

class Alat {
  final int id;
  final String namaAlat;
  final int kategoriId;
  final int stok;
  final int hargaPerHari;
  final String kondisi;
  final String status;
  final Kategori? kategori;

  Alat({
    required this.id,
    required this.namaAlat,
    required this.kategoriId,
    required this.stok,
    required this.hargaPerHari,
    required this.kondisi,
    required this.status,
    this.kategori,
  });

  factory Alat.fromJson(Map<String, dynamic> json) => Alat(
    id: json['id'] as int,
    namaAlat: json['nama_alat'] as String,
    kategoriId: json['kategori_id'] as int,
    stok: (json['stok'] as num).toInt(),
    hargaPerHari: (json['harga_per_hari'] as num).toInt(),
    kondisi: (json['kondisi'] ?? '') as String,
    status: (json['status'] ?? '') as String,
    kategori: json['kategori'] != null
        ? Kategori.fromJson(json['kategori'] as Map<String, dynamic>)
        : null,
  );
}
