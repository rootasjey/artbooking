import 'package:artbooking/components/expansion_tile_card/expansion_tile_card_description.dart';
import 'package:artbooking/components/expansion_tile_card/expansion_tile_card_title.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/enums/enum_content_visibility.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';

class EditIllustrationPageVisibility extends StatelessWidget {
  const EditIllustrationPageVisibility({
    Key? key,
    this.onUpdateVisibility,
    required this.visibilityValue,
  }) : super(key: key);

  final void Function(EnumContentVisibility)? onUpdateVisibility;
  final String visibilityValue;

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
        title: Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ExpansionTileCardTitle(
                textValue: "visibility".tr(),
              ),
              ExpansionTileCardDescription(
                textValue: "illustration_visibility_description".tr(),
              ),
            ],
          ),
        ),
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(top: 12.0, left: 16.0),
              child: PopupMenuButton(
                tooltip: "illustration_visibility_choose".tr(),
                child: Material(
                  color: Colors.black87,
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: 200.0,
                      minHeight: 48.0,
                    ),
                    child: Center(
                      child: Text(
                        // "visibility_${illustration.visibilityToString()}"
                        "visibility_${visibilityValue}".tr().toUpperCase(),
                        style: Utilities.fonts.style(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                onSelected: onUpdateVisibility,
                itemBuilder: (context) =>
                    <PopupMenuEntry<EnumContentVisibility>>[
                  visibiltyPopupItem(
                    value: EnumContentVisibility.private,
                    titleValue: "visibility_private".tr(),
                    subtitleValue: "visibility_private_description".tr(),
                  ),
                  visibiltyPopupItem(
                    value: EnumContentVisibility.public,
                    titleValue: "visibility_public".tr(),
                    subtitleValue: "visibility_public_description".tr(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<EnumContentVisibility> visibiltyPopupItem({
    required EnumContentVisibility value,
    required String titleValue,
    required String subtitleValue,
  }) {
    return PopupMenuItem(
      value: value,
      child: ListTile(
        title: Text(
          titleValue,
          style: Utilities.fonts.style(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitleValue,
          style: Utilities.fonts.style(
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
