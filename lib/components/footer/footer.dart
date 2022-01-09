import 'package:artbooking/components/footer/sections/about_us_section.dart';
import 'package:artbooking/components/footer/sections/artworks_section.dart';
import 'package:artbooking/components/footer/sections/legal_section.dart';
import 'package:artbooking/components/footer/sections/user_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Footer extends ConsumerStatefulWidget {
  final ScrollController? pageScrollController;
  final bool closeModalOnNav;
  final bool autoNavToHome;

  Footer({
    this.autoNavToHome = true,
    this.pageScrollController,
    this.closeModalOnNav = false,
  });

  @override
  _FooterState createState() => _FooterState();
}

class _FooterState extends ConsumerState<Footer> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final WrapAlignment alignment =
        width < 700.0 ? WrapAlignment.spaceBetween : WrapAlignment.spaceAround;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 60.0,
        vertical: 90.0,
      ),
      child: Wrap(
        runSpacing: 80.0,
        alignment: alignment,
        children: <Widget>[
          Divider(
            height: 20.0,
            thickness: 1.0,
            color: Colors.black38,
          ),
          LegalSection(),
          ArtworksSection(),
          UserSection(),
          AboutUsSection(),
        ],
      ),
    );
  }
}
