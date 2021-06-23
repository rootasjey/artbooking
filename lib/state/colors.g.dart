// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'colors.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$StateColors on StateColorsBase, Store {
  final _$backgroundAtom = Atom(name: 'StateColorsBase.background');

  @override
  Color get background {
    _$backgroundAtom.reportRead();
    return super.background;
  }

  @override
  set background(Color value) {
    _$backgroundAtom.reportWrite(value, super.background, () {
      super.background = value;
    });
  }

  final _$foregroundAtom = Atom(name: 'StateColorsBase.foreground');

  @override
  Color get foreground {
    _$foregroundAtom.reportRead();
    return super.foreground;
  }

  @override
  set foreground(Color value) {
    _$foregroundAtom.reportWrite(value, super.foreground, () {
      super.foreground = value;
    });
  }

  final _$primaryAtom = Atom(name: 'StateColorsBase.primary');

  @override
  Color get primary {
    _$primaryAtom.reportRead();
    return super.primary;
  }

  @override
  set primary(Color value) {
    _$primaryAtom.reportWrite(value, super.primary, () {
      super.primary = value;
    });
  }

  final _$secondaryAtom = Atom(name: 'StateColorsBase.secondary');

  @override
  Color get secondary {
    _$secondaryAtom.reportRead();
    return super.secondary;
  }

  @override
  set secondary(Color value) {
    _$secondaryAtom.reportWrite(value, super.secondary, () {
      super.secondary = value;
    });
  }

  final _$StateColorsBaseActionController =
      ActionController(name: 'StateColorsBase');

  @override
  void refreshTheme(Brightness? brightness) {
    final _$actionInfo = _$StateColorsBaseActionController.startAction(
        name: 'StateColorsBase.refreshTheme');
    try {
      return super.refreshTheme(brightness);
    } finally {
      _$StateColorsBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setPrimaryColor(Color color) {
    final _$actionInfo = _$StateColorsBaseActionController.startAction(
        name: 'StateColorsBase.setPrimaryColor');
    try {
      return super.setPrimaryColor(color);
    } finally {
      _$StateColorsBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSecondaryColor(Color color) {
    final _$actionInfo = _$StateColorsBaseActionController.startAction(
        name: 'StateColorsBase.setSecondaryColor');
    try {
      return super.setSecondaryColor(color);
    } finally {
      _$StateColorsBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
background: ${background},
foreground: ${foreground},
primary: ${primary},
secondary: ${secondary}
    ''';
  }
}
