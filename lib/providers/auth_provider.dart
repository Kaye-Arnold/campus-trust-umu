import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _service = AuthService();

  User? _user;
  bool _loading = false;
  String? _error;

  User?   get user          => _user;
  bool    get isAuthenticated => _user != null;
  bool    get isLoading     => _loading;
  String? get error         => _error;

  AuthProvider() {
    _service.authStateChanges.listen((u) {
      _user = u;
      notifyListeners();
    });
  }

  Future<bool> signInWithGoogle() async {
    _loading = true;
    _error   = null;
    notifyListeners();
    try {
      final result = await _service.signInWithGoogle();
      // Do not wait for the authStateChanges stream before protected actions.
      _user = _service.currentUser;
      _loading = false;
      notifyListeners();
      return result != null;
    } catch (e) {
      _error   = e.toString();
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _service.signOut();
  }
}
