import 'package:flutter/material.dart' as m;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../main.dart';
import 'alat_list_page.dart';
import 'buat_peminjaman_page.dart';

class PeminjamHomePage extends m.StatelessWidget {
  const PeminjamHomePage({super.key});

  // ==========================
  // LOGOUT FUNCTION
  // ==========================
  Future<void> logout(m.BuildContext context) async {
    await Supabase.instance.client.auth.signOut();

    if (!context.mounted) return;

    m.Navigator.pushNamedAndRemoveUntil(
      context,
      Routes.login,
      (route) => false,
    );
  }

  @override
  m.Widget build(m.BuildContext context) {
    return m.Scaffold(
      backgroundColor: const m.Color(0xFFE3F2FD),
      appBar: m.AppBar(
        title: const m.Text("Dashboard Peminjam"),
        backgroundColor: m.Colors.green,
        actions: [
          m.IconButton(
            icon: const m.Icon(m.Icons.logout),
            tooltip: "Logout",
            onPressed: () => logout(context),
          ),
        ],
      ),
      body: m.ListView(
        padding: const m.EdgeInsets.all(16),
        children: [
          // ==========================
          // LIHAT DAFTAR ALAT
          // ==========================
          m.Card(
            shape: m.RoundedRectangleBorder(
              borderRadius: m.BorderRadius.circular(12),
            ),
            child: m.ListTile(
              leading: const m.Icon(m.Icons.list),
              title: const m.Text("Melihat Daftar Alat"),
              subtitle: const m.Text("Cek alat dan ketersediaan stok"),
              onTap: () {
                m.Navigator.push(
                  context,
                  m.MaterialPageRoute(builder: (_) => const AlatListPage()),
                );
              },
            ),
          ),

          const m.SizedBox(height: 10),

          // ==========================
          // AJUKAN PEMINJAMAN
          // ==========================
          m.Card(
            shape: m.RoundedRectangleBorder(
              borderRadius: m.BorderRadius.circular(12),
            ),
            child: m.ListTile(
              leading: const m.Icon(m.Icons.add_shopping_cart),
              title: const m.Text("Ajukan Peminjaman"),
              subtitle: const m.Text("Buat permintaan peminjaman alat"),
              onTap: () {
                m.Navigator.push(
                  context,
                  m.MaterialPageRoute(
                    builder: (_) => const BuatPeminjamanPage(),
                  ),
                );
              },
            ),
          ),

          const m.SizedBox(height: 10),

          // ==========================
          // PENGEMBALIAN ALAT
          // ==========================
          m.Card(
            shape: m.RoundedRectangleBorder(
              borderRadius: m.BorderRadius.circular(12),
            ),
            child: m.ListTile(
              leading: const m.Icon(m.Icons.assignment_return),
              title: const m.Text("Pengembalian Alat"),
              subtitle: const m.Text("Fitur pengembalian (belum dibuat)"),
              onTap: () {
                m.ScaffoldMessenger.of(context).showSnackBar(
                  const m.SnackBar(
                    content: m.Text("Halaman pengembalian belum dibuat"),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
