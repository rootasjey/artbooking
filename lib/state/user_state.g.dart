// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_state.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$UserState on UserStateBase, Store {
  final _$usernameAtom = Atom(name: 'UserStateBase.username');

  @override
  String get username {
    _$usernameAtom.context.enforceReadPolicy(_$usernameAtom);
    _$usernameAtom.reportObserved();
    return super.username;
  }

  @override
  set username(String value) {
    _$usernameAtom.context.conditionallyRunInAction(() {
      super.username = value;
      _$usernameAtom.reportChanged();
    }, _$usernameAtom, name: '${_$usernameAtom.name}_set');
  }

  final _$uidAtom = Atom(name: 'UserStateBase.uid');

  @override
  String get uid {
    _$uidAtom.context.enforceReadPolicy(_$uidAtom);
    _$uidAtom.reportObserved();
    return super.uid;
  }

  @override
  set uid(String value) {
    _$uidAtom.context.conditionallyRunInAction(() {
      super.uid = value;
      _$uidAtom.reportChanged();
    }, _$uidAtom, name: '${_$uidAtom.name}_set');
  }

  final _$isConnectedAtom = Atom(name: 'UserStateBase.isConnected');

  @override
  bool get isConnected {
    _$isConnectedAtom.context.enforceReadPolicy(_$isConnectedAtom);
    _$isConnectedAtom.reportObserved();
    return super.isConnected;
  }

  @override
  set isConnected(bool value) {
    _$isConnectedAtom.context.conditionallyRunInAction(() {
      super.isConnected = value;
      _$isConnectedAtom.reportChanged();
    }, _$isConnectedAtom, name: '${_$isConnectedAtom.name}_set');
  }

  final _$langAtom = Atom(name: 'UserStateBase.lang');

  @override
  String get lang {
    _$langAtom.context.enforceReadPolicy(_$langAtom);
    _$langAtom.reportObserved();
    return super.lang;
  }

  @override
  set lang(String value) {
    _$langAtom.context.conditionallyRunInAction(() {
      super.lang = value;
      _$langAtom.reportChanged();
    }, _$langAtom, name: '${_$langAtom.name}_set');
  }

  final _$UserStateBaseActionController =
      ActionController(name: 'UserStateBase');

  @override
  void clearAuthCache() {
    final _$actionInfo = _$UserStateBaseActionController.startAction();
    try {
      return super.clearAuthCache();
    } finally {
      _$UserStateBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setLang(String newLang) {
    final _$actionInfo = _$UserStateBaseActionController.startAction();
    try {
      return super.setLang(newLang);
    } finally {
      _$UserStateBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setUserConnected(bool connected) {
    final _$actionInfo = _$UserStateBaseActionController.startAction();
    try {
      return super.setUserConnected(connected);
    } finally {
      _$UserStateBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setUsername(String name) {
    final _$actionInfo = _$UserStateBaseActionController.startAction();
    try {
      return super.setUsername(name);
    } finally {
      _$UserStateBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setUid(String newUid) {
    final _$actionInfo = _$UserStateBaseActionController.startAction();
    try {
      return super.setUid(newUid);
    } finally {
      _$UserStateBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void signOut() {
    final _$actionInfo = _$UserStateBaseActionController.startAction();
    try {
      return super.signOut();
    } finally {
      _$UserStateBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    final string =
        'username: ${username.toString()},uid: ${uid.toString()},isConnected: ${isConnected.toString()},lang: ${lang.toString()}';
    return '{$string}';
  }
}
