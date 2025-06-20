import 'package:injectable/injectable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

@injectable
class AuthService {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  AuthService(this._firebaseAuth, this._googleSignIn);

  /// Current authenticated user
  User? get currentUser => _firebaseAuth.currentUser;

  /// Current user ID - throws if not authenticated
  String get currentUserId {
    final user = currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    return user.uid;
  }

  /// Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Create user with email and password
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Sign in with Google
  Future<UserCredential> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google sign in was cancelled');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _firebaseAuth.signInWithCredential(credential);
    } catch (e) {
      throw Exception('Google sign in failed: ${e.toString()}');
    }
  }

  /// Sign in anonymously
  Future<UserCredential> signInAnonymously() async {
    return await _firebaseAuth.signInAnonymously();
  }

  /// Sign out current user
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  /// Ensure user is authenticated (sign in anonymously if not)
  Future<void> ensureAuthenticated() async {
    if (!isAuthenticated) {
      await signInAnonymously();
    }
  }

  /// Delete current user account
  Future<void> deleteAccount() async {
    final user = currentUser;
    if (user != null) {
      await user.delete();
    }
  }

  /// Handle Firebase Auth exceptions with user-friendly messages
  Exception _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return Exception('No user found with this email address.');
      case 'wrong-password':
        return Exception('Incorrect password.');
      case 'email-already-in-use':
        return Exception('An account already exists with this email address.');
      case 'weak-password':
        return Exception('Password is too weak.');
      case 'invalid-email':
        return Exception('Invalid email address.');
      case 'user-disabled':
        return Exception('This account has been disabled.');
      case 'too-many-requests':
        return Exception('Too many failed attempts. Please try again later.');
      default:
        return Exception('Authentication failed: ${e.message}');
    }
  }
}
