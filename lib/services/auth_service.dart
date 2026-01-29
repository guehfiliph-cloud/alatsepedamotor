import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client;

  AuthService(this._client);

  Future<void> login(String email, String password) async {
    try {
      final res = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      if (res.session == null) {
        throw Exception('Login gagal. Email atau password salah.');
      }
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Login error: $e');
    }
  }

  Future<void> register({
    required String nama,
    required String email,
    required String noHp,
    required String password,
  }) async {
    try {
      // WAJIB untuk Flutter Web supaya request auth tidak gagal fetch
      final redirect = Uri.base.origin; // contoh: http://localhost:51536

      final res = await _client.auth.signUp(
        email: email.trim(),
        password: password,
        emailRedirectTo: redirect,
      );

      final user = res.user;
      if (user == null) {
        throw Exception('Register gagal. Coba lagi.');
      }

      // Insert ke tabel users sesuai ERD kamu (JANGAN UBAH KOLOM)
      await _client.from('users').insert({
        'id': user.id,
        'nama': nama.trim(),
        'email': email.trim(),
        'no_hp': noHp.trim(),
        'role': 'peminjam',
      });
    } on AuthException catch (e) {
      // contoh: "User already registered"
      throw Exception(e.message);
    } on PostgrestException catch (e) {
      // contoh: RLS/policy/constraint error
      throw Exception('DB error: ${e.message}');
    } catch (e) {
      throw Exception('Register error: $e');
    }
  }

  Future<void> logout() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      throw Exception('Logout error: $e');
    }
  }

  Session? get session => _client.auth.currentSession;
}
