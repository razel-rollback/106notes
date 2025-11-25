import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn? _googleSignIn = kIsWeb ? null : GoogleSignIn();

  /// Sign in with Google. Returns the signed-in [User] or null if cancelled.
  Future<User?> signInWithGoogle() async {
    if (kIsWeb) {
      // Web: use FirebaseAuth signInWithPopup with a GoogleAuthProvider
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();
      final UserCredential userCredential =
          await _auth.signInWithPopup(googleProvider);
      return userCredential.user;
    } else {
      final  googleUser = await _googleSignIn?.signIn();
      if (googleUser == null) return null;

      final  googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
   
      return (await _auth.signInWithCredential(credential)).user;
    }
  }

  Future <User?>registerWithEmail(String email, String password) async {
    try{
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
          return userCredential.user;
    }catch(e){
      print('Error in registration: $e');
      return null;
    }
  }
  Future<User?> signInWithEmail(String email, String password) async {
    try{
      final  userCredential = await _auth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
          return userCredential.user;
    }catch(e){
      print('Error in sign in: $e');
      return null;
    }
  }


  Future<void> signOut() async {
    if (!kIsWeb) {
      await _googleSignIn?.signOut();
    }
    await _auth.signOut();
  }

  Stream <User?> get authStateChanges => _auth.authStateChanges();

  /// Sends a password reset email to [email].
  /// Returns true when the request was sent successfully, false otherwise.
  Future<bool> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException(sendPasswordReset): ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Unexpected error in sendPasswordReset: $e');
      return false;
    }
  }
}