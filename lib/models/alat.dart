class Alat {
  final int id;
  final String namaAlat;
  final int kategoriId;
  final int stok;
  final int hargaPerHari;
  final String kondisi;
  final String status;

  Alat({
    required this.id,
    required this.namaAlat,
    required this.kategoriId,
    required this.stok,
    required this.hargaPerHari,
    required this.kondisi,
    required this.status,
  });

  factory Alat.fromJson(Map<String, dynamic> json) {
    return Alat(
      id: json['id'],
      namaAlat: json['nama_alat'],
      kategoriId: json['kategori_id'],
      stok: json['stok'],
      hargaPerHari: json['harga_per_hari'],
      kondisi: json['kondisi'],
      status: json['status'],
    );
  }
}
