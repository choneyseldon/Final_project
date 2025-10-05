import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Register with email and password
  Future<User?> signUpWithEmail(String email, String password, String fullName) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update display name
      await result.user?.updateDisplayName(fullName);
      
      return result.user;
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign in with Google (placeholder - will be implemented)
  Future<User?> signInWithGoogle() async {
    try {
      // For now, show placeholder message
      throw Exception('Google Sign-In will be implemented in next update');
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign in with Facebook (placeholder - will be implemented)
  Future<User?> signInWithFacebook() async {
    try {
      // For now, show placeholder message
      throw Exception('Facebook Sign-In will be implemented in next update');
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Handle auth exceptions
  String _handleAuthException(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return 'No user found for this email.';
        case 'wrong-password':
          return 'Wrong password provided.';
        case 'email-already-in-use':
          return 'An account already exists for this email.';
        case 'weak-password':
          return 'The password provided is too weak.';
        case 'invalid-email':
          return 'The email address is not valid.';
        case 'user-disabled':
          return 'This user account has been disabled.';
        case 'too-many-requests':
          return 'Too many requests. Try again later.';
        default:
          return 'Authentication failed. Please try again.';
      }
    }
    return e.toString();
  }
}