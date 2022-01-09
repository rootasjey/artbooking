import 'package:beamer/beamer.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:artbooking/components/app_icon.dart';
import 'package:artbooking/components/footer/company_watermark.dart';
import 'package:artbooking/components/footer/footer_link.dart';
import 'package:artbooking/components/footer/footer_section.dart';
import 'package:artbooking/router/locations/tos_location.dart';
import 'package:artbooking/types/footer_link_data.dart';

class LegalSection extends StatelessWidget {
  const LegalSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppIcon(size: 30.0),
              CompanyWatermark(),
            ],
          ),
        ),
        FooterSection(
          children: getItems(context).map(
            (item) {
              return FooterLink(
                label: item.label,
                heroTag: item.heroTag,
                onPressed: item.onPressed,
              );
            },
          ).toList(),
        ),
      ],
    );
  }

  List<FooterLinkData> getItems(BuildContext context) {
    return [
      FooterLinkData(
        label: "tos".tr(),
        heroTag: "tos_hero",
        onPressed: () {
          Beamer.of(context).beamToNamed(TosLocation.route);
        },
      ),
      FooterLinkData(
        label: "privacy".tr(),
        onPressed: () => Beamer.of(context).beamToNamed(TosLocation.route),
      ),
    ];
  }
}
