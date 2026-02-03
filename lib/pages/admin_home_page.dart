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

  Future<void> logout(m.BuildContext context) async {
    await Supabase.instance.client.auth.signOut();
    if (!context.mounted) return;

    m.Navigator.pushNamedAndRemoveUntil(
      context,
      Routes.login,
      (route) => false,
    );
  }

  final pages = const [
    DashboardRingkasanPage(),
    AlatListPage(),
    KategoriPage(),
    UserListPage(),
    AdminApprovalPage(),
  ];

  @override
  m.Widget build(m.BuildContext context) {
    return m.Scaffold(
      backgroundColor: const m.Color(0xFFEFF6FF),
      appBar: m.AppBar(
        elevation: 0,
        backgroundColor: m.Colors.transparent,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const m.Text(
          "Dashboard Admin",
          style: m.TextStyle(
            fontSize: 18,
            fontWeight: m.FontWeight.w900,
            color: m.Colors.white,
            letterSpacing: 0.2,
          ),
        ),
        actions: [
          m.Container(
            margin: const m.EdgeInsets.only(right: 12),
            decoration: m.BoxDecoration(
              color: m.Colors.white.withValues(alpha: 0.18),
              borderRadius: m.BorderRadius.circular(14),
              border: m.Border.all(
                color: m.Colors.white.withValues(alpha: 0.25),
              ),
            ),
            child: m.IconButton(
              tooltip: "Logout",
              onPressed: () => logout(context),
              icon: const m.Icon(
                m.Icons.logout_rounded,
                size: 20,
                color: m.Colors.white,
              ),
            ),
          ),
        ],
        flexibleSpace: m.Container(
          decoration: const m.BoxDecoration(
            gradient: m.LinearGradient(
              colors: [m.Color(0xFF7F1D1D), m.Color(0xFFEF4444)],
              begin: m.Alignment.topLeft,
              end: m.Alignment.bottomRight,
            ),
            boxShadow: [
              m.BoxShadow(
                blurRadius: 18,
                color: m.Colors.black12,
                offset: m.Offset(0, 8),
              ),
            ],
            borderRadius: m.BorderRadius.only(
              bottomLeft: m.Radius.circular(22),
              bottomRight: m.Radius.circular(22),
            ),
          ),
        ),
      ),
      body: m.Container(
        decoration: const m.BoxDecoration(
          gradient: m.LinearGradient(
            begin: m.Alignment.topCenter,
            end: m.Alignment.bottomCenter,
            colors: [m.Color(0xFFEFF6FF), m.Color(0xFFF7F7F8)],
          ),
        ),
        child: pages[_index],
      ),
      bottomNavigationBar: m.BottomNavigationBar(
        currentIndex: _index,
        onTap: (value) => setState(() => _index = value),
        backgroundColor: m.Colors.white,
        selectedItemColor: const m.Color(0xFFB91C1C),
        unselectedItemColor: m.Colors.grey,
        type: m.BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        selectedFontSize: 12,
        unselectedFontSize: 11,
        items: const [
          m.BottomNavigationBarItem(
            icon: m.Icon(m.Icons.dashboard_rounded),
            label: "Ringkasan",
          ),
          m.BottomNavigationBarItem(
            icon: m.Icon(m.Icons.build_rounded),
            label: "Alat",
          ),
          m.BottomNavigationBarItem(
            icon: m.Icon(m.Icons.category_rounded),
            label: "Kategori",
          ),
          m.BottomNavigationBarItem(
            icon: m.Icon(m.Icons.people_alt_rounded),
            label: "User",
          ),
          m.BottomNavigationBarItem(
            icon: m.Icon(m.Icons.verified_user_rounded),
            label: "Pending",
          ),
        ],
      ),
    );
  }
}
