import 'package:artbooking/components/cards/data_type_card.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/enums/enum_section_data_type.dart';
import 'package:artbooking/types/tile_data.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class SectionPageDataTypes extends StatelessWidget {
  const SectionPageDataTypes({
    Key? key,
    required this.dataTypes,
    this.padding = EdgeInsets.zero,
  }) : super(key: key);

  final List<EnumSectionDataType> dataTypes;
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
                "section_data_types".tr(),
                style: Utilities.fonts.style(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 200.0,
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
    return dataTypes.map((EnumSectionDataType dataType) {
      return TileData<EnumSectionDataType>(
        name: dataType.name.tr(),
        description: "data_type_description.${dataType.name}".tr(),
        iconData: Utilities.ui.getDataTypeIcon(dataType),
        type: dataType,
      );
    }).map(
      (TileData<EnumSectionDataType> data) {
        return DataTypeCard(
          data: data,
        );
      },
    ).toList();
  }
}
