/// Format rupiah: 40000 -> "Rp 40.000".
String rupiah(int value) {
  final s = value.abs().toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
    b.write(s[i]);
  }
  return '${value < 0 ? '-' : ''}Rp $b';
}

/// Validasi bersama untuk form.
class Validators {
  static String? required(String? v, [String label = 'Kolom ini']) =>
      (v == null || v.trim().isEmpty) ? '$label wajib diisi' : null;

  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email wajib diisi';
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim());
    return ok ? null : 'Format email tidak valid';
  }

  static String? phone(String? v) {
    if (v == null || v.trim().isEmpty) return 'Nomor ponsel wajib diisi';
    final ok = RegExp(r'^(62|0)8\d{7,12}$').hasMatch(v.trim());
    return ok ? null : 'Nomor ponsel tidak valid (contoh 6282387436427)';
  }

  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'Kata sandi wajib diisi';
    return v.length < 6 ? 'Minimal 6 karakter' : null;
  }

  static String? number(String? v, [String label = 'Nilai']) {
    if (v == null || v.trim().isEmpty) return '$label wajib diisi';
    final n = int.tryParse(v.trim());
    return (n == null || n < 0) ? '$label harus angka' : null;
  }
}
