import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Register akun baru
  Future<User?> register(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      return result.user;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  // Login pengguna
  Future<User?> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return result.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Login gagal');
    }
  }

  // Logout pengguna
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Mengecek pengguna yang sedang login
  User? get currentUser => _auth.currentUser;

  // Memantau status login
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
