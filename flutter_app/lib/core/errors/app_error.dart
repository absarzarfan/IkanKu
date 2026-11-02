import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart' as sb;

enum AppErrorKind { network, auth, permission, validation, unknown }

/// Galat bertipe dengan pesan Indonesia yang aman ditampilkan (tanpa teks pengecualian mentah).
class AppError implements Exception {
  const AppError(this.kind, this.message);
  final AppErrorKind kind;
  final String message;

  const AppError.network([String message = 'Tidak dapat terhubung. Periksa koneksi internet Anda.']) : this(AppErrorKind.network, message);
  const AppError.auth([String message = 'Email atau kata sandi salah.']) : this(AppErrorKind.auth, message);
  const AppError.permission([String message = 'Anda tidak memiliki izin untuk tindakan ini.']) : this(AppErrorKind.permission, message);
  const AppError.validation([String message = 'Data tidak valid.']) : this(AppErrorKind.validation, message);

  @override
  String toString() => message;
}

/// Pesan kustom dari fungsi database (errcode 22023 = validasi) memang ditulis dalam bahasa Indonesia.
AppError mapError(Object e) {
  if (e is AppError) return e;
  if (e is SocketException || e is TimeoutException || e is HttpException) return const AppError.network();
  if (e is sb.AuthException) {
    final m = e.message.toLowerCase();
    if (m.contains('already registered') || m.contains('already been registered')) return const AppError.validation('Email sudah terdaftar.');
    if (m.contains('password') && (m.contains('weak') || m.contains('at least'))) return const AppError.validation('Kata sandi terlalu lemah (minimal 6 karakter).');
    if (m.contains('rate limit') || m.contains('too many')) return const AppError(AppErrorKind.unknown, 'Terlalu banyak percobaan. Coba lagi nanti.');
    if (m.contains('network') || m.contains('failed host lookup') || m.contains('socket')) return const AppError.network();
    return const AppError.auth();
  }
  if (e is sb.PostgrestException) {
    final code = e.code ?? '';
    if (code == '42501' || code == 'PGRST301') return const AppError.permission();
    if (code == '22023') return AppError.validation(e.message);
    if (code == '23505') return const AppError.validation('Data sudah ada.');
    if (code == '23514' || code == '23502' || code == '22P02') return const AppError.validation();
    return const AppError(AppErrorKind.unknown, 'Terjadi kesalahan pada server. Coba lagi.');
  }
  if (e is sb.StorageException) return const AppError(AppErrorKind.unknown, 'Gagal mengunggah berkas. Pastikan ukuran dan format gambar sesuai.');
  if (e.toString().contains('SocketException') || e.toString().contains('ClientException')) return const AppError.network();
  return const AppError(AppErrorKind.unknown, 'Terjadi kesalahan. Coba lagi.');
}
