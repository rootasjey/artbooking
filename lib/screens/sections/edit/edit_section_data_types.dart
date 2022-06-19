import 'package:artbooking/components/cards/data_type_card.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/enums/enum_data_ui_shape.dart';
import 'package:artbooking/types/enums/enum_section_data_type.dart';
import 'package:artbooking/types/tile_data.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class EditSectionDataTypes extends StatelessWidget {
  const EditSectionDataTypes({
    Key? key,
    required this.dataTypes,
    this.onValueChanged,
    this.margin = EdgeInsets.zero,
    this.editMode = false,
  }) : super(key: key);

  /// Values will be editable if true.
  final bool editMode;

  /// External padding (blank space around this widget).
  final EdgeInsets margin;

  /// Selected section's data types.
  final List<EnumSectionDataType> dataTypes;

  /// Callback event fired when this section's data types are updated.
  final void Function(
    EnumSectionDataType type,
    bool selected,
  )? onValueChanged;

  @override
  Widget build(BuildContext context) {
    if (dataTypes.isEmpty) {
      return Container();
    }

    return Padding(
      padding: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 4.0,
              bottom: 12.0,
            ),
            child: Opacity(
              opacity: 0.6,
              child: Text(
                "section_data_types".tr().toUpperCase(),
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
            children: getTypes(),
          ),
        ],
      ),
    );
  }

  List<Widget> getTypes() {
    if (editMode) {
      return getAllAvailableTypes();
    }

    return getSectionTypes();
  }

  List<Widget> getSectionTypes() {
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
          shape: EnumDataUIShape.chip,
        );
      },
    ).toList();
  }

  List<Widget> getAllAvailableTypes() {
    return [
      EnumSectionDataType.books,
      EnumSectionDataType.illustrations,
      EnumSectionDataType.text,
      EnumSectionDataType.user
    ].map((EnumSectionDataType dataType) {
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
          shape: EnumDataUIShape.chip,
          selected: dataTypes.contains(data.type),
          onTap: onValueChanged,
        );
      },
    ).toList();
  }
}
