import 'dart:io';
import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final supabase = Supabase.instance.client;

  // ✅ Nama bucket (samakan dengan yang ada di Supabase Storage)
  final String alatBucket = "alat-images";
  final String userBucket = "users";

  // =========================
  // HELPERS
  // =========================

  String _newJpgName([String? originalName]) {
    final ts = DateTime.now().millisecondsSinceEpoch;
    if (originalName == null || originalName.trim().isEmpty) {
      return "$ts.jpg";
    }
    // kalau originalName sudah ada ekstensi, biarkan
    return "${ts}_$originalName";
  }

  /// Ambil path dari public URL Supabase storage
  /// Contoh URL:
  /// .../storage/v1/object/public/alat-images/alat/12/123.jpg
  /// => return: alat/12/123.jpg
  String? publicUrlToPath(String? publicUrl, String bucket) {
    if (publicUrl == null || publicUrl.isEmpty) return null;

    final marker = "/object/public/$bucket/";
    final idx = publicUrl.indexOf(marker);
    if (idx == -1) return null;

    return publicUrl.substring(idx + marker.length);
  }

  // =========================
  // ANDROID / MOBILE (File)
  // =========================

  /// Upload gambar alat (Android/iOS)
  Future<String> uploadAlatImage(File file, int alatId) async {
    final fileName = _newJpgName();
    final path = "alat/$alatId/$fileName";

    await supabase.storage
        .from(alatBucket)
        .upload(
          path,
          file,
          fileOptions: const FileOptions(
            upsert: true,
            contentType: "image/jpeg",
          ),
        );

    return supabase.storage.from(alatBucket).getPublicUrl(path);
  }

  /// Upload foto user (Android/iOS)
  Future<String> uploadUserPhoto(File file, String userId) async {
    final fileName = _newJpgName();
    final path = "users/$userId/$fileName";

    await supabase.storage
        .from(userBucket)
        .upload(
          path,
          file,
          fileOptions: const FileOptions(
            upsert: true,
            contentType: "image/jpeg",
          ),
        );

    return supabase.storage.from(userBucket).getPublicUrl(path);
  }

  // =========================
  // WEB / BYTES (Uint8List)
  // =========================

  /// Upload gambar alat (Web) pakai bytes
  Future<String> uploadAlatImageBytes(
    Uint8List bytes,
    int alatId,
    String originalName,
  ) async {
    final fileName = _newJpgName(originalName);
    final path = "alat/$alatId/$fileName";

    await supabase.storage
        .from(alatBucket)
        .uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(
            upsert: true,
            contentType: "image/jpeg",
          ),
        );

    return supabase.storage.from(alatBucket).getPublicUrl(path);
  }

  /// Upload foto user (Web) pakai bytes
  Future<String> uploadUserPhotoBytes(
    Uint8List bytes,
    String userId,
    String originalName,
  ) async {
    final fileName = _newJpgName(originalName);
    final path = "users/$userId/$fileName";

    await supabase.storage
        .from(userBucket)
        .uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(
            upsert: true,
            contentType: "image/jpeg",
          ),
        );

    return supabase.storage.from(userBucket).getPublicUrl(path);
  }

  // =========================
  // DELETE (opsional tapi berguna)
  // =========================

  /// Hapus file dari bucket alat-images berdasarkan public URL
  Future<void> deleteAlatImageByUrl(String? publicUrl) async {
    final path = publicUrlToPath(publicUrl, alatBucket);
    if (path == null) return;

    await supabase.storage.from(alatBucket).remove([path]);
  }

  /// Hapus file dari bucket users berdasarkan public URL
  Future<void> deleteUserPhotoByUrl(String? publicUrl) async {
    final path = publicUrlToPath(publicUrl, userBucket);
    if (path == null) return;

    await supabase.storage.from(userBucket).remove([path]);
  }
}
