import 'package:artbooking/components/buttons/circle_button.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class SheetHeader extends StatelessWidget {
  SheetHeader({
    required this.title,
    this.subtitle,
    this.tooltip,
    this.bottom,
    this.heroTitleTag = "",
    this.margin = EdgeInsets.zero,
  });

  /// External space around this widget.
  final EdgeInsets margin;

  /// Widget to show below subtitle if any.
  final Widget? bottom;

  /// If provided, will try to make a hero transition with the title.
  final String heroTitleTag;

  /// Subtile's value.
  final String? subtitle;

  /// Ttile's value.
  final String title;

  /// Tooltip's message if anny.
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleButton(
              onTap: () => Utilities.navigation.back(context),
              tooltip: tooltip,
              icon: Icon(
                UniconsLine.times,
                size: 20.0,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: heroTitleTag,
                  child: Opacity(
                    opacity: 0.4,
                    child: Text(
                      title,
                      style: Utilities.fonts.body(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: Utilities.fonts.body(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                if (bottom != null) bottom!,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
