import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/enums/enum_content_visibility.dart';
import 'package:flutter/material.dart';

class VisibilityTile extends StatelessWidget {
  const VisibilityTile({
    Key? key,
    required this.visibility,
    required this.titleValue,
    required this.subtitleValue,
    this.onTap,
  }) : super(key: key);

  /// Visibility value as string.
  final EnumContentVisibility visibility;

  /// Callback fired after tapping on this tile.
  final void Function(EnumContentVisibility visibility)? onTap;

  /// Subtitle string value.
  final String subtitleValue;

  /// Title string value.
  final String titleValue;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: ListTile(
        onTap: () => onTap?.call(visibility),
        title: Text(
          titleValue,
          style: Utilities.fonts.body(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitleValue,
          style: Utilities.fonts.body(
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
