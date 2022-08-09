import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/license/license.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';
import 'package:url_launcher/url_launcher.dart';

class SelectLicensePanelMoreInfo extends StatelessWidget {
  const SelectLicensePanelMoreInfo({
    Key? key,
    required this.license,
    this.margin = EdgeInsets.zero,
    this.onBack,
  }) : super(key: key);

  /// Spacing around this widget.
  final EdgeInsets margin;

  /// Callback fired to navigate back.
  final Function()? onBack;

  /// Selected license to show info about.
  final License license;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    tooltip: "back".tr(),
                    onPressed: onBack,
                    icon: Opacity(
                      opacity: 0.6,
                      child: Icon(UniconsLine.arrow_left),
                    ),
                  ),
                  Expanded(
                    child: Opacity(
                      opacity: 0.8,
                      child: Text(
                        license.name.toUpperCase(),
                        style: Utilities.fonts.body(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Opacity(
                opacity: 0.6,
                child: Text(
                  license.description,
                  style: Utilities.fonts.body(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            linksPreview(),
          ],
        ),
      ),
    );
  }

  Widget linksPreview() {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, left: 24.0),
      child: Wrap(
        spacing: 12.0,
        runSpacing: 12.0,
        children: [
          if (license.links.wikipedia.isNotEmpty)
            OutlinedButton(
              onPressed: () => launchUrl(Uri.parse(license.links.wikipedia)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("wikipedia"),
              ),
              style: OutlinedButton.styleFrom(
                primary: Colors.black54,
              ),
            ),
          if (license.links.website.isNotEmpty)
            OutlinedButton(
              onPressed: () => launchUrl(Uri.parse(license.links.website)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("website"),
              ),
              style: OutlinedButton.styleFrom(
                primary: Colors.black54,
              ),
            ),
        ],
      ),
    );
  }
}
