import 'package:flutter/material.dart';
import 'package:uas/services/api_auth_service.dart';
import 'package:uas/utils/auth_status.dart';
import 'package:uas/utils/profile.dart';

class AuthProvider extends ChangeNotifier {
  final ApiAuthService _service;

  AuthProvider(this._service);

  String? _message;
  Profile? _profile;
  AuthStatus _authStatus = AuthStatus.unauthenticated;

  Profile? get profile => _profile;
  String? get message => _message;
  AuthStatus get authStatus => _authStatus;
  String? get token => _service.token;

  Future createAccount(String fullname, String email, String password) async {
    try {
      _authStatus = AuthStatus.creatingAccount;
      notifyListeners();

      final result = await _service.register(fullname, email, password);

      if (result['success'] == true) {
        _authStatus = AuthStatus.accountCreated;
        _message =
            result['message'] ??
            "Akun berhasil dibuat, Login untuk melanjutkan";
      } else {
        _message = result['message'] ?? "Registrasi gagal";
        _authStatus = AuthStatus.error;
      }
    } catch (e) {
      _message = e is String ? e : e.toString();
      _authStatus = AuthStatus.error;
    }
    notifyListeners();
  }

  Future signInUser(String email, String password) async {
    try {
      _authStatus = AuthStatus.authenticating;
      notifyListeners();

      final result = await _service.login(email, password);

      if (result['success'] == true) {
        // Parse user profile from response
        if (result['user'] != null) {
          _profile = Profile.fromJson(result['user']);
        }

        _authStatus = AuthStatus.authenticated;
        _message =
            result['message'] ?? "Login berhasil, selamat datang kembali!";
      } else {
        _message = result['message'] ?? "Login gagal";
        _authStatus = AuthStatus.error;
      }
    } catch (e) {
      _message = e.toString();
      _authStatus = AuthStatus.error;
    }
    notifyListeners();
  }

  Future signOutUser() async {
    try {
      _authStatus = AuthStatus.signingOut;
      notifyListeners();

      await _service.logout();

      _profile = null;
      _authStatus = AuthStatus.unauthenticated;
      _message = "Logout berhasil, sampai jumpa lagi!";
    } catch (e) {
      _message = e.toString();
      _authStatus = AuthStatus.error;
    }
    notifyListeners();
  }

  Future updateProfile() async {
    final fetchedProfile = await _service.getProfile();
    if (fetchedProfile != null) {
      _profile = fetchedProfile;
      notifyListeners();
    }
  }

  /// Restore authentication state from saved token
  void restoreToken(String token) {
    _service.setToken(token);
    _authStatus = AuthStatus.authenticated;
    notifyListeners();
  }
}
