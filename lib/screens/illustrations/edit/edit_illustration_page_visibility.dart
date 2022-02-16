import 'package:artbooking/components/buttons/visibility_button.dart';
import 'package:artbooking/components/expansion_tile_card/expansion_tile_card_description.dart';
import 'package:artbooking/components/expansion_tile_card/expansion_tile_card_title.dart';
import 'package:artbooking/types/enums/enum_content_visibility.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';

class EditIllustrationPageVisibility extends StatelessWidget {
  const EditIllustrationPageVisibility({
    Key? key,
    this.onUpdateVisibility,
    required this.visibility,
  }) : super(key: key);

  final void Function(EnumContentVisibility)? onUpdateVisibility;
  final EnumContentVisibility visibility;

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
            child: VisibilityButton(
              visibility: visibility,
              onChangedVisibility: onUpdateVisibility,
              padding: const EdgeInsets.only(top: 12.0, left: 16.0),
            ),
          ),
        ],
      ),
    );
  }
}
