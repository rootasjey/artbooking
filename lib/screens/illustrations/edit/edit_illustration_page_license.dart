import 'package:artbooking/components/buttons/dark_elevated_button.dart';
import 'package:artbooking/components/expansion_tile_card/expansion_tile_card_description.dart';
import 'package:artbooking/components/expansion_tile_card/expansion_tile_card_title.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/license/license.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class EditIllustrationPageLicense extends StatelessWidget {
  const EditIllustrationPageLicense({
    Key? key,
    required this.showLicensesPanel,
    required this.license,
    this.onTapCurrentLicense,
    this.onUnselectLicenseAndUpdate,
    this.onExpandStateLicenseChanged,
    this.onToggleLicensePanel,
  }) : super(key: key);

  final bool showLicensesPanel;
  final License license;
  final void Function()? onTapCurrentLicense;
  final void Function()? onToggleLicensePanel;
  final void Function()? onUnselectLicenseAndUpdate;
  final void Function(bool)? onExpandStateLicenseChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 600.0,
      padding: const EdgeInsets.only(
        top: 100.0,
      ),
      child: ExpansionTileCard(
        elevation: 0.0,
        expandedTextColor: Colors.black,
        baseColor: Theme.of(context).backgroundColor,
        expandedColor: Theme.of(context).backgroundColor,
        onExpansionChanged: onExpandStateLicenseChanged,
        title: Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ExpansionTileCardTitle(
                textValue: "license".tr(),
              ),
              ExpansionTileCardDescription(
                textValue: "illustration_license_description".tr(),
              ),
            ],
          ),
        ),
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              width: 400.0,
              padding: const EdgeInsets.only(
                top: 24.0,
                left: 12.0,
                bottom: 12.0,
              ),
              child: Card(
                elevation: 2.0,
                child: InkWell(
                  onTap: onTapCurrentLicense,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Opacity(
                              opacity: 0.6,
                              child: Text(
                                "license_current".tr().toUpperCase(),
                                style: Utilities.fonts.body(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            Opacity(
                              opacity: 0.8,
                              child: Text(
                                license.name.isEmpty
                                    ? "license_none".tr()
                                    : license.name,
                                style: Utilities.fonts.body(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        license.name.isEmpty
                            ? Container()
                            : Opacity(
                                opacity: 0.8,
                                child: IconButton(
                                  tooltip: "license_current_remove".tr(),
                                  onPressed: onUnselectLicenseAndUpdate,
                                  icon: Icon(UniconsLine.trash),
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(
                top: 24.0,
                left: 16.0,
              ),
              child: DarkElevatedButton.large(
                onPressed: onToggleLicensePanel,
                // onPressed: () {
                //   setState(() {
                //     _showLicensesPanel = !_showLicensesPanel;
                //   });
                // },
                child: Text(
                  showLicensesPanel
                      ? "license_hide_panel".tr()
                      : "license_select".tr(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
