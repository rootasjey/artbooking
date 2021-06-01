import 'package:artbooking/components/desktop_app_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeDesktop extends StatefulWidget {
  @override
  _HomeDesktopState createState() => _HomeDesktopState();
}

class _HomeDesktopState extends State<HomeDesktop>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          DesktopAppBar(),
          body(),
        ],
      ),
    );
  }

  Widget body() {
    return SliverPadding(
      padding: const EdgeInsets.only(top: 120.0),
      sliver: SliverList(
        delegate: SliverChildListDelegate.fixed([
          Column(
            children: [
              Text(
                "ArtBooking",
                style: GoogleFonts.yellowtail(
                  fontSize: 120.0,
                ),
              ),
              Opacity(
                opacity: 0.6,
                child: Text(
                  "app_caption".tr(),
                  style: TextStyle(
                    fontSize: 26.0,
                  ),
                ),
              ),
            ],
          ),
        ]),
      ),
    );
  }
}
