import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/components/square/square_link.dart';
import 'package:artbooking/types/license/license_links.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:unicons/unicons.dart';
import 'package:url_launcher/url_launcher.dart';

class LicensePageLinks extends StatelessWidget {
  const LicensePageLinks({
    Key? key,
    required this.links,
  }) : super(key: key);

  final LicenseLinks links;

  @override
  Widget build(BuildContext context) {
    if (links.website.isEmpty && links.wikipedia.isEmpty) {
      return Container();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0),
          child: Opacity(
            opacity: 0.6,
            child: Text(
              "Links".toUpperCase(),
              style: Utilities.fonts.style(
                fontSize: 20.0,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        Wrap(
          spacing: 16.0,
          runSpacing: 16.0,
          children: [
            if (links.website.isNotEmpty)
              SquareLink(
                onTap: () => launch(links.website),
                icon: Icon(
                  UniconsLine.globe,
                  size: 42.0,
                ),
                text: Text(
                  "website",
                  style: Utilities.fonts.style(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            if (links.wikipedia.isNotEmpty)
              SquareLink(
                onTap: () => launch(links.wikipedia),
                icon: Icon(
                  FontAwesomeIcons.wikipediaW,
                  size: 36.0,
                ),
                text: Text(
                  "wikipedia",
                  style: Utilities.fonts.style(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
