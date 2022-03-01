import 'package:artbooking/types/user/user_social_links.dart';
import 'package:flutter/material.dart';

class IconSocialLinkData {
  IconSocialLinkData({
    required this.tooltip,
    required this.icon,
    required this.isEmpty,
    required this.socialKey,
    required this.initialValue,
    required this.onValidate,
  });

  final String tooltip;
  final Widget icon;
  final bool isEmpty;
  final String socialKey;
  final String initialValue;
  final UserSocialLinks Function(String) onValidate;

  IconSocialLinkData copyWith({
    String? tooltip,
    Widget? icon,
    bool? isEmpty,
    String? socialKey,
    String? initialValue,
    UserSocialLinks Function(String)? onValidate,
  }) {
    return IconSocialLinkData(
      tooltip: tooltip ?? this.tooltip,
      icon: icon ?? this.icon,
      isEmpty: isEmpty ?? this.isEmpty,
      socialKey: socialKey ?? this.socialKey,
      initialValue: initialValue ?? this.initialValue,
      onValidate: onValidate ?? this.onValidate,
    );
  }

  @override
  String toString() {
    return 'IconSocialLinkData(tooltip: $tooltip, icon: $icon, isEmpty: $isEmpty, socialKey: $socialKey, initialValue: $initialValue)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is IconSocialLinkData &&
        other.tooltip == tooltip &&
        other.icon == icon &&
        other.isEmpty == isEmpty &&
        other.socialKey == socialKey &&
        other.initialValue == initialValue;
  }

  @override
  int get hashCode {
    return tooltip.hashCode ^
        icon.hashCode ^
        isEmpty.hashCode ^
        socialKey.hashCode ^
        initialValue.hashCode;
  }
}
