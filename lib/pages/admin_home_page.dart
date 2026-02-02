import 'package:flutter/material.dart' as m;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../main.dart';
import 'dashboard_ringkasan_page.dart';
import 'alat_list_page.dart';
import 'kategori_page.dart';
import 'user_list_page.dart';
import 'admin_approval_page.dart';

class AdminHomePage extends m.StatefulWidget {
  const AdminHomePage({super.key});

  @override
  m.State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends m.State<AdminHomePage> {
  int _index = 0;

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

  // ==========================
  // HALAMAN MENU
  // ==========================
  final pages = const [
    DashboardRingkasanPage(), // ✅ TAB PERTAMA: RINGKASAN
    AlatListPage(),
    KategoriPage(),
    UserListPage(),
    AdminApprovalPage(),
  ];

  @override
  m.Widget build(m.BuildContext context) {
    return m.Scaffold(
      backgroundColor: const m.Color(0xFFE3F2FD),

      // ==========================
      // APPBAR
      // ==========================
      appBar: m.AppBar(
        backgroundColor: const m.Color(0xFFB91C1C),

        title: const m.Text(
          "Dashboard Admin",
          style: m.TextStyle(
            fontSize: 22, // ✅ ukuran lebih besar
            fontWeight: m.FontWeight.bold, // ✅ lebih tegas
            color: m.Colors.white,
          ),
        ),

        actions: [
          // ✅ LOGOUT
          m.IconButton(
            tooltip: "Logout",
            onPressed: () => logout(context),
            icon: const m.Icon(
              m.Icons.logout,
              size: 12, // ✅ icon lebih besar
              color: m.Colors.white,
            ),
          ),
        ],
      ),

      // ==========================
      // BODY BERUBAH SESUAI MENU
      // ==========================
      body: pages[_index],

      // ==========================
      // BOTTOM NAVIGATION
      // ==========================
      bottomNavigationBar: m.BottomNavigationBar(
        currentIndex: _index,
        onTap: (value) {
          setState(() {
            _index = value;
          });
        },
        selectedItemColor: const m.Color(0xFFB91C1C),
        unselectedItemColor: m.Colors.grey,
        type: m.BottomNavigationBarType.fixed,
        items: const [
          m.BottomNavigationBarItem(
            icon: m.Icon(m.Icons.dashboard),
            label: "Ringkasan",
          ),
          m.BottomNavigationBarItem(icon: m.Icon(m.Icons.build), label: "Alat"),
          m.BottomNavigationBarItem(
            icon: m.Icon(m.Icons.category),
            label: "Kategori",
          ),
          m.BottomNavigationBarItem(
            icon: m.Icon(m.Icons.people),
            label: "User",
          ),
          m.BottomNavigationBarItem(
            icon: m.Icon(m.Icons.verified_user),
            label: "Pending",
          ),
        ],
      ),
    );
  }
}
