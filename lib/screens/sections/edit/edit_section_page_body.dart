import 'package:artbooking/components/buttons/dark_elevated_button.dart';
import 'package:artbooking/components/loading_view.dart';
import 'package:artbooking/components/edit_title_description.dart';
import 'package:artbooking/screens/sections/edit/color_card_picker.dart';
import 'package:artbooking/screens/sections/edit/edit_section_data_fetch_modes.dart';
import 'package:artbooking/screens/sections/edit/edit_section_data_types.dart';
import 'package:artbooking/screens/sections/edit/edit_section_header_separator.dart';
import 'package:artbooking/types/enums/enum_header_separator_tab.dart';
import 'package:artbooking/types/enums/enum_section_data_mode.dart';
import 'package:artbooking/types/enums/enum_section_data_type.dart';
import 'package:artbooking/types/named_color.dart';
import 'package:artbooking/types/section.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';

class EditSectionPageBody extends StatelessWidget {
  const EditSectionPageBody({
    Key? key,
    required this.loading,
    required this.saving,
    required this.isNew,
    required this.section,
    this.onBackgroundColorChanged,
    this.onValidate,
    this.onTitleChanged,
    this.onDescriptionChanged,
    this.onDataFetchModesChanged,
    this.onDataTypesChanged,
    this.onShowHeaderSeparatorDialog,
    this.onTextColorChanged,
  }) : super(key: key);

  final bool loading;
  final bool saving;

  /// True if we create a new section. It's an update therwise.
  final bool isNew;

  final Section section;

  final void Function(NamedColor)? onBackgroundColorChanged;
  final void Function(NamedColor)? onTextColorChanged;
  final void Function(
    EnumSectionDataMode mode,
    bool selected,
  )? onDataFetchModesChanged;

  final void Function(
    EnumSectionDataType dataType,
    bool selected,
  )? onDataTypesChanged;

  final void Function()? onValidate;
  final void Function(String)? onTitleChanged;
  final void Function(String)? onDescriptionChanged;
  final void Function(
    EnumHeaderSeparatorTab initialTab,
  )? onShowHeaderSeparatorDialog;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return LoadingView(
        sliver: false,
        title: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Opacity(
            opacity: 0.6,
            child: Text("loading".tr()),
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(top: 90.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EditTitleDescription(
            initialDescription: section.description,
            initialName: section.name,
            onTitleChanged: onTitleChanged,
            onDescriptionChanged: onDescriptionChanged,
          ),
          Wrap(
            children: [
              ColorCardPicker(
                name: "background_color_default".tr(),
                dialogTextTitle: "background_color_update".tr(),
                dialogTextSubtitle: "section_background_color_choose".tr(),
                backgroundColor: section.backgroundColor,
                onValueChanged: onBackgroundColorChanged,
                padding: const EdgeInsets.only(top: 42.0, left: 6.0),
              ),
              ColorCardPicker(
                dialogTextTitle: "text_color_update".tr(),
                dialogTextSubtitle: "text_color_choose".tr(),
                name: "text_color_default".tr(),
                backgroundColor: section.textColor,
                onValueChanged: onTextColorChanged,
                padding: const EdgeInsets.only(top: 42.0, left: 6.0),
              ),
            ],
          ),
          EditSectionDataFetchModes(
            dataModes: section.dataFetchModes,
            onValueChanged: onDataFetchModesChanged,
            padding: const EdgeInsets.only(top: 24.0),
          ),
          EditSectionDataTypes(
            dataTypes: section.dataTypes,
            onValueChanged: onDataTypesChanged,
            padding: const EdgeInsets.only(top: 24.0),
          ),
          EditSectionHeaderSeparator(
            headerSeparator: section.headerSeparator,
            padding: const EdgeInsets.only(top: 24.0),
            onShowHeaderSeparatorDialog: onShowHeaderSeparatorDialog,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 80.0),
            child: DarkElevatedButton.large(
              onPressed: saving ? null : onValidate,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 64.0),
                child: Text(
                  isNew ? "create".tr() : "update".tr(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
