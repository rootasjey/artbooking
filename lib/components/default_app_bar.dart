import 'package:artbooking/components/app_icon.dart';
import 'package:artbooking/components/page_app_bar.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

class DefaultAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PageAppBar(
      title: Padding(
        padding: const EdgeInsets.only(left: 32.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppIcon(
              padding: const EdgeInsets.only(right: 12.0),
            ),
            Text(
              "ArtBooking",
              style: GoogleFonts.yellowtail(
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
