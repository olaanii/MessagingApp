import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../data/services/auth_service.dart';
import '../../domain/models/user_model.dart';
import 'dart:async';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _error;
  UserModel? _user;
  bool _codeSent = false;
  StreamSubscription<User?>? _authSubscription;

  bool get isLoading => _isLoading;
  String? get error => _error;
  UserModel? get user => _user;
  UserModel? get currentUser => _user; // Added for UI compatibility
  bool get codeSent => _codeSent;
  bool get isAuthenticated => _user != null || _authService.currentUser != null;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  AuthProvider() {
    _init();
  }

  void _init() {
    _authSubscription = _authService.authStateChanges.listen((
      firebaseUser,
    ) async {
      if (firebaseUser == null) {
        _user = null;
        notifyListeners();
      } else {
        // Recovery: Fetch user model if it exists in Firestore
        _user = await _authService.getUser(firebaseUser.uid);
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<void> sendOtp(String phoneNumber) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    await _authService.sendOtp(
      phoneNumber: phoneNumber,
      onCodeSent: (String verificationId) {
        _codeSent = true;
        _isLoading = false;
        notifyListeners();
      },
      onError: (String errorMsg) {
        _error = errorMsg;
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<bool> verifyOtp(String smsCode) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authService.verifyOtpAndSignIn(smsCode);
      return _user != null;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logOut() async {
    await _authService.logOut();
    _user = null;
    _codeSent = false;
    notifyListeners();
  }

  Future<void> updateProfile({required String name, String? status}) async {
    if (_user == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final updatedUser = _user!.copyWith(
        name: name,
        status: status ?? _user!.status,
      );
      await _authService.updateUser(updatedUser);
      _user = updatedUser;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> blockUser(String otherUserId) async {
    if (_user == null) return;
    try {
      await _authService.blockUser(_user!.id, otherUserId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> reportUser(String otherUserId, String chatId) async {
    if (_user == null) return;
    try {
      await _authService.reportContent(
        reporterId: _user!.id,
        reportedUserId: otherUserId,
        chatId: chatId,
        reason: 'Reported by user from UI',
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
