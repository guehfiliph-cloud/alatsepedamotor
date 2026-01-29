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
    final e = email.trim();
    return RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(e);
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

      await _auth.register(
        nama: namaC.text,
        email: emailC.text,
        noHp: noHpC.text,
        password: passC.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Register berhasil. Silakan login.')),
      );

      Navigator.pop(context);
    } catch (e) {
      setState(() {
        errorText = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  if (errorText != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(errorText!, style: const TextStyle(color: Colors.red)),
                    ),
                    const SizedBox(height: 12),
                  ],

                  TextFormField(
                    controller: namaC,
                    decoration: const InputDecoration(labelText: 'Nama'),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Nama wajib diisi';
                      if (v.trim().length < 3) return 'Nama minimal 3 karakter';
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),

                  TextFormField(
                    controller: emailC,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Email wajib diisi';
                      if (!_isEmailValid(v)) return 'Format email tidak valid';
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),

                  TextFormField(
                    controller: noHpC,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'No HP'),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'No HP wajib diisi';
                      if (v.trim().length < 8) return 'No HP minimal 8 digit';
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),

                  TextFormField(
                    controller: passC,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password'),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Password wajib diisi';
                      if (v.length < 6) return 'Password minimal 6 karakter';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: loading ? null : register,
                      child: loading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Daftar'),
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
