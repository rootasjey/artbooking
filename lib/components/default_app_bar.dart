import 'package:artbooking/components/app_icon.dart';
import 'package:artbooking/components/page_app_bar.dart';
import 'package:artbooking/state/colors.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unicons/unicons.dart';

class DefaultAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final mustShowNavBack =
        context.router.stack.length > 1 || context.router.root.stack.length > 1;

    return PageAppBar(
      title: Padding(
        padding: const EdgeInsets.only(
          left: 32.0,
          top: 16.0,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (mustShowNavBack)
              Padding(
                padding: const EdgeInsets.only(
                  left: 10.0,
                  right: 16.0,
                ),
                child: IconButton(
                  color: stateColors.foreground,
                  onPressed: context.router.pop,
                  icon: Icon(UniconsLine.arrow_left),
                ),
              ),
            AppIcon(
              padding: const EdgeInsets.only(right: 12.0),
            ),
            Text(
              "ArtBooking",
              style: GoogleFonts.yellowtail(
                color: stateColors.foreground.withOpacity(0.6),
                fontSize: 24.0,
              ),
            ),
          ],
        ),
      ),
      // titlePadding: const EdgeInsets.only(left: 12.0),
    );
  }
}
