import 'package:flutter/material.dart';
import 'package:uas/services/firebase_auth_service.dart';
import 'package:uas/utils/firebase_auth_status.dart';
import 'package:uas/utils/profile.dart';

class FirebaseAuthProvider extends ChangeNotifier {
  final FirebaseAuthService _service;

  FirebaseAuthProvider(this._service);

  String? _message;
  Profile? _profile;
  FirebaseAuthStatus _authStatus = FirebaseAuthStatus.unauthenticated;

  Profile? get profile => _profile;
  String? get message => _message;
  FirebaseAuthStatus get authStatus => _authStatus;

  Future createAccount(String fullname, String email, String password) async {
    try {
      _authStatus = FirebaseAuthStatus.creatingAccount;
      notifyListeners();

      await _service.createUser(fullname, email, password);
      _authStatus = FirebaseAuthStatus.accountCreated;
      _message = "Akun berhasil dibuat, Login untuk melanjutkan";
    } catch (e) {
      _message = e is String ? e : e.toString();
      _authStatus = FirebaseAuthStatus.error;
    }
    notifyListeners();
  }

  Future signInUser(String email, String password) async {
    try {
      _authStatus = FirebaseAuthStatus.authenticating;
      notifyListeners();

      final result = await _service.signInUser(email, password);
      if (result.user != null) {
        _profile = await _service.getProfile(result.user!.uid);
      }

      _authStatus = FirebaseAuthStatus.authenticated;
      _message = "Login berhasil, selamat datang kembali!";
    } catch (e) {
      _message = e.toString();
      _authStatus = FirebaseAuthStatus.error;
    }
    notifyListeners();
  }

  Future signOutUser() async {
    try {
      _authStatus = FirebaseAuthStatus.signingOut;
      notifyListeners();

      await _service.signOut();

      _authStatus = FirebaseAuthStatus.unauthenticated;
      _message = "Logout berhasil, sampai jumpa lagi!";
    } catch (e) {
      _message = e.toString();
      _authStatus = FirebaseAuthStatus.error;
    }
    notifyListeners();
  }

  Future updateProfile() async {
    final user = await _service.userChanges();
    _profile = Profile(
      fullname: user?.displayName,
      email: user?.email,
      photoUrl: user?.photoURL,
    );
    notifyListeners();
  }
}
