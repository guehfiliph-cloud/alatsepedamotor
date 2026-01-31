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

  // ==========================
  // LOGIN FUNCTION
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
  // UI LOGIN PAGE
  // ==========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(title: const Text("Login"), centerTitle: true),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
          child: Card(
            elevation: 5,
            margin: const EdgeInsets.all(20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock, size: 70, color: Colors.blue),
                  const SizedBox(height: 10),

                  const Text(
                    "Peminjaman Alat Sepeda Motor",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 20),

                  // ==========================
                  // ERROR MESSAGE
                  // ==========================
                  if (errorText != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        errorText!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // ==========================
                  // EMAIL
                  // ==========================
                  TextField(
                    controller: emailC,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      prefixIcon: Icon(Icons.email),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ==========================
                  // PASSWORD
                  // ==========================
                  TextField(
                    controller: passC,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Password",
                      prefixIcon: Icon(Icons.lock),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ==========================
                  // BUTTON LOGIN
                  // ==========================
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: loading ? null : login,
                      child: loading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            )
                          : const Text("Login"),
                    ),
                  ),

                  const SizedBox(height: 15),

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
                        child: const Text("Daftar"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
