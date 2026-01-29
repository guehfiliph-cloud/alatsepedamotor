import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/supabase_config.dart';

// pages
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/alat_list_page.dart';
import 'pages/buat_peminjaman_page.dart';
import 'pages/peminjaman_saya_page.dart';
import 'pages/pengembalian_page.dart';
import 'pages/register_page.dart';

const primaryBlue = Color(0xFF1565C0);
const lightBlueBg = Color(0xFFE3F2FD);
const darkText = Color(0xFF0D47A1);

class Routes {
  static const login = '/login';
  static const home = '/home';
  static const alat = '/alat';
  static const buatPeminjaman = '/buat-peminjaman';
  static const peminjamanSaya = '/peminjaman-saya';
  static const pengembalian = '/pengembalian';
  static const register = '/register';
}

/// Inisialisasi Supabase dibuat aman (anti blank).
Future<void> initSupabaseSafe() async {
  final url = SupabaseConfig.supabaseUrl.trim();
  final key = SupabaseConfig.anonKey.trim();

  if (url.isEmpty || key.isEmpty || !url.startsWith('http')) {
    debugPrint('SupabaseConfig belum valid. App tetap jalan tanpa supabase.');
    return;
  }

  try {
    await Supabase.initialize(https://muasrupptktcjodxgfpe.supabase.co, );
    debugPrint('Supabase initialized ✅');
  } catch (e) {
    debugPrint('Supabase init error (safe): $e');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // WAJIB: init supabase dulu supaya login tidak gagal diam-diam
  await initSupabaseSafe();

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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            minimumSize: const Size.fromHeight(48),
          ),
        ),
      ),

      // Gate cek session
      home: const InitGate(),

      routes: {
        Routes.login: (_) => const LoginPage(),
        Routes.home: (_) => const HomePage(),
        Routes.alat: (_) => const AlatListPage(),
        Routes.buatPeminjaman: (_) => const BuatPeminjamanPage(),
        Routes.peminjamanSaya: (_) => const PeminjamanSayaPage(),
        Routes.pengembalian: (_) => const PengembalianPage(),
        Routes.register: (_) => const RegisterPage(),
      },
    );
  }
}

class InitGate extends StatelessWidget {
  const InitGate({super.key});

  @override
  Widget build(BuildContext context) {
    // kalau supabase belum siap / config kosong, tetap masuk login
    try {
      final session = Supabase.instance.client.auth.currentSession;
      return session == null ? const LoginPage() : const HomePage();
    } catch (_) {
      return const LoginPage();
    }
  }
}
