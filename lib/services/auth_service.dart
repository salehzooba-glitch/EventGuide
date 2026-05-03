import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../core/errors.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign Up with Email & Password
  Future<Result<UserModel>> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      // Create user in Firebase Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      User? user = result.user;
      if (user == null) {
        return const Failure('Registration failed');
      }

      // Create user profile in Firestore
      final userModel = UserModel(
        uid: user.uid,
        fullName: fullName.trim(),
        email: email.trim(),
        interests: [],
        savedEvents: [],
        attendedEvents: [],
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userModel.toFirestore());

      // Update display name
      await user.updateDisplayName(fullName.trim());

      return Success(userModel);
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'weak-password':
          message = 'Password is too weak';
          break;
        case 'email-already-in-use':
          message = 'Email already registered';
          break;
        case 'invalid-email':
          message = 'Invalid email address';
          break;
        default:
          message = e.message ?? 'Registration failed';
      }
      return Failure(message, code: e.code);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  // Sign In
  Future<Result<UserModel>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      User? user = result.user;
      if (user == null) {
        return const Failure('Login failed');
      }

      // Get user data from Firestore
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (!doc.exists) {
        return const Failure('User data not found');
      }

      // Update last login
      await _firestore.collection('users').doc(user.uid).update({
        'lastLogin': DateTime.now(),
      });

      final userModel = UserModel.fromFirestore(
        doc.data() as Map<String, dynamic>,
        user.uid,
      );

      return Success(userModel);
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found with this email';
          break;
        case 'wrong-password':
          message = 'Wrong password';
          break;
        case 'invalid-email':
          message = 'Invalid email address';
          break;
        case 'user-disabled':
          message = 'This account has been disabled';
          break;
        default:
          message = e.message ?? 'Login failed';
      }
      return Failure(message, code: e.code);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  // Sign Out
  Future<Result<void>> signOut() async {
    try {
      await _auth.signOut();
      return const Success(null);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  // Get current user data
  Future<Result<UserModel>> getCurrentUserData() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        return const Failure('No user logged in');
      }

      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (!doc.exists) {
        return const Failure('User data not found');
      }

      final userModel = UserModel.fromFirestore(
        doc.data() as Map<String, dynamic>,
        user.uid,
      );

      return Success(userModel);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  // Reset password
  Future<Result<void>> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return const Success(null);
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found with this email';
          break;
        case 'invalid-email':
          message = 'Invalid email address';
          break;
        default:
          message = e.message ?? 'Password reset failed';
      }
      return Failure(message, code: e.code);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  // Update user profile
  Future<Result<UserModel>> updateProfile({
    String? fullName,
    String? profileImage,
    List<String>? interests,
  }) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        return const Failure('No user logged in');
      }

      Map<String, dynamic> updates = {};

      if (fullName != null) {
        updates['fullName'] = fullName.trim();
        await user.updateDisplayName(fullName.trim());
      }

      if (profileImage != null) {
        updates['profileImage'] = profileImage;
      }

      if (interests != null) {
        updates['interests'] = interests;
      }

      if (updates.isNotEmpty) {
        await _firestore.collection('users').doc(user.uid).update(updates);
      }

      // Get updated user data
      return await getCurrentUserData();
    } catch (e) {
      return Failure(e.toString());
    }
  }
}
