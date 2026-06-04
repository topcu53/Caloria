import 'package:firebase_auth/firebase_auth.dart';

String authErrorMessage(Object error) {
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'invalid-email':
        return 'Geçerli bir e-posta adresi girin.';
      case 'user-disabled':
        return 'Bu hesap devre dışı bırakılmış.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'E-posta veya şifre hatalı.';
      case 'email-already-in-use':
        return 'Bu e-posta zaten kayıtlı.';
      case 'weak-password':
        return 'Şifre en az 6 karakter olmalı.';
      case 'operation-not-allowed':
        return 'E-posta ile giriş Firebase\'de kapalı. Konsolda Email/Password\'ü etkinleştirin.';
      case 'too-many-requests':
        return 'Çok fazla deneme. Biraz sonra tekrar deneyin.';
      case 'network-request-failed':
        return 'İnternet bağlantısını kontrol edin.';
      default:
        return error.message ?? 'İşlem başarısız (${error.code}).';
    }
  }
  return 'Beklenmeyen bir hata oluştu.';
}
