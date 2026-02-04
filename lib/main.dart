import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/supabase_config.dart';
import 'routes.dart';

// =======================
// PAGES IMPORT
// =======================
import 'pages/login_page.dart';
import 'pages/register_page.dart';

import 'pages/alat_list_page.dart';
import 'pages/buat_peminjaman_page.dart';
import 'pages/peminjaman_saya_page.dart';
import 'pages/pengembalian_page.dart';

import 'pages/admin_home_page.dart';
import 'pages/petugas_home_page.dart';
import 'pages/peminjam_home_page.dart';
import 'pages/admin_approval_page.dart';

import 'pages/admin_peminjaman_page.dart';
import 'pages/admin_pengembalian_page.dart';

import 'pages/users_page.dart';
import 'pages/petugas_pengembalian_page.dart';

// =======================
// THEME COLORS
// =======================
const primaryBlue = Color(0xFF1565C0);
const lightBlueBg = Color(0xFFE3F2FD);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.anonKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Peminjaman Alat Sepeda Motor',
      theme: ThemeData(
        primaryColor: primaryBlue,
        scaffoldBackgroundColor: lightBlueBg,
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryBlue,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: const InitGate(),
      routes: {
        Routes.login: (_) => const LoginPage(),
        Routes.register: (_) => const RegisterPage(),

        Routes.alat: (_) => const AlatListPage(),
        Routes.buatPeminjaman: (_) => const BuatPeminjamanPage(),
        Routes.peminjamanSaya: (_) => const PeminjamanSayaPage(),
        Routes.pengembalian: (_) => const PengembalianPage(),

        Routes.adminHome: (_) => const AdminHomePage(),
        Routes.petugasHome: (_) => const PetugasHomePage(),
        Routes.peminjamHome: (_) => const PeminjamHomePage(),

        Routes.approval: (_) => const AdminApprovalPage(),

        // ✅ ADMIN CRUD
        Routes.adminPeminjaman: (_) => const AdminPeminjamanPage(),
        Routes.adminPengembalian: (_) => const AdminPengembalianPage(),

        // ✅ PROFILE + PETUGAS MONITOR
        Routes.profile: (_) => const UsersPage(), // pastikan file/class ada
        Routes.petugasMonitor: (_) =>
            const PetugasPengembalianPage(), // pastikan file/class ada
      },
      onUnknownRoute: (_) =>
          MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }
}

class InitGate extends StatelessWidget {
  const InitGate({super.key});

  Future<Widget> _redirectUser() async {
    final client = Supabase.instance.client;
    final session = client.auth.currentSession;

    if (session == null) return const LoginPage();

    final userId = session.user.id;

    final userData = await client
        .from('users')
        .select('role,status_akun')
        .eq('id', userId)
        .maybeSingle();

    if (userData == null) {
      await client.auth.signOut();
      return const LoginPage();
    }

    final role = (userData['role'] ?? 'peminjam').toString();
    final status = (userData['status_akun'] ?? 'pending').toString();

    if (status != "aktif") {
      await client.auth.signOut();
      return const LoginPage();
    }

    if (role == "admin") return const AdminHomePage();
    if (role == "petugas") return const PetugasHomePage();
    return const PeminjamHomePage();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _redirectUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return snapshot.data ?? const LoginPage();
      },
    );
  }
}
