import 'package:artbooking/components/buttons/dark_elevated_button.dart';
import 'package:artbooking/components/expansion_tile_card/expansion_tile_card_description.dart';
import 'package:artbooking/components/expansion_tile_card/expansion_tile_card_title.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';

class EditIllustrationPageStyles extends StatelessWidget {
  const EditIllustrationPageStyles({
    Key? key,
    required this.selectedStyles,
    required this.showStylesPanel,
    this.onRemoveStyleAndUpdate,
    this.onToggleStylesPanel,
  }) : super(key: key);

  final List<String> selectedStyles;
  final bool showStylesPanel;
  final void Function()? onToggleStylesPanel;
  final void Function(String)? onRemoveStyleAndUpdate;

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
              textValue: "styles".tr(),
            ),
            ExpansionTileCardDescription(
              textValue: "styles_description".tr(),
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
                  children: selectedStyles.map((style) {
                    return InputChip(
                      label: Opacity(
                        opacity: 0.8,
                        child: Text(style),
                      ),
                      labelStyle:
                          Utilities.fonts.style(fontWeight: FontWeight.w700),
                      elevation: 2.0,
                      deleteIconColor: Theme.of(context)
                          .secondaryHeaderColor
                          .withOpacity(0.8),
                      labelPadding:
                          const EdgeInsets.symmetric(horizontal: 12.0),
                      onDeleted: () {
                        onRemoveStyleAndUpdate?.call(style);
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
                // onPressed: () {
                //   setState(() {
                //     _isSidePanelStylesVisible = !_isSidePanelStylesVisible;
                //   });
                // },
                onPressed: onToggleStylesPanel,
                child: Text(
                  showStylesPanel ? "style_hide_panel".tr() : "style_add".tr(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
