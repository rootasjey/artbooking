import 'package:artbooking/types/enums.dart';
import 'package:artbooking/utils/storage_keys.dart';
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
    return _localStorage!.getBool(StorageKeys.firstLaunch) ?? true;
  }

  void setFirstLaunch({bool? overrideValue}) {
    if (overrideValue != null) {
      _localStorage!.setBool(StorageKeys.firstLaunch, overrideValue);
      return;
    }

    _localStorage!.setBool(StorageKeys.firstLaunch, false);
  }

  // / ---------------/
  // /      USER      /
  // /----------------/
  Future clearUserAuthData() async {
    await _localStorage!.remove(StorageKeys.username);
    await _localStorage!.remove(StorageKeys.email);
    await _localStorage!.remove(StorageKeys.password);
    await _localStorage!.remove(StorageKeys.userUid);
  }

  Map<String, String?> getCredentials() {
    final credentials = Map<String, String?>();

    credentials[StorageKeys.email] =
        _localStorage!.getString(StorageKeys.email);
    credentials[StorageKeys.password] =
        _localStorage!.getString(StorageKeys.password);

    return credentials;
  }

  String getLang() => _localStorage!.getString(StorageKeys.lang) ?? 'en';
  String getUserName() => _localStorage!.getString(StorageKeys.username) ?? '';
  String getUserUid() => _localStorage!.getString(StorageKeys.userUid) ?? '';

  void setCredentials({required String email, required String password}) {
    _localStorage!.setString(StorageKeys.email, email);
    _localStorage!.setString(StorageKeys.password, password);
  }

  void setEmail(String email) {
    _localStorage!.setString(StorageKeys.email, email);
  }

  void setPassword(String password) {
    _localStorage!.setString(StorageKeys.password, password);
  }

  void setLang(String lang) => _localStorage!.setString('lang', lang);

  // / ----------------/
  // /      Layout     /
  // / ----------------/
  DiscoverType getDiscoverType() {
    final value = _localStorage!.getString(StorageKeys.discoverType);
    return value == 'authors' ? DiscoverType.authors : DiscoverType.references;
  }

  List<String> getDrafts() {
    List<String> drafts =
        _localStorage!.getStringList(StorageKeys.drafts) ?? [];
    return drafts;
  }

  ItemsLayout getItemsStyle(String pageRoute) {
    final itemsStyle =
        _localStorage!.getString('${StorageKeys.itemsStyle}$pageRoute');

    switch (itemsStyle) {
      case StorageKeys.itemsLayoutGrid:
        return ItemsLayout.grid;
      case StorageKeys.itemsLayoutList:
        return ItemsLayout.list;
      default:
        return ItemsLayout.list;
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
    return _localStorage!.getBool(StorageKeys.dashboardSideMenuExpanded) ??
        true;
  }

  void saveDiscoverType(DiscoverType discoverType) {
    final value =
        discoverType == DiscoverType.authors ? 'authors' : 'references';

    _localStorage!.setString('discover_type', value);
  }

  void saveItemsStyle({String? pageRoute, ItemsLayout? style}) {
    _localStorage!.setString('items_style_$pageRoute', style.toString());
  }

  /// Set the expanded state of dashboard side menu.
  void setDashboardSideMenuExpanded(bool expanded) async {
    await _localStorage!.setBool(
      StorageKeys.dashboardSideMenuExpanded,
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