import 'package:flutter/foundation.dart';

import '../models/user.dart';
import '../services/auth_service.dart';

/// App-wide authentication state. Wraps [AuthService] and exposes the current
/// [User] plus loading/auth status for the router and screens.
class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthService? service}) : _service = service ?? AuthService();

  final AuthService _service;

  User? _user;
  bool _loading = false;
  String? _error;

  User? get user => _user;
  bool get loading => _loading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  bool get isHost => _user?.isHost ?? false;

  /// Called at startup: if a token exists, hydrate the current user.
  Future<void> bootstrap() async {
    print('[AuthProvider] bootstrap start');
    if (!await _service.hasToken()) {
      print('[AuthProvider] no token, bootstrap end');
      return;
    }
    try {
      print('[AuthProvider] token found, fetching me()');
      _user = await _service.me();
      print('[AuthProvider] me() success: ${_user?.email}');
    } catch (e) {
      print('[AuthProvider] bootstrap error: $e');
      _user = null;
    }
    notifyListeners();
    print('[AuthProvider] bootstrap end');
  }

  Future<bool> login(String email, String password) =>
      _run(() => _service.login(email: email, password: password));

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String type = 'consumer',
    String? referralCode,
  }) =>
      _run(() => _service.register(
            name: name,
            email: email,
            password: password,
            phone: phone,
            type: type,
            referralCode: referralCode,
          ));

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  Future<void> logout() async {
    await _service.logout();
    _user = null;
    notifyListeners();
  }

  Future<bool> _run(Future<User> Function() action) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _user = await action();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst(RegExp(r'^ApiException\(\d+\): '), '');
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
