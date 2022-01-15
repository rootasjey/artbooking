import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/screens/licenses/square_link.dart';
import 'package:artbooking/types/illustration/license_urls.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:unicons/unicons.dart';
import 'package:url_launcher/url_launcher.dart';

class LicenseUrlSection extends StatelessWidget {
  const LicenseUrlSection({
    Key? key,
    required this.urls,
  }) : super(key: key);

  final LicenseUrls urls;

  @override
  Widget build(BuildContext context) {
    if (urls.website.isEmpty && urls.wikipedia.isEmpty) {
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
            if (urls.website.isNotEmpty)
              SquareLink(
                onTap: () => launch(urls.website),
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
            if (urls.wikipedia.isNotEmpty)
              SquareLink(
                onTap: () => launch(urls.wikipedia),
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
