import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists first-run marketing onboarding; drives GoRouter redirect + refresh.
class OnboardingHolder extends ChangeNotifier {
  OnboardingHolder(this._completed);

  static const prefsKey = 'onboarding_completed';

  bool _completed;
  bool get completed => _completed;

  Future<void> markCompleted() async {
    if (_completed) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(prefsKey, true);
    _completed = true;
    notifyListeners();
  }
}
