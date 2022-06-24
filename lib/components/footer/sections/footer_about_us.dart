import 'package:beamer/beamer.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:artbooking/components/footer/footer_link.dart';
import 'package:artbooking/components/footer/footer_column.dart';
import 'package:artbooking/router/locations/about_location.dart';
import 'package:artbooking/router/locations/contact_location.dart';
import 'package:artbooking/types/footer_link_data.dart';
import 'package:url_launcher/url_launcher.dart';

class FooterAboutUs extends StatelessWidget {
  const FooterAboutUs({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FooterColumn(
      titleValue: "about".tr().toUpperCase(),
      children: getItems(context).map(
        (item) {
          return FooterLink(
            label: item.label,
            onPressed: item.onPressed,
          );
        },
      ).toList(),
    );
  }

  List<FooterLinkData> getItems(BuildContext context) {
    return [
      FooterLinkData(
        label: "about_us".tr(),
        onPressed: () => Beamer.of(context).beamToNamed(AboutLocation.route),
      ),
      FooterLinkData(
        label: "contact_us".tr(),
        onPressed: () => Beamer.of(context).beamToNamed(ContactLocation.route),
      ),
      FooterLinkData(
        label: "GitHub",
        onPressed: () =>
            launchUrl(Uri.parse("https://github.com/rootasjey/rootasjey.dev")),
      ),
    ];
  }
}
