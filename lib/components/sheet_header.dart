import 'package:artbooking/components/circle_button.dart';
import 'package:artbooking/state/colors.dart';
import 'package:artbooking/utils/fonts.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class SheetHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String tooltip;
  final Widget bottom;

  SheetHeader({
    @required this.title,
    this.subtitle,
    this.tooltip,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: CircleButton(
            onTap: context.router.pop,
            tooltip: tooltip,
            icon: Icon(
              UniconsLine.times,
              size: 20.0,
              color: stateColors.primary,
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Opacity(
                opacity: 0.4,
                child: Text(
                  title,
                  style: FontsUtils.mainStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: FontsUtils.mainStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              if (bottom != null) bottom,
            ],
          ),
        ),
      ],
    );
  }
}
