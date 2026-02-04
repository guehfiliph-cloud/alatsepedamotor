import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../widgets/dashboard_menu_tile.dart';
import '../widgets/dashboard_profile_card.dart';
import '../routes.dart'; // Import ini sekarang terpakai ✅

class PetugasHomePage extends StatelessWidget {
  const PetugasHomePage({super.key});

  Future<void> _logout(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();
    if (context.mounted) {
      // Menggunakan rute dari class Routes
      Navigator.pushNamedAndRemoveUntil(context, Routes.login, (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final email = user?.email ?? '-';

    return Scaffold(
      backgroundColor: const Color(0xFFEFF6FF),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF7F1D1D), Color(0xFFEF4444)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          "Dashboard Petugas",
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
          DashboardProfileCard(
            title: "Halo, Petugas 👋",
            email: email,
            icon: Icons.badge_rounded,
            gradient: const [Color(0xFF7F1D1D), Color(0xFFEF4444)],
            onTap: () =>
                Navigator.pushNamed(context, Routes.profile), // ✅ Terpakai
          ),
          const SizedBox(height: 14),

          DashboardMenuTile(
            icon: Icons.manage_accounts_rounded,
            iconBg: const Color(0xFFB91C1C),
            title: "Ganti Profile",
            subtitle: "Ubah nama, no HP, dan foto",
            onTap: () =>
                Navigator.pushNamed(context, Routes.profile), // ✅ Terpakai
          ),
          const SizedBox(height: 12),

          DashboardMenuTile(
            icon: Icons.verified_rounded,
            iconBg: const Color(0xFF16A34A),
            title: "Menyetujui Peminjaman",
            subtitle: "Approve peminjaman dari peminjam",
            onTap: () =>
                Navigator.pushNamed(context, Routes.approval), // ✅ Terpakai
          ),
          const SizedBox(height: 12),

          DashboardMenuTile(
            icon: Icons.inventory_2_rounded,
            iconBg: const Color(0xFF2563EB),
            title: "Memantau Pengembalian",
            subtitle: "Cek alat yang sudah / belum dikembalikan",
            onTap: () =>
                Navigator.pushNamed(context, Routes.monitor), // ✅ Terpakai
          ),
          const SizedBox(height: 12),

          DashboardMenuTile(
            icon: Icons.print_rounded,
            iconBg: const Color(0xFF7C3AED),
            title: "Cetak Laporan",
            subtitle: "Rekap peminjaman & pengembalian",
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Fitur laporan: nanti kita buat ya ✅"),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
