import 'package:artbooking/globals/utilities.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

/// Snack bar class.
/// Helper to quickly dispay different snacks types.
class SnackUtilities {
  const SnackUtilities();

  /// Show a snack with an error message.
  Future e({
    required BuildContext context,
    Duration duration = const Duration(seconds: 5),
    Widget? icon,
    required String? message,
    Widget? primaryAction,
    String title = '',
  }) {
    Widget _icon;

    if (icon != null) {
      _icon = icon;
    } else {
      _icon = Icon(
        UniconsLine.times,
        color: Colors.pink,
      );
    }

    return Utilities.flash.groundedBottom(
      context,
      title: title,
      message: message,
      icon: _icon,
      primaryAction: primaryAction,
    );
  }

  /// Show a snack with an informative message.
  Future i({
    required BuildContext context,
    Duration duration = const Duration(seconds: 5),
    Widget? icon,
    required String message,
    Widget? primaryAction,
    String title = '',
  }) {
    Widget _icon;

    if (icon != null) {
      _icon = icon;
    } else {
      _icon = Icon(
        UniconsLine.info,
        color: Colors.blue,
      );
    }

    return Utilities.flash.groundedBottom(
      context,
      title: title,
      message: message,
      icon: _icon,
      primaryAction: primaryAction,
    );
  }

  /// Show a snack with a success message.
  Future s({
    required BuildContext context,
    Duration duration = const Duration(seconds: 5),
    Widget? icon,
    required String message,
    Widget? primaryAction,
    String title = '',
  }) {
    Widget _icon;

    if (icon != null) {
      _icon = icon;
    } else {
      _icon = Icon(
        UniconsLine.check,
        color: Colors.green,
      );
    }

    return Utilities.flash.groundedBottom(
      context,
      title: title,
      message: message,
      icon: _icon,
      duration: duration,
      primaryAction: primaryAction,
    );
  }
}