import 'package:artbooking/components/cards/data_fetch_mode_card.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/enums/enum_section_data_mode.dart';
import 'package:artbooking/types/tile_data.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class SectionPageDataFetchModes extends StatelessWidget {
  const SectionPageDataFetchModes({
    Key? key,
    required this.dataModes,
    this.padding = EdgeInsets.zero,
  }) : super(key: key);

  final List<EnumSectionDataMode> dataModes;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: Opacity(
              opacity: 0.6,
              child: Text(
                "section_data_fetch_modes".tr(),
                style: Utilities.fonts.style(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 300.0,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: getChildren(),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> getChildren() {
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
        );
      },
    ).toList();
  }
}
