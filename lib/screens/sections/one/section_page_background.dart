import 'package:artbooking/globals/utilities.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class SectionPageBackground extends StatelessWidget {
  const SectionPageBackground({
    Key? key,
    required this.backgroundColor,
    this.padding = EdgeInsets.zero,
  }) : super(key: key);

  final EdgeInsets padding;
  final int backgroundColor;

  @override
  Widget build(BuildContext context) {
    final Color color =
        Theme.of(context).textTheme.bodyText2?.color?.withOpacity(0.1) ??
            Colors.black38;

    return Container(
      width: 140.0,
      height: 140.0,
      padding: padding,
      child: Card(
        elevation: 0.0,
        color: Color(backgroundColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.0),
          side: BorderSide(width: 2.0, color: color),
        ),
        child: Opacity(
          opacity: 0.6,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "background_color_default".tr(),
                style: Utilities.fonts.style(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
