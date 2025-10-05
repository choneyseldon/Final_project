import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _initializeAuth();
  }

  void _initializeAuth() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<void> signInWithEmail(String email, String password) async {
    _setLoading(true);
    _clearError();
    
    try {
      final user = await _authService.signInWithEmail(email, password);
      _user = user;
    } catch (e) {
      _errorMessage = e.toString();
    }
    
    _setLoading(false);
  }

  Future<void> signUpWithEmail(String email, String password, String fullName) async {
    _setLoading(true);
    _clearError();
    
    try {
      final user = await _authService.signUpWithEmail(email, password, fullName);
      _user = user;
    } catch (e) {
      _errorMessage = e.toString();
    }
    
    _setLoading(false);
  }

  Future<void> signInWithGoogle() async {
    _setLoading(true);
    _clearError();
    
    try {
      final user = await _authService.signInWithGoogle();
      _user = user;
    } catch (e) {
      _errorMessage = e.toString();
    }
    
    _setLoading(false);
  }

  Future<void> signInWithFacebook() async {
    _setLoading(true);
    _clearError();
    
    try {
      final user = await _authService.signInWithFacebook();
      _user = user;
    } catch (e) {
      _errorMessage = e.toString();
    }
    
    _setLoading(false);
  }

  Future<void> signOut() async {
    _setLoading(true);
    _clearError();
    
    try {
      await _authService.signOut();
      _user = null;
    } catch (e) {
      _errorMessage = e.toString();
    }
    
    _setLoading(false);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}