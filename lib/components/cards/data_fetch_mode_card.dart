import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/enums/enum_data_ui_shape.dart';
import 'package:artbooking/types/enums/enum_section_data_mode.dart';
import 'package:artbooking/types/tile_data.dart';
import 'package:flutter/material.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';

class DataFetchModeCard extends StatelessWidget {
  const DataFetchModeCard({
    Key? key,
    required this.data,
    this.selected = false,
    this.onTap,
    this.shape = EnumDataUIShape.chip,
  }) : super(key: key);

  /// Will be highlited if true.
  final bool selected;

  /// The visual aspect of this widget.
  final EnumDataUIShape shape;

  /// Main data.
  final TileData<EnumSectionDataMode> data;

  /// Callback fired when this widget is tapped.
  final void Function(EnumSectionDataMode mode, bool selected)? onTap;

  @override
  Widget build(BuildContext context) {
    double opacity = 1.0;
    if (onTap != null) {
      opacity = selected ? 1.0 : 0.6;
    }

    if (shape == EnumDataUIShape.card) {
      return cardWiget(
        context,
        opacity: opacity,
      );
    }

    return chipWidget(
      context,
      opacity: opacity,
    );
  }

  Widget cardWiget(
    BuildContext context, {
    double opacity = 1.0,
  }) {
    return Opacity(
      opacity: opacity,
      child: Container(
        height: 300.0,
        width: 280.0,
        margin: EdgeInsets.only(right: 12.0),
        child: Card(
          elevation: onTap != null ? 4.0 : 0.0,
          color: Constants.colors.clairPink,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
            side: selected
                ? BorderSide(color: Theme.of(context).primaryColor, width: 2.0)
                : BorderSide.none,
          ),
          child: InkWell(
            onTap: onTap != null
                ? () => onTap?.call(
                      data.type,
                      !selected,
                    )
                : null,
            child: Container(
              width: 200.0,
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Opacity(
                    opacity: 0.8,
                    child: Icon(
                      data.iconData,
                      size: 36,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      data.name,
                      style: Utilities.fonts.body(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Opacity(
                    opacity: 0.4,
                    child: Text(
                      data.description,
                      style: Utilities.fonts.body(
                        fontSize: 14.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget chipWidget(
    BuildContext context, {
    double opacity = 1.0,
  }) {
    if (onTap == null) {
      return Chip(
        avatar: Icon(
          data.iconData,
          size: 16.0,
          color: Colors.black38,
        ),
        label: Text(
          data.name,
          style: Utilities.fonts.body(),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 12.0,
          vertical: 8.0,
        ),
      );
    }

    return JustTheTooltip(
      tailBaseWidth: 20.0,
      tailLength: 12.0,
      backgroundColor: Constants.colors.tertiary,
      content: Container(
        constraints: BoxConstraints(maxWidth: 500.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: selected ? Constants.colors.tertiary : Colors.white,
          borderRadius: BorderRadius.circular(4.0),
          border: Border.all(
            color: Constants.colors.tertiary,
            width: 2.0,
          ),
        ),
        child: Text(
          data.description,
          style: Utilities.fonts.body(
            fontSize: 14.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      child: ChoiceChip(
        avatar: Icon(
          data.iconData,
          size: 16.0,
          color: Colors.black38,
        ),
        label: Text(
          data.name,
          style: Utilities.fonts.body(),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 12.0,
          vertical: 8.0,
        ),
        selected: selected,
        selectedColor: Constants.colors.tertiary,
        onSelected: (active) {
          onTap?.call(
            data.type,
            !selected,
          );
        },
      ),
    );
  }
}
