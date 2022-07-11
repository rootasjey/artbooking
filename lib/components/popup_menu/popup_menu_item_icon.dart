import 'package:artbooking/components/animations/fade_in_y.dart';
import 'package:artbooking/components/popup_menu/popup_menu_icon.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

/// A PopupMenuItem with a leading icon.
class PopupMenuItemIcon<T> extends PopupMenuItem<T> {
  PopupMenuItemIcon({
    Key? key,
    required this.icon,
    required this.textLabel,
    this.enabled = true,
    this.height = kMinInteractiveDimension,
    this.mouseCursor,
    this.padding,
    this.value,
    this.selected = false,
    this.delay = const Duration(seconds: 0),
    this.selectedColor,
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
                opacity: 0.6,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 18.0),
                      child: icon.runtimeType == PopupMenuIcon
                          ? PopupMenuIcon(
                              (icon as PopupMenuIcon).iconData,
                              color: selectedColor ?? icon.color,
                            )
                          : icon,
                    ),
                    Expanded(
                      child: Text(
                        textLabel,
                        style: Utilities.fonts.body(
                          color: selectedColor,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (selected)
                      Icon(
                        UniconsLine.check,
                        color: selectedColor,
                      ),
                  ],
                ),
              ),
            ),
          ),
        );

  final Widget icon;
  final String textLabel;
  final T? value;
  final bool enabled;
  final Color? selectedColor;
  final double height;
  final EdgeInsets? padding;
  final MouseCursor? mouseCursor;
  final bool selected;
  final Duration delay;

  PopupMenuItemIcon<T> copyWith({
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
    return PopupMenuItemIcon(
      enabled: enabled ?? this.enabled,
      selected: selected ?? this.selected,
      selectedColor: selectedColor ?? this.selectedColor,
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
