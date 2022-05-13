import 'package:artbooking/components/buttons/dark_elevated_button.dart';
import 'package:artbooking/components/expansion_tile_card/expansion_tile_card_description.dart';
import 'package:artbooking/components/expansion_tile_card/expansion_tile_card_title.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';

class EditIllustrationPageArtMovements extends StatelessWidget {
  const EditIllustrationPageArtMovements({
    Key? key,
    required this.selectedArtMovements,
    required this.showArtMovementPanel,
    this.onRemoveArtMovementAndUpdate,
    this.onToggleArtMovementPanel,
  }) : super(key: key);

  final List<String> selectedArtMovements;
  final bool showArtMovementPanel;
  final void Function()? onToggleArtMovementPanel;
  final void Function(String)? onRemoveArtMovementAndUpdate;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 600.0,
      padding: const EdgeInsets.only(top: 100.0),
      child: ExpansionTileCard(
        elevation: 0.0,
        expandedTextColor: Colors.black,
        baseColor: Theme.of(context).backgroundColor,
        expandedColor: Theme.of(context).backgroundColor,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExpansionTileCardTitle(
              textValue: "art_movements".tr(),
            ),
            ExpansionTileCardDescription(
              textValue: "art_movements_description".tr(),
            ),
          ],
        ),
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Wrap(
                  spacing: 12.0,
                  runSpacing: 12.0,
                  children: selectedArtMovements.map((artMovement) {
                    return InputChip(
                      label: Opacity(
                        opacity: 0.8,
                        child: Text(artMovement),
                      ),
                      labelStyle:
                          Utilities.fonts.body(fontWeight: FontWeight.w700),
                      elevation: 2.0,
                      deleteIconColor: Theme.of(context)
                          .secondaryHeaderColor
                          .withOpacity(0.8),
                      labelPadding:
                          const EdgeInsets.symmetric(horizontal: 12.0),
                      onDeleted: () {
                        onRemoveArtMovementAndUpdate?.call(artMovement);
                      },
                      onSelected: (isSelected) {},
                    );
                  }).toList()),
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
                onPressed: onToggleArtMovementPanel,
                child: Text(
                  showArtMovementPanel
                      ? "art_movement_hide_panel".tr()
                      : "art_movement_add".tr(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
