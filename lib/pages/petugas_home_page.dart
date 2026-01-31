import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../main.dart';

class PetugasHomePage extends StatelessWidget {
  const PetugasHomePage({super.key});

  Future<void> logout(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();
    if (!context.mounted) return;

    Navigator.pushNamedAndRemoveUntil(context, Routes.login, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(
        title: const Text("Dashboard Petugas"),
        backgroundColor: const Color(0xFFFF9800),
        actions: [
          IconButton(
            tooltip: "Logout",
            icon: const Icon(Icons.logout),
            onPressed: () => logout(context),
          ),
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ==========================
          // HEADER INFO
          // ==========================
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.badge, color: Color(0xFFFF9800), size: 30),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Halo, Petugas 👋",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? "-",
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ==========================
          // MENU BUTTONS
          // ==========================
          _MenuCard(
            icon: Icons.check_circle,
            iconColor: const Color(0xFF2E7D32),
            title: "Menyetujui Peminjaman",
            subtitle: "Approve peminjaman dari peminjam",
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Halaman approval peminjaman belum dibuat"),
                ),
              );
            },
          ),

          const SizedBox(height: 10),

          _MenuCard(
            icon: Icons.assignment_return,
            iconColor: const Color(0xFF1565C0),
            title: "Memantau Pengembalian",
            subtitle: "Cek alat yang sudah / belum dikembalikan",
            onTap: () {
              Navigator.pushNamed(context, Routes.pengembalian);
            },
          ),

          const SizedBox(height: 10),

          _MenuCard(
            icon: Icons.print,
            iconColor: const Color(0xFF6A1B9A),
            title: "Cetak Laporan",
            subtitle: "Rekap peminjaman & pengembalian",
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Fitur laporan belum dibuat")),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ==========================
// WIDGET MENU CARD (BAGUS)
// ==========================
class _MenuCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: iconColor.withValues(alpha: 0.12),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
