import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/license/license.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';
import 'package:url_launcher/url_launcher.dart';

class SelectLicensePanelPreview extends StatelessWidget {
  const SelectLicensePanelPreview({
    Key? key,
    required this.selectedLicensePreview,
    this.onBack,
  }) : super(key: key);

  final License selectedLicensePreview;
  final Function()? onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 140.0,
        bottom: 12.0,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 40.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    tooltip: "back".tr(),
                    onPressed: onBack,
                    icon: Icon(UniconsLine.arrow_left),
                  ),
                  Expanded(
                    child: Opacity(
                      opacity: 0.8,
                      child: Text(
                        selectedLicensePreview.name.toUpperCase(),
                        style: Utilities.fonts.style(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Opacity(
                opacity: 0.6,
                child: Text(
                  selectedLicensePreview.description,
                  style: Utilities.fonts.style(
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
      padding: const EdgeInsets.only(left: 24.0),
      child: Wrap(
        spacing: 12.0,
        runSpacing: 12.0,
        children: [
          if (selectedLicensePreview.urls.wikipedia.isNotEmpty)
            OutlinedButton(
              onPressed: () => launch(selectedLicensePreview.urls.wikipedia),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("wikipedia"),
              ),
              style: OutlinedButton.styleFrom(
                primary: Colors.black54,
              ),
            ),
          if (selectedLicensePreview.urls.website.isNotEmpty)
            OutlinedButton(
              onPressed: () => launch(selectedLicensePreview.urls.website),
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
