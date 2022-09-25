import 'package:artbooking/components/animations/fade_in_y.dart';
import 'package:artbooking/components/popup_menu/popup_menu_icon.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

/// A PopupMenuItem which display a checkmark if active.
class PopupMenuToggleItem<T> extends PopupMenuItem<T> {
  PopupMenuToggleItem({
    Key? key,
    required this.textLabel,
    this.enabled = true,
    this.selected = false,
    this.foregroundColor,
    this.height = kMinInteractiveDimension,
    this.delay = const Duration(seconds: 0),
    this.padding,
    this.mouseCursor,
    this.value,
    this.icon,
  }) : super(
          key: key,
          value: value,
          enabled: enabled,
          height: height,
          padding: padding,
          mouseCursor: mouseCursor,
          child: FadeInY(
            beginY: 12.0,
            delay: delay,
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Opacity(
                opacity: 1.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    if (icon != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 18.0),
                        child: icon.runtimeType == PopupMenuIcon
                            ? PopupMenuIcon(
                                (icon as PopupMenuIcon).iconData,
                                color: foregroundColor ?? icon.color,
                              )
                            : icon,
                      ),
                    Expanded(
                      child: Text(
                        textLabel,
                        style: Utilities.fonts.body(
                          color: foregroundColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (selected)
                      Icon(
                        UniconsLine.check,
                        color: foregroundColor,
                      ),
                  ],
                ),
              ),
            ),
          ),
        );

  final Widget? icon;
  final String textLabel;
  final T? value;
  final bool enabled;
  final Color? foregroundColor;
  final double height;
  final EdgeInsets? padding;
  final MouseCursor? mouseCursor;
  final bool selected;
  final Duration delay;

  PopupMenuToggleItem<T> copyWith({
    bool? enabled,
    bool? selected,
    Color? selectedColor,
    double? height,
    Duration? delay,
    EdgeInsets? padding,
    MouseCursor? mouseCursor,
    String? textLabel,
    T? value,
    Widget? icon,
  }) {
    return PopupMenuToggleItem(
      enabled: enabled ?? this.enabled,
      selected: selected ?? this.selected,
      foregroundColor: selectedColor ?? this.foregroundColor,
      height: height ?? this.height,
      delay: delay ?? this.delay,
      padding: padding ?? this.padding,
      mouseCursor: mouseCursor ?? this.mouseCursor,
      textLabel: textLabel ?? this.textLabel,
      value: value ?? this.value,
      icon: icon ?? this.icon,
    );
  }
}
