import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:artbooking/components/footer/footer_link.dart';
import 'package:artbooking/components/footer/footer_section.dart';
import 'package:artbooking/types/footer_link_data.dart';

class FooterArtworks extends StatelessWidget {
  const FooterArtworks({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FooterSection(
      titleValue: "artworks".tr().toUpperCase(),
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
        label: "illustrations".tr(),
        onPressed: () {},
      ),
      FooterLinkData(
        label: "books".tr(),
        onPressed: () {},
      ),
      FooterLinkData(
        label: "challenges".tr(),
        onPressed: () {},
      ),
    ];
  }
}
