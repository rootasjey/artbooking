import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/enums/enum_section_data_mode.dart';
import 'package:artbooking/types/tile_data.dart';
import 'package:flutter/material.dart';

class DataFetchModeCard extends StatelessWidget {
  const DataFetchModeCard({
    Key? key,
    required this.data,
    this.selected = false,
    this.onTap,
  }) : super(key: key);

  final bool selected;
  final TileData<EnumSectionDataMode> data;
  final void Function(EnumSectionDataMode mode, bool selected)? onTap;

  @override
  Widget build(BuildContext context) {
    double opacity = 1.0;
    if (onTap != null) {
      opacity = selected ? 1.0 : 0.6;
    }

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
                      style: Utilities.fonts.style(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Opacity(
                    opacity: 0.4,
                    child: Text(
                      data.description,
                      style: Utilities.fonts.style(
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
}
