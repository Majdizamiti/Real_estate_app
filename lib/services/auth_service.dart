import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import 'database_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final DatabaseService _db = DatabaseService();

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  // Real Firebase Email & Password Sign Up
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String username,
    required UserRole role,
  }) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = credential.user;
      if (user == null) {
        throw Exception('User registration failed');
      }

      UserModel newUser = UserModel(
        uid: user.uid,
        email: email,
        username: username,
        role: role,
        photoUrl: user.photoURL,
      );

      // Save user with role in Realtime Database (/users/$uid)
      await _db.saveUserData(newUser);
      return newUser;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Registration error: ${e.toString()}');
    }
  }

  // Real Firebase Email & Password Sign In
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
    UserRole selectedRole = UserRole.client,
  }) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = credential.user;
      if (user == null) throw Exception('User login failed');

      // Fetch user profile & role from Realtime Database
      UserModel? userModel = await _db.getUserData(user.uid);
      if (userModel != null) {
        return userModel;
      } else {
        UserModel fallback = UserModel(
          uid: user.uid,
          email: email,
          username: email.contains('@') ? email.split('@').first : 'User',
          role: selectedRole,
        );
        await _db.saveUserData(fallback);
        return fallback;
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Login error: ${e.toString()}');
    }
  }

  // Google Sign-In
  Future<UserModel?> signInWithGoogle({UserRole role = UserRole.client}) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCred = await _auth.signInWithCredential(credential);
      User? user = userCred.user;

      if (user != null) {
        UserModel? existingUser = await _db.getUserData(user.uid);
        if (existingUser != null) {
          return existingUser;
        }

        UserModel newUser = UserModel(
          uid: user.uid,
          email: user.email ?? '',
          username: user.displayName ?? 'User',
          role: role,
          photoUrl: user.photoURL,
        );

        await _db.saveUserData(newUser);
        return newUser;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Google Sign-In failed: ${e.toString()}');
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
    } catch (_) {}
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found for that email. Please Register first.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Wrong password or invalid credentials.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'operation-not-allowed':
        return 'Email/Password sign-in is not enabled in Firebase Console.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'invalid-email':
        return 'The email address is formatted incorrectly.';
      default:
        return e.message ?? 'Authentication error (${e.code}).';
    }
  }
}
