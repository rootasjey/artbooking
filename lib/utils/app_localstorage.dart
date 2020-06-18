import 'package:cross_local_storage/cross_local_storage.dart';
import 'package:flutter/material.dart';

class AppLocalStorageKeys {
  static const username = 'username';
  static const email = 'email';
  static const password = 'password';
  static const user_uid = 'user_uid';
  static const autoBrightness = 'autoBrightness';
  static const brightness = 'brightness';
  static const is_device_sub_notif_active = 'is_device_sub_notif_active';
}

class AppLocalStorage {
  static LocalStorageInterface _localStorage;

  Future clearUserAuthData() async {
    await _localStorage.remove(AppLocalStorageKeys.username);
    await _localStorage.remove(AppLocalStorageKeys.email);
    await _localStorage.remove(AppLocalStorageKeys.password);
    await _localStorage.remove(AppLocalStorageKeys.user_uid);
  }

  bool getAutoBrightness() {
    return _localStorage.getBool(AppLocalStorageKeys.autoBrightness) ?? true;
  }

  Brightness getBrightness() {
    final brightness = _localStorage.getString(AppLocalStorageKeys.brightness) == 'dark' ?
      Brightness.dark : Brightness.light;

    return brightness;
  }

  Map<String, String> getCredentials() {
    final credentials = Map<String, String>();

    credentials[AppLocalStorageKeys.email] = _localStorage.getString(AppLocalStorageKeys.email);
    credentials[AppLocalStorageKeys.password] = _localStorage.getString(AppLocalStorageKeys.password);

    return credentials;
  }

  String getLang() => _localStorage.getString('lang') ?? 'en';

  bool getPageOrder({String pageRoute}) {
    final key = '$pageRoute?order';
    final descending = _localStorage.getBool(key);
    return descending ?? true;
  }

  String getUserName() => _localStorage.getString(AppLocalStorageKeys.username) ?? '';
  String getUserUid() => _localStorage.getString(AppLocalStorageKeys.user_uid) ?? '';

  Future initialize() async {
    if (_localStorage != null) { return; }
    _localStorage = await LocalStorage.getInstance();
  }

  bool isDeviceSubNotifActive() {
    return _localStorage.getBool(AppLocalStorageKeys.is_device_sub_notif_active) ?? false;
  }

  void setAutoBrightness(bool value) {
    _localStorage.setBool(AppLocalStorageKeys.autoBrightness, value);
  }

  void setBrightness(Brightness brightness) {
    final strBrightness = brightness == Brightness.dark ? 'dark' : 'light';
    _localStorage.setString(AppLocalStorageKeys.brightness, strBrightness);
  }

  void setCredentials({String email, String password}) {
    _localStorage.setString(AppLocalStorageKeys.email, email);
    _localStorage.setString(AppLocalStorageKeys.password, password);
  }

  void setDeviceSubNotif(bool value) {
    _localStorage.setBool(AppLocalStorageKeys.is_device_sub_notif_active, value);
  }

  void setLang(String lang) => _localStorage.setString('lang', lang);

  void setPageOrder({bool descending, String pageRoute}) {
    final key = '$pageRoute?order';
    _localStorage.setBool(key, descending);
  }

  void setUserName(String userName) {
    _localStorage.setString(AppLocalStorageKeys.username, userName);
  }

  void setUserUid(String userName) {
    _localStorage.setString(AppLocalStorageKeys.user_uid, userName);
  }
}

final appLocalStorage = AppLocalStorage();
