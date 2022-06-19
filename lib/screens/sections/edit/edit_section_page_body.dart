import 'package:artbooking/components/loading_view.dart';
import 'package:artbooking/components/edit_title_description.dart';
import 'package:artbooking/screens/sections/edit/edit_section_colors.dart';
import 'package:artbooking/screens/sections/edit/edit_section_data_fetch_modes.dart';
import 'package:artbooking/screens/sections/edit/edit_section_data_types.dart';
import 'package:artbooking/screens/sections/edit/edit_section_header_separator.dart';
import 'package:artbooking/screens/sections/edit/edit_section_visibility.dart';
import 'package:artbooking/types/enums/enum_header_separator_tab.dart';
import 'package:artbooking/types/enums/enum_section_data_mode.dart';
import 'package:artbooking/types/enums/enum_section_data_type.dart';
import 'package:artbooking/types/enums/enum_section_visibility.dart';
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
    this.onVisibilityChanged,
  }) : super(key: key);

  /// Fetching network data if true.
  final bool loading;

  /// Saving local data to network if true.
  final bool saving;

  /// True if we create a new section. It's an update therwise.
  final bool isNew;

  /// Main page data.
  final Section section;

  /// Callback event fired when this section's background has been updated.
  final void Function(NamedColor)? onBackgroundColorChanged;

  /// Callback event fired when this section's text color has been updated.
  final void Function(NamedColor)? onTextColorChanged;

  /// Callback event fired when this section's fetch modes has been updated.
  final void Function(
    EnumSectionDataMode mode,
    bool selected,
  )? onDataFetchModesChanged;

  /// Callback event fired when this section's data type has been updated.
  final void Function(
    EnumSectionDataType dataType,
    bool selected,
  )? onDataTypesChanged;

  /// Callback event fired when this section's visibility (public/staff)
  /// has been updated.
  final void Function(
    EnumSectionVisibility visibility,
  )? onVisibilityChanged;

  /// Callback event fired when we want to save pending changes.
  final void Function()? onValidate;

  /// Callback event fired when this section's title has been updated.
  final void Function(String)? onTitleChanged;

  /// Callback event fired when this section's description has been updated.
  final void Function(String)? onDescriptionChanged;

  /// Callback event fired when we want to updated header separator.
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
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.start,
        children: [
          SizedBox(
            width: 500.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EditTitleDescription(
                  initialDescription: section.description,
                  initialName: section.name,
                  titleHintText: "title_enter".tr(),
                  descriptionHintText: "description_enter".tr(),
                  onTitleChanged: onTitleChanged,
                  onDescriptionChanged: onDescriptionChanged,
                ),
                EditSectionVisibility(
                  visibility: section.visibility,
                  onValueChanged: onVisibilityChanged,
                  margin: const EdgeInsets.only(left: 12.0, top: 42.0),
                ),
                EditSectionColors(
                  section: section,
                  onBackgroundColorChanged: onBackgroundColorChanged,
                  onTextColorChanged: onTextColorChanged,
                  margin: const EdgeInsets.only(left: 6.0, top: 24.0),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 500.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EditSectionDataFetchModes(
                  editMode: true,
                  dataModes: section.dataFetchModes,
                  onValueChanged: onDataFetchModesChanged,
                ),
                EditSectionDataTypes(
                  editMode: true,
                  dataTypes: section.dataTypes,
                  onValueChanged: onDataTypesChanged,
                  margin: const EdgeInsets.only(top: 42.0),
                ),
                EditSectionHeaderSeparator(
                  editMode: true,
                  headerSeparator: section.headerSeparator,
                  margin: const EdgeInsets.only(top: 42.0),
                  onShowHeaderSeparatorDialog: onShowHeaderSeparatorDialog,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
