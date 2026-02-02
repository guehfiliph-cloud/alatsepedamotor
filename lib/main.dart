import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/supabase_config.dart';

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

// =======================
// THEME COLORS
// =======================
const primaryBlue = Color(0xFF1565C0);
const lightBlueBg = Color(0xFFE3F2FD);

// =======================
// ROUTES
// =======================
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

  // Admin Approval
  static const approval = '/approval';
}

// =======================
// MAIN FUNCTION ✅
// =======================
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.anonKey,
  );

  runApp(const MyApp());
}

// =======================
// APP ROOT
// =======================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Peminjaman Alat Sepeda Motor',

      // =======================
      // THEME
      // =======================
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

      // =======================
      // START PAGE (ROLE GATE)
      // =======================
      home: const InitGate(),

      // =======================
      // ROUTING
      // =======================
      routes: {
        // Auth
        Routes.login: (_) => const LoginPage(),
        Routes.register: (_) => const RegisterPage(),

        // Alat & Peminjaman
        Routes.alat: (_) => const AlatListPage(),
        Routes.buatPeminjaman: (_) => const BuatPeminjamanPage(),
        Routes.peminjamanSaya: (_) => const PeminjamanSayaPage(),
        Routes.pengembalian: (_) => const PengembalianPage(),

        // Role Home
        Routes.adminHome: (_) => const AdminHomePage(),
        Routes.petugasHome: (_) => const PetugasHomePage(),
        Routes.peminjamHome: (_) => const PeminjamHomePage(),

        // Admin Approval
        Routes.approval: (_) => const AdminApprovalPage(),
      },
    );
  }
}

// =======================
// ROLE AUTH GATE
// =======================
class InitGate extends StatelessWidget {
  const InitGate({super.key});

  Future<Widget> _redirectUser() async {
    final client = Supabase.instance.client;
    final session = client.auth.currentSession;

    // 1) Jika belum login
    if (session == null) return const LoginPage();

    final userId = session.user.id;

    // 2) Ambil role & status akun dari tabel users
    // pakai maybeSingle agar tidak crash kalau data belum ada
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

    // 3) Jika akun belum aktif
    if (status != "aktif") {
      await client.auth.signOut();
      return const LoginPage();
    }

    // 4) Redirect sesuai role
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
