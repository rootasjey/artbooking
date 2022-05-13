import 'package:artbooking/globals/utilities.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class SeparatorColorCard extends StatelessWidget {
  const SeparatorColorCard({
    Key? key,
    required this.color,
    this.onTap,
  }) : super(key: key);

  final Color color;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final double luminance = color.computeLuminance();
    final Color foreground = luminance < 0.5 ? Colors.white : Colors.black;

    return SizedBox(
      width: 150.0,
      height: 150.0,
      child: Card(
        elevation: onTap != null ? 4.0 : 0.0,
        color: color,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(UniconsLine.palette, color: foreground),
                Opacity(
                  opacity: 0.6,
                  child: Text(
                    "color".tr(),
                    style: Utilities.fonts.body(
                      color: foreground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
