import 'package:artbooking/components/cards/data_fetch_mode_card.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/enums/enum_data_ui_shape.dart';
import 'package:artbooking/types/enums/enum_section_data_mode.dart';
import 'package:artbooking/types/tile_data.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class EditSectionDataFetchModes extends StatelessWidget {
  const EditSectionDataFetchModes({
    Key? key,
    required this.dataModes,
    this.onValueChanged,
    this.margin = EdgeInsets.zero,
    this.editMode = false,
  }) : super(key: key);

  /// Values will be editable if true.
  final bool editMode;

  /// External padding (blank space around this widget).
  final EdgeInsets margin;

  /// Selected section's data fetch modes.
  final List<EnumSectionDataMode> dataModes;

  /// Callback event fired when this section's fetch modes are updated.
  final void Function(EnumSectionDataMode mode, bool selected)? onValueChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 8.0,
              top: 16.0,
              bottom: 16.0,
            ),
            child: Opacity(
              opacity: 0.6,
              child: Text(
                "section_data_fetch_modes".tr().toUpperCase(),
                style: Utilities.fonts.body3(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Wrap(
            spacing: 12.0,
            runSpacing: 12.0,
            children: getModes(),
          ),
        ],
      ),
    );
  }

  List<Widget> getModes() {
    if (editMode) {
      return getAllModes();
    }

    return getSectionModes();
  }

  List<Widget> getSectionModes() {
    return dataModes.map((EnumSectionDataMode dataMode) {
      return TileData<EnumSectionDataMode>(
        name: "data_fetch_mode_title.${dataMode.name}".tr(),
        description: "data_fetch_mode_description.${dataMode.name}".tr(),
        iconData: Utilities.ui.getDataFetchModeIconData(dataMode),
        type: dataMode,
      );
    }).map(
      (TileData<EnumSectionDataMode> data) {
        return DataFetchModeCard(
          data: data,
          shape: EnumDataUIShape.chip,
          onTap: editMode ? onValueChanged : null,
        );
      },
    ).toList();
  }

  List<Widget> getAllModes() {
    return [EnumSectionDataMode.chosen, EnumSectionDataMode.sync]
        .map((EnumSectionDataMode dataMode) {
      return TileData<EnumSectionDataMode>(
        name: "data_fetch_mode_title.${dataMode.name}".tr(),
        description: "data_fetch_mode_description.${dataMode.name}".tr(),
        iconData: Utilities.ui.getDataFetchModeIconData(dataMode),
        type: dataMode,
      );
    }).map(
      (TileData<EnumSectionDataMode> data) {
        return DataFetchModeCard(
          data: data,
          shape: EnumDataUIShape.chip,
          selected: dataModes.contains(data.type),
          onTap: editMode ? onValueChanged : null,
        );
      },
    ).toList();
  }
}
