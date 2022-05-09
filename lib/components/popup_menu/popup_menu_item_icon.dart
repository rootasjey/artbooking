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
  }) : super(
          key: key,
          value: value,
          enabled: enabled,
          height: height,
          padding: padding,
          mouseCursor: mouseCursor,
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Opacity(
              opacity: 0.6,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 26.0),
                    child: icon,
                  ),
                  Expanded(
                    child: Text(
                      textLabel,
                      style: Utilities.fonts.style(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (selected) Icon(UniconsLine.check),
                ],
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
}
