import 'package:artbooking/utils/app_localstorage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:mobx/mobx.dart';

part 'user_state.g.dart';

class UserState = UserStateBase with _$UserState;

abstract class UserStateBase with Store {
  FirebaseUser _userAuth;

  @observable
  String username = '';

  @observable
  bool isConnected = false;

  @observable
  String lang = 'en';

  Future<FirebaseUser> get userAuth async {
    if (_userAuth != null) {
      return _userAuth;
    }

    _userAuth = await FirebaseAuth.instance.currentUser();

    if (_userAuth == null) {
      await _signin();
    }

    if (_userAuth != null) {
      setUsername(_userAuth.displayName);
    }

    return _userAuth;
  }

  /// Signin user with credentials if FirebaseAuth is null.
  Future _signin() async {
    try {
      final credentialsMap = appLocalStorage.getCredentials();

      final email = credentialsMap['email'];
      final password = credentialsMap['password'];

      if ((email == null || email.isEmpty) || (password == null || password.isEmpty)) {
        return null;
      }

      final auth = await FirebaseAuth.instance
        .signInWithEmailAndPassword(
          email: email,
          password: password,
        );

      _userAuth = auth.user;
      isConnected = true;

    } catch (error) {
      debugPrint(error.toString());
      appLocalStorage.clearUserAuthData();
    }
  }

  /// Use on sign out / user's data has changed.
  @action
  void clearAuthCache() {
    _userAuth = null;
  }

  @action
  void setLang(String newLang) {
    lang = newLang;
  }

  @action
  void setUserConnected(bool connected) {
    isConnected = connected;
  }

  @action
  void setUsername(String name) {
    username = name;
  }

  @action
  void signOut() {
    _userAuth = null;
    isConnected = false;
  }
}

final userState = UserState();
