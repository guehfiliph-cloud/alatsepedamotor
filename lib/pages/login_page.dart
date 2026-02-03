import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailC = TextEditingController();
  final passC = TextEditingController();

  bool loading = false;
  String? errorText;

  // ✅ untuk show/hide password (UI saja)
  bool _obscure = true;

  // ==========================
  // LOGIN FUNCTION (TIDAK DIUBAH)
  // ==========================
  Future<void> login() async {
    setState(() {
      loading = true;
      errorText = null;
    });

    try {
      // 1. LOGIN AUTH SUPABASE
      final res = await Supabase.instance.client.auth.signInWithPassword(
        email: emailC.text.trim(),
        password: passC.text,
      );

      final userId = res.user!.id;

      // 2. AMBIL DATA USER DARI TABLE USERS
      final userData = await Supabase.instance.client
          .from("users")
          .select()
          .eq("id", userId)
          .single();

      if (!mounted) return;

      // 3. CEK STATUS AKUN
      if (userData["status_akun"] == "pending") {
        setState(() {
          errorText = "Akun Anda belum disetujui Admin!";
        });

        await Supabase.instance.client.auth.signOut();
        return;
      }

      // 4. REDIRECT SESUAI ROLE
      final role = userData["role"];

      if (role == "admin") {
        Navigator.pushReplacementNamed(context, Routes.adminHome);
      } else if (role == "petugas") {
        Navigator.pushReplacementNamed(context, Routes.petugasHome);
      } else {
        Navigator.pushReplacementNamed(context, Routes.peminjamHome);
      }
    } catch (e) {
      setState(() {
        errorText = e.toString().replaceAll("Exception: ", "");
      });
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  // ==========================
  // UI HELPER
  // ==========================
  InputDecoration _dec({
    required String label,
    required IconData icon,
    String? hint,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.6),
      ),
    );
  }

  // ==========================
  // UI LOGIN PAGE
  // ==========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F8),
      appBar: AppBar(
        title: const Text("Login"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEFF6FF), Color(0xFFF7F7F8)],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: Card(
              elevation: 10,
              margin: const EdgeInsets.all(20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ==========================
                    // HEADER ICON (lebih simple)
                    // ==========================
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB).withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: const Color(
                            0xFF2563EB,
                          ).withValues(alpha: 0.18),
                        ),
                      ),
                      // ✅ ikon kunci simple (outline)
                      child: const Icon(
                        Icons.lock_outline_rounded,
                        size: 30,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                    const SizedBox(height: 12),

                    const Text(
                      "Peminjaman Alat Sepeda Motor",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Selamat Datang di Bengkel pinjam",
                      style: TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ==========================
                    // ERROR MESSAGE
                    // ==========================
                    if (errorText != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.red.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                errorText!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // ==========================
                    // EMAIL
                    // ==========================
                    TextField(
                      controller: emailC,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: _dec(
                        label: "Email",
                        icon: Icons.mail_outline_rounded,
                        hint: "contoh@email.com",
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ==========================
                    // PASSWORD (✅ tambah show/hide)
                    // ==========================
                    TextField(
                      controller: passC,
                      obscureText: _obscure,
                      textInputAction: TextInputAction.done,
                      decoration: _dec(
                        label: "Password",
                        icon: Icons.lock_outline_rounded,
                        hint: "Masukkan password",
                        suffixIcon: IconButton(
                          tooltip: _obscure
                              ? "Tampilkan Password"
                              : "Sembunyikan Password",
                          onPressed: () {
                            setState(() {
                              _obscure = !_obscure;
                            });
                          },
                          icon: Icon(
                            _obscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ==========================
                    // BUTTON LOGIN
                    // ==========================
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2563EB), Color(0xFF60A5FA)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 16,
                              color: const Color(
                                0xFF2563EB,
                              ).withValues(alpha: 0.22),
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: loading ? null : login,
                          child: loading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  "Login",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 14,
                                  ),
                                ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ==========================
                    // LINK REGISTER
                    // ==========================
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Belum punya akun? "),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, Routes.register);
                          },
                          child: const Text(
                            "Daftar",
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
