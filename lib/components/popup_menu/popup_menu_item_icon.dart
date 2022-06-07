import 'package:artbooking/components/animations/fade_in_y.dart';
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
                      child: icon,
                    ),
                    Expanded(
                      child: Text(
                        textLabel,
                        style: Utilities.fonts.body(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (selected) Icon(UniconsLine.check),
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
  final double height;
  final EdgeInsets? padding;
  final MouseCursor? mouseCursor;
  final bool selected;
  final Duration delay;
}
