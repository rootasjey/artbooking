import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/types/enums/enum_discover_type.dart';
import 'package:artbooking/types/enums/enum_items_layout.dart';
import 'package:artbooking/globals/constants/storage_keys_constants.dart';
import 'package:cross_local_storage/cross_local_storage.dart';

class StorageUtilities {
  const StorageUtilities();

  static LocalStorageInterface? _localStorage;

  // / --------------- /
  // /     General     /
  // / --------------- /
  bool containsKey(String key) => _localStorage!.containsKey(key);

  String? getString(String key) => _localStorage!.getString(key);

  bool? getBool(String key) => _localStorage!.getBool(key);

  Future initialize() async {
    if (_localStorage != null) {
      return;
    }

    _localStorage = await LocalStorage.getInstance();
  }

  Future<bool> setBool(String key, bool value) =>
      _localStorage!.setBool(key, value);

  Future<bool> setString(String key, String value) =>
      _localStorage!.setString(key, value);

  // / -----------------/
  // /   First launch   /
  // / -----------------/
  bool isFirstLanch() {
    return _localStorage!.getBool(Constants.storageKeys.firstLaunch) ?? true;
  }

  void setFirstLaunch({bool? overrideValue}) {
    if (overrideValue != null) {
      _localStorage!.setBool(Constants.storageKeys.firstLaunch, overrideValue);
      return;
    }

    _localStorage!.setBool(Constants.storageKeys.firstLaunch, false);
  }

  // / ---------------/
  // /      USER      /
  // /----------------/
  Future clearUserAuthData() async {
    await _localStorage!.remove(Constants.storageKeys.username);
    await _localStorage!.remove(Constants.storageKeys.email);
    await _localStorage!.remove(Constants.storageKeys.password);
    await _localStorage!.remove(Constants.storageKeys.userUid);
  }

  Map<String, String?> getCredentials() {
    final credentials = Map<String, String?>();

    credentials[Constants.storageKeys.email] =
        _localStorage!.getString(Constants.storageKeys.email);
    credentials[Constants.storageKeys.password] =
        _localStorage!.getString(Constants.storageKeys.password);

    return credentials;
  }

  String getLang() =>
      _localStorage!.getString(Constants.storageKeys.lang) ?? 'en';
  String getUserName() =>
      _localStorage!.getString(Constants.storageKeys.username) ?? '';
  String getUserUid() =>
      _localStorage!.getString(Constants.storageKeys.userUid) ?? '';

  void setCredentials({required String email, required String password}) {
    _localStorage!.setString(Constants.storageKeys.email, email);
    _localStorage!.setString(Constants.storageKeys.password, password);
  }

  void setEmail(String email) {
    _localStorage!.setString(Constants.storageKeys.email, email);
  }

  void setPassword(String password) {
    _localStorage!.setString(Constants.storageKeys.password, password);
  }

  void setLang(String lang) => _localStorage!.setString('lang', lang);

  // / ----------------/
  // /      Layout     /
  // / ----------------/
  EnumDiscoverType getDiscoverType() {
    final value = _localStorage!.getString(Constants.storageKeys.discoverType);
    return value == 'authors'
        ? EnumDiscoverType.authors
        : EnumDiscoverType.references;
  }

  List<String> getDrafts() {
    List<String> drafts =
        _localStorage!.getStringList(Constants.storageKeys.drafts) ?? [];
    return drafts;
  }

  EnumItemsLayout getItemsStyle(String pageRoute) {
    final itemsStyle = _localStorage!
        .getString('${Constants.storageKeys.itemsStyle}$pageRoute');

    switch (itemsStyle) {
      case StorageKeys.itemsLayoutGrid:
        return EnumItemsLayout.grid;
      case StorageKeys.itemsLayoutList:
        return EnumItemsLayout.list;
      default:
        return EnumItemsLayout.list;
    }
  }

  String getPageLang({String? pageRoute}) {
    final key = '$pageRoute?lang';
    final lang = _localStorage!.getString(key);
    return lang ?? 'en';
  }

  bool getPageOrder({String? pageRoute}) {
    final key = '$pageRoute?order';
    final descending = _localStorage!.getBool(key);
    return descending ?? true;
  }

  /// Return the expanded state of dashboard side menu.
  bool getDashboardSideMenuExpanded() {
    return _localStorage!
            .getBool(Constants.storageKeys.dashboardSideMenuExpanded) ??
        true;
  }

  void saveDiscoverType(EnumDiscoverType discoverType) {
    final value =
        discoverType == EnumDiscoverType.authors ? 'authors' : 'references';

    _localStorage!.setString('discover_type', value);
  }

  void saveItemsStyle({String? pageRoute, EnumItemsLayout? style}) {
    _localStorage!.setString('items_style_$pageRoute', style.toString());
  }

  /// Set the expanded state of dashboard side menu.
  void setDashboardSideMenuExpanded(bool expanded) async {
    await _localStorage!.setBool(
      Constants.storageKeys.dashboardSideMenuExpanded,
      expanded,
    );
  }

  void setPageLang({required String lang, String? pageRoute}) {
    final key = '$pageRoute?lang';
    _localStorage!.setString(key, lang);
  }

  void setPageOrder({required bool descending, String? pageRoute}) {
    final key = '$pageRoute?order';
    _localStorage!.setBool(key, descending);
  }
}
