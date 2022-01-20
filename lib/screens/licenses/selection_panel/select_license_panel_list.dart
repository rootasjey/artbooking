import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/license/license.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class SelectLicensePanelList extends StatelessWidget {
  const SelectLicensePanelList({
    Key? key,
    required this.licenses,
    required this.selectedLicenseId,
    this.toggleLicenseAndUpdate,
    this.onShowLicensePreview,
  }) : super(key: key);

  final Function(License, bool)? toggleLicenseAndUpdate;
  final Function(License)? onShowLicensePreview;
  final List<License> licenses;
  final String selectedLicenseId;

  @override
  Widget build(BuildContext context) {
    if (licenses.isEmpty) {
      return SliverPadding(
        padding: const EdgeInsets.all(24.0),
        sliver: SliverList(
          delegate: SliverChildListDelegate.fixed([
            Opacity(
              opacity: 0.6,
              child: Icon(
                UniconsLine.no_entry,
                size: 80.0,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Opacity(
                opacity: 0.6,
                child: Text(
                  "license_search_result_empty".tr(),
                  textAlign: TextAlign.center,
                  style: Utilities.fonts.style(
                    fontSize: 24.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ]),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(8.0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final currentLicense = licenses.elementAt(index);
            final selected = selectedLicenseId == currentLicense.id;

            return ListTile(
              onLongPress: () => onShowLicensePreview?.call(currentLicense),
              onTap: () => toggleLicenseAndUpdate?.call(
                currentLicense,
                selected,
              ),
              title: Opacity(
                opacity: 0.8,
                child: Row(
                  children: [
                    if (selected)
                      Icon(
                        UniconsLine.check,
                        color: selected
                            ? Theme.of(context).secondaryHeaderColor
                            : null,
                      ),
                    Expanded(
                      child: Text(
                        currentLicense.name.toUpperCase(),
                        style: Utilities.fonts.style(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w700,
                          color: selected
                              ? Theme.of(context).secondaryHeaderColor
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              subtitle: Text(
                currentLicense.description,
                style: Utilities.fonts.style(
                  fontWeight: FontWeight.w600,
                ),
              ),
              contentPadding: const EdgeInsets.all(16.0),
            );
          },
          childCount: licenses.length,
        ),
      ),
    );
  }
}
