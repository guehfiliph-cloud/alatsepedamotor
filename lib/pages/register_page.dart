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

  // Helper styling biar rapi + konsisten
  InputDecoration _dec({
    required String label,
    required IconData icon,
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
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
        borderSide: const BorderSide(color: Color(0xFFB91C1C), width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red, width: 1.2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // background dibuat halus biar lebih modern
      backgroundColor: const Color(0xFFF7F7F8),

      appBar: AppBar(
        title: const Text("Register"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
      ),

      body: Container(
        // gradient halus supaya ga flat
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF7F7F8), Color(0xFFF2F4F7)],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // ==========================
                    // HEADER CARD
                    // ==========================
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 18,
                            color: Colors.black.withValues(alpha: 0.06),
                            offset: const Offset(0, 10),
                          ),
                        ],
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFB91C1C), Color(0xFFEF4444)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.person_add,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Buat Akun",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "Lengkapi data untuk mendaftar",
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ==========================
                    // ERROR MESSAGE (lebih rapi)
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
                    // INPUT NAMA
                    // ==========================
                    TextFormField(
                      controller: namaC,
                      textInputAction: TextInputAction.next,
                      decoration: _dec(
                        label: "Nama",
                        icon: Icons.badge_outlined,
                        hint: "Masukkan nama lengkap",
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? "Nama wajib diisi" : null,
                    ),
                    const SizedBox(height: 12),

                    // ==========================
                    // INPUT EMAIL
                    // ==========================
                    TextFormField(
                      controller: emailC,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: _dec(
                        label: "Email",
                        icon: Icons.email_outlined,
                        hint: "contoh@email.com",
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return "Email wajib diisi";
                        if (!_isEmailValid(v)) {
                          return "Format email tidak valid";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // ==========================
                    // INPUT NO HP
                    // ==========================
                    TextFormField(
                      controller: noHpC,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      decoration: _dec(
                        label: "No HP",
                        icon: Icons.phone_outlined,
                        hint: "08xxxxxxxxxx",
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? "No HP wajib diisi" : null,
                    ),
                    const SizedBox(height: 12),

                    // ==========================
                    // INPUT PASSWORD
                    // ==========================
                    TextFormField(
                      controller: passC,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      decoration: _dec(
                        label: "Password",
                        icon: Icons.lock_outline,
                        hint: "Minimal 6 karakter",
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return "Password wajib diisi";
                        }
                        if (v.length < 6) return "Password minimal 6 karakter";
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // ==========================
                    // DROPDOWN ROLE (lebih modern)
                    // ==========================
                    DropdownButtonFormField<String>(
                      initialValue: selectedRole,
                      decoration: _dec(
                        label: "Daftar Sebagai",
                        icon: Icons.work_outline,
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
                    // BUTTON REGISTER (lebih premium)
                    // ==========================
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFB91C1C), Color(0xFFEF4444)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 16,
                              color: const Color(
                                0xFFB91C1C,
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
                          onPressed: loading ? null : register,
                          child: loading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  "Daftar",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // info kecil
                    Text(
                      selectedRole == "admin" || selectedRole == "petugas"
                          ? "Catatan: akun Admin/Petugas akan menunggu persetujuan."
                          : "Catatan: akun peminjam langsung aktif.",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
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
