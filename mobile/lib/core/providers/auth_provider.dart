import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:dio/dio.dart';
import '../network/api_client.dart';

// Provides the global instance of FirebaseAuth
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

// A stream provider that emits the user whenever authentication state changes
final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

// Provides the auth controller logic
final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController(ref.watch(firebaseAuthProvider));
});

class AuthController {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb ? 'dummy-client-id.apps.googleusercontent.com' : null,
  );

  AuthController(this._auth);

  Future<void> signInWithEmail(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signUpWithEmail(String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    if (cred.user != null) {
      try {
        final token = await cred.user!.getIdToken();
        await ApiClient.client.post('/users/', 
          data: {
            'firebase_uid': cred.user!.uid,
            'email': cred.user!.email,
            'display_name': email.split('@').first,
            'avatar_url': 'https://api.dicebear.com/7.x/avataaars/svg?seed=${cred.user!.uid}',
          },
          options: Options(headers: {'Authorization': 'Bearer $token'})
        );
      } catch (e) {
        debugPrint('Backend sync error: $e');
      }
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return; // User canceled the sign in

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
