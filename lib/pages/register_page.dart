import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final namaC = TextEditingController();
  final emailC = TextEditingController();
  final noHpC = TextEditingController();
  final passC = TextEditingController();

  bool loading = false;
  String? errorText;

  // Default role
  String selectedRole = "peminjam";

  AuthService get _auth => AuthService(Supabase.instance.client);

  @override
  void dispose() {
    namaC.dispose();
    emailC.dispose();
    noHpC.dispose();
    passC.dispose();
    super.dispose();
  }

  bool _isEmailValid(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email.trim());
  }

  Future<void> register() async {
    setState(() {
      errorText = null;
      loading = true;
    });

    try {
      if (!_formKey.currentState!.validate()) {
        setState(() => loading = false);
        return;
      }

      // Status akun otomatis
      String statusAkun = "aktif";

      // Jika admin/petugas → pending
      if (selectedRole == "admin" || selectedRole == "petugas") {
        statusAkun = "pending";
      }

      await _auth.register(
        nama: namaC.text.trim(),
        email: emailC.text.trim(),
        noHp: noHpC.text.trim(),
        password: passC.text,
        role: selectedRole,
        statusAkun: statusAkun,
      );

      if (!mounted) return;

      // Notifikasi sesuai role
      if (statusAkun == "pending") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Register berhasil. Akun Anda menunggu persetujuan Admin.",
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Register berhasil. Silakan login.")),
        );
      }

      Navigator.pop(context);
    } catch (e) {
      setState(() {
        errorText = e.toString().replaceAll("Exception: ", "");
      });
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
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
                  // INPUT NAMA
                  // ==========================
                  TextFormField(
                    controller: namaC,
                    decoration: const InputDecoration(labelText: "Nama"),
                    validator: (v) =>
                        v == null || v.isEmpty ? "Nama wajib diisi" : null,
                  ),
                  const SizedBox(height: 10),

                  // ==========================
                  // INPUT EMAIL
                  // ==========================
                  TextFormField(
                    controller: emailC,
                    decoration: const InputDecoration(labelText: "Email"),
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return "Email wajib diisi";
                      }
                      if (!_isEmailValid(v)) {
                        return "Format email tidak valid";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),

                  // ==========================
                  // INPUT NO HP
                  // ==========================
                  TextFormField(
                    controller: noHpC,
                    decoration: const InputDecoration(labelText: "No HP"),
                    validator: (v) =>
                        v == null || v.isEmpty ? "No HP wajib diisi" : null,
                  ),
                  const SizedBox(height: 10),

                  // ==========================
                  // INPUT PASSWORD
                  // ==========================
                  TextFormField(
                    controller: passC,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: "Password"),
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return "Password wajib diisi";
                      }
                      if (v.length < 6) {
                        return "Password minimal 6 karakter";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),

                  // ==========================
                  // DROPDOWN ROLE
                  // ==========================
                  DropdownButtonFormField<String>(
                    initialValue: selectedRole,
                    decoration: const InputDecoration(
                      labelText: "Daftar Sebagai",
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: "peminjam",
                        child: Text("Peminjam"),
                      ),
                      DropdownMenuItem(
                        value: "petugas",
                        child: Text("Petugas"),
                      ),
                      DropdownMenuItem(value: "admin", child: Text("Admin")),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedRole = value!;
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  // ==========================
                  // BUTTON REGISTER
                  // ==========================
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: loading ? null : register,
                      child: loading
                          ? const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            )
                          : const Text("Daftar"),
                    ),
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
