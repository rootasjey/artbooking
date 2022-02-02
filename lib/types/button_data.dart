import 'package:flutter/widgets.dart';

class ButtonData {
  final String textValue;
  final Widget icon;
  final void Function()? onTap;
  ButtonData({
    required this.textValue,
    required this.icon,
    this.onTap,
  });

  ButtonData copyWith({
    String? textValue,
    Widget? icon,
    void Function()? onTap,
  }) {
    return ButtonData(
      textValue: textValue ?? this.textValue,
      icon: icon ?? this.icon,
      onTap: onTap ?? this.onTap,
    );
  }

  @override
  String toString() =>
      'ButtonData(textValue: $textValue, icon: $icon, onTap: $onTap)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ButtonData &&
        other.textValue == textValue &&
        other.icon == icon &&
        other.onTap == onTap;
  }

  @override
  int get hashCode => textValue.hashCode ^ icon.hashCode ^ onTap.hashCode;
}
