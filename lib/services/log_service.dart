import 'package:supabase_flutter/supabase_flutter.dart';

class LogService {
  final _sb = Supabase.instance.client;

  Future<void> log(String userId, String aktivitas) async {
    await _sb.from('log_aktivitas').insert({
      'user_id': userId,
      'aktivitas': aktivitas,
    });
  }
}
