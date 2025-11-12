import 'dart:developer' as developer;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _rtdb = FirebaseDatabase.instance.ref();

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e, s) {
      developer.log(
        'Failed to sign in',
        name: 'com.app.AuthService',
        error: e,
        stackTrace: s,
      );
      return null;
    }
  }

  Future<User?> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      if (user != null) {
        // Also write user info to Realtime Database, but don't wait for it
        _rtdb.child('users').child(user.uid).set({
          'email': user.email,
          'createdAt': ServerValue.timestamp,
        });
      }
      return user;
    } on FirebaseAuthException catch (e, s) {
      developer.log(
        'Failed to create user',
        name: 'com.app.AuthService',
        error: e,
        stackTrace: s,
      );
      return null;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e, s) {
      developer.log(
        'Failed to send password reset email',
        name: 'com.app.AuthService',
        error: e,
        stackTrace: s,
      );
      // Optionally, rethrow the exception to be handled in the UI
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
