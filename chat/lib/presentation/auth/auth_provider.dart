import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/user_model.dart';
import '../../features/auth/application/auth_notifier.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._ref);

  final Ref _ref;

  AsyncValue<AuthState> _authValue = const AsyncLoading();

  bool get isLoading =>
      _authValue.isLoading || _authValue.value is AuthStateLoading;
  String? get error {
    final value = _authValue.value;
    return switch (value) {
      AuthStateError(:final message) => message,
      _ => null,
    };
  }
  UserModel? get user => currentUser;
  UserModel? get currentUser {
    final value = _authValue.value;
    return switch (value) {
      AuthStateAuthenticated(:final user) => user,
      _ => null,
    };
  }
  bool get codeSent => _authValue.value is AuthStateCodeSent;
  bool get isAuthenticated => currentUser != null;

  void syncState(AsyncValue<AuthState> value) {
    _authValue = value;
    notifyListeners();
  }

  void setLoading(bool value) {
    // No-op in the Riverpod-backed bridge; loading state comes from AuthNotifier.
  }

  Future<void> sendOtp(String phoneNumber) async {
    await _ref.read(authNotifierV2Provider.notifier).sendOtp(phoneNumber);
  }

  Future<bool> verifyOtp(String smsCode) async {
    return _ref.read(authNotifierV2Provider.notifier).verifyOtp(smsCode);
  }

  Future<void> logOut() async {
    await _ref.read(authNotifierV2Provider.notifier).logout();
  }

  Future<void> updateProfile({required String name, String? status}) async {
    await _ref.read(authNotifierV2Provider.notifier).updateProfile(
      name: name,
      status: status,
    );
  }

  Future<void> blockUser(String otherUserId) async {
    await _ref.read(authNotifierV2Provider.notifier).blockUser(otherUserId);
  }

  Future<void> reportUser(String otherUserId, String chatId) async {
    await _ref.read(authNotifierV2Provider.notifier).reportUser(
      targetUserId: otherUserId,
      targetChatId: chatId,
      reason: 'Reported by user from UI',
    );
  }
}
