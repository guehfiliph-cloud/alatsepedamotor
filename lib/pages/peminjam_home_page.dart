import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../widgets/dashboard_menu_tile.dart';
import '../widgets/dashboard_profile_card.dart';
import '../routes.dart';

class PeminjamHomePage extends StatelessWidget {
  const PeminjamHomePage({super.key});

  Future<void> _logout(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, Routes.login, (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mengambil data user dari auth Supabase
    final user = Supabase.instance.client.auth.currentUser;
    final email = user?.email ?? '-';

    return Scaffold(
      backgroundColor: const Color(0xFFE7F4FF),
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2563EB), Color(0xFF06B6D4)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          "Dashboard Peminjam",
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            tooltip: "Logout",
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Widget Card Profile Atas
          DashboardProfileCard(
            title: "Halo, Peminjam 👋",
            email: email,
            icon: Icons.person_rounded,
            gradient: const [Color(0xFF2563EB), Color(0xFF06B6D4)],
          ),
          const SizedBox(height: 14),

          // Menu: Ganti Profile
          DashboardMenuTile(
            icon: Icons.manage_accounts_rounded,
            iconBg: const Color(0xFFB91C1C),
            title: "Ganti Profile",
            subtitle: "Ubah nama, no HP, dan foto",
            onTap: () => Navigator.pushNamed(context, Routes.profile),
          ),
          const SizedBox(height: 12),

          // Menu: Daftar Alat
          DashboardMenuTile(
            icon: Icons.list_alt_rounded,
            iconBg: const Color(0xFF2563EB),
            title: "Melihat Daftar Alat",
            subtitle: "Lihat alat tersedia & detailnya",
            onTap: () => Navigator.pushNamed(context, Routes.alat),
          ),
          const SizedBox(height: 12),

          // Menu: Buat Peminjaman
          DashboardMenuTile(
            icon: Icons.add_circle_rounded,
            iconBg: const Color(0xFF22C55E),
            title: "Mengajukan Peminjaman",
            subtitle: "Buat permintaan peminjaman alat",
            onTap: () => Navigator.pushNamed(context, Routes.buatPeminjaman),
          ),
          const SizedBox(height: 12),

          // Menu: Riwayat Peminjaman
          DashboardMenuTile(
            icon: Icons.assignment_turned_in_rounded,
            iconBg: const Color(0xFFF97316),
            title: "Peminjaman Saya",
            subtitle: "Cek status peminjaman kamu",
            onTap: () => Navigator.pushNamed(context, Routes.peminjamanSaya),
          ),
          const SizedBox(height: 12),

          // Menu: Pengembalian
          DashboardMenuTile(
            icon: Icons.keyboard_return_rounded,
            iconBg: const Color(0xFFEF4444),
            title: "Mengembalikan Alat",
            subtitle: "Isi pengembalian jika sudah selesai",
            onTap: () => Navigator.pushNamed(context, Routes.pengembalian),
          ),
        ],
      ),
    );
  }
}
