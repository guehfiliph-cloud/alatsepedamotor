import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client;

  AuthService(this._client);

  // ===========================
  // REGISTER USER + ROLE
  // ===========================
  Future<void> register({
    required String nama,
    required String email,
    required String noHp,
    required String password,
    required String role,
    required String statusAkun,
  }) async {
    // 1. Signup Supabase Auth
    final res = await _client.auth.signUp(email: email, password: password);

    final userId = res.user?.id;

    if (userId == null) {
      throw Exception("Register gagal!");
    }

    // 2. Insert ke tabel users
    await _client.from('users').insert({
      'id': userId,
      'nama': nama,
      'email': email,
      'no_hp': noHp,
      'role': role,
      'status_akun': statusAkun,
    });
  }

  // ===========================
  // LOGIN
  // ===========================
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // ===========================
  // GET ROLE + STATUS
  // ===========================
  Future<Map<String, dynamic>> getUserRole(String userId) async {
    final data = await _client
        .from('users')
        .select('role,status_akun')
        .eq('id', userId)
        .single();

    return data;
  }

  // ===========================
  // LOGOUT
  // ===========================
  Future<void> logout() async {
    await _client.auth.signOut();
  }
}
