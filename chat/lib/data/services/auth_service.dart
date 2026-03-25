import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../domain/models/user_model.dart';

class AuthService {
  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  Stream<User?> get authStateChanges {
    try {
      if (Firebase.apps.isEmpty) return const Stream.empty();
      return _auth.authStateChanges();
    } catch (e) {
      debugPrint('Auth state changes stream failed: $e');
      return const Stream.empty();
    }
  }

  User? get currentUser {
    try {
      if (Firebase.apps.isEmpty) return null;
      return _auth.currentUser;
    } catch (e) {
      return null;
    }
  }

  String? _verificationId;

  Future<void> sendOtp({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-resolution on Android devices
          await _signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          onError(e.message ?? 'Verification failed');
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      onError(e.toString());
    }
  }

  Future<UserModel?> verifyOtpAndSignIn(String smsCode) async {
    if (_verificationId == null) throw Exception('Verification ID is missing');

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );
      return await _signInWithCredential(credential);
    } catch (e) {
      throw Exception('Failed to verify OTP: ${e.toString()}');
    }
  }

  Future<UserModel?> _signInWithCredential(
    PhoneAuthCredential credential,
  ) async {
    try {
      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      final user = userCredential.user;

      if (user != null) {
        try {
          return await _syncUserToFirestore(user);
        } catch (e) {
          debugPrint('Firestore Sync Error: $e');
          // If Firestore fails (e.g., rules or not created),
          // we still return a basic user model so login doesn't crash.
          return UserModel(
            id: user.uid,
            name: user.phoneNumber ?? 'User',
            lastSeen: DateTime.now(),
            status: 'online',
          );
        }
      }
      return null;
    } catch (e) {
      throw Exception('Sign in failed: ${e.toString()}');
    }
  }

  Future<UserModel> _syncUserToFirestore(User firebaseUser) async {
    try {
      if (Firebase.apps.isEmpty) throw Exception('Firebase not initialized');

      final userDoc = _firestore.collection('users').doc(firebaseUser.uid);
      final snapshot = await userDoc.get();

      if (snapshot.exists && snapshot.data() != null) {
        final userModel = UserModel.fromJson(snapshot.data()!);
        // Update last seen, status, and phone number
        final updatedModel = userModel.copyWith(
          lastSeen: DateTime.now(),
          status: 'online',
          phoneNumber: firebaseUser.phoneNumber,
        );
        await userDoc.update(updatedModel.toJson());
        return updatedModel;
      } else {
        // Create new user
        final newUser = UserModel(
          id: firebaseUser.uid,
          name: firebaseUser.phoneNumber ?? 'Unknown',
          lastSeen: DateTime.now(),
          status: 'online',
          phoneNumber: firebaseUser.phoneNumber,
        );
        await userDoc.set(newUser.toJson());
        return newUser;
      }
    } catch (e) {
      debugPrint('Sync to Firestore failed: $e');
      rethrow; // Caught by the caller
    }
  }

  Future<void> logOut() async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'status': 'offline',
        'lastSeen': DateTime.now().toIso8601String(),
      });
    }
    await _auth.signOut();
  }

  Future<UserModel?> getUser(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromJson(doc.data()!);
    }
    return null;
  }

  Future<void> updateUser(UserModel user) async {
    await _firestore.collection('users').doc(user.id).update(user.toJson());
  }

  Future<void> blockUser(String currentUserId, String blockedUserId) async {
    await _firestore.collection('users').doc(currentUserId).update({
      'blockedUsers': FieldValue.arrayUnion([blockedUserId]),
    });
  }

  Future<void> reportContent({
    required String reporterId,
    required String reportedUserId,
    required String chatId,
    required String reason,
  }) async {
    await _firestore.collection('reports').add({
      'reporterId': reporterId,
      'reportedUserId': reportedUserId,
      'chatId': chatId,
      'reason': reason,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
