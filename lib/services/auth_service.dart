import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient client;

  AuthService(this.client);

  // FUNGSI REGISTER: Perbaikan dari 'profiles' ke 'users'
  Future<void> register({
    required String nama,
    required String email,
    required String noHp,
    required String password,
    required String role,
    required String statusAkun,
  }) async {
    try {
      // 1. SignUp ke Supabase Auth
      final AuthResponse res = await client.auth.signUp(
        email: email,
        password: password,
      );

      final user = res.user;
      if (user == null) throw Exception("Gagal mendaftarkan user.");

      // 2. Simpan ke tabel 'users'
      await client.from('users').insert({
        'id': user.id,
        'nama': nama,
        'email': email,
        'no_hp': noHp,
        'role': role,
        'status_akun': statusAkun,
        'created_at': DateTime.now().toIso8601String(),
      });
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception("Terjadi kesalahan: $e");
    }
  }

  Future<AuthResponse> login(String email, String password) async {
    try {
      return await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } on AuthException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }
}
