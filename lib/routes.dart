class Routes {
  static const login = '/login';
  static const register = '/register';

  // Alat & Peminjaman
  static const alat = '/alat';
  static const buatPeminjaman = '/buat-peminjaman';
  static const peminjamanSaya = '/peminjaman-saya';
  static const pengembalian = '/pengembalian';

  // Role Home
  static const adminHome = '/admin-home';
  static const petugasHome = '/petugas-home';
  static const peminjamHome = '/peminjam-home';

  // Admin / Petugas
  static const approval = '/approval';
  static const adminPeminjaman = '/admin-peminjaman';
  static const adminPengembalian = '/admin-pengembalian';

  // Profile & Monitor
  static const profile = '/profile';

  // Kita gunakan nama ini agar sinkron dengan main.dart kamu
  static const petugasMonitor = '/petugas-monitor';

  // Alias monitor agar petugas_home_page tidak error
  static const monitor = petugasMonitor;
}
