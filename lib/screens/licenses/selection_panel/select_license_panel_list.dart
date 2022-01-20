import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/license/license.dart';
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

  final List<License> licenses;
  final String selectedLicenseId;
  final Function(License, bool)? toggleLicenseAndUpdate;
  final Function()? onShowLicensePreview;

  @override
  Widget build(BuildContext context) {
    if (licenses.isEmpty) {
      return SliverList(
        delegate: SliverChildListDelegate.fixed([
          Text("There is no license for your search."),
        ]),
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
              onTap: () => toggleLicenseAndUpdate?.call(
                currentLicense,
                selected,
              ),
              onLongPress: onShowLicensePreview,
              // onLongPress: () {
              //   setState(() {
              //     _selectedLicensePreview = currentLicense;
              //     _showLicenseInfo = true;
              //   });
              // },
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
