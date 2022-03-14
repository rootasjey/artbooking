import 'package:artbooking/components/dialogs/header_separator_dialog.dart';
import 'package:artbooking/components/edit_item_sheet_header.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/screens/sections/edit/edit_section_page_body.dart';
import 'package:artbooking/types/enums/enum_header_separator_tab.dart';
import 'package:artbooking/types/enums/enum_section_data_mode.dart';
import 'package:artbooking/types/enums/enum_section_data_type.dart';
import 'package:artbooking/types/header_separator.dart';
import 'package:artbooking/types/named_color.dart';
import 'package:artbooking/types/section.dart';
import 'package:beamer/beamer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class EditSectionPage extends StatefulWidget {
  const EditSectionPage({
    Key? key,
    required this.section,
  }) : super(key: key);

  final Section section;

  @override
  State<EditSectionPage> createState() => _EditSectionPageState();
}

class _EditSectionPageState extends State<EditSectionPage> {
  bool _loading = false;
  bool _saving = false;

  var _section = Section.empty();

  @override
  void initState() {
    super.initState();
    _section = widget.section.copyWith();
  }

  @override
  void dispose() {
    _section = Section.empty();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: tryCreateOrUpdateSection,
        child: Icon(UniconsLine.check),
        backgroundColor: Theme.of(context).secondaryHeaderColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(60.0),
          child: Column(
            children: [
              EditItemSheetHeader(
                itemId: _section.id,
                itemName: _section.name,
                subtitleCreate: "section_create".tr(),
                subtitleEdit: "section_edit_existing".tr(),
              ),
              EditSectionPageBody(
                section: _section,
                loading: _loading,
                saving: _saving,
                isNew: widget.section.id.isEmpty,
                onValidate: tryCreateOrUpdateSection,
                onBackgroundColorChanged: onBackgroundColorChanged,
                onTextColorChanged: onTextColorChanged,
                onDescriptionChanged: onDescriptionChanged,
                onTitleChanged: onTitleChanged,
                onDataFetchModesChanged: onDataFetchModesChanged,
                onDataTypesChanged: onDataTypesChanged,
                onShowHeaderSeparatorDialog: onShowHeaderSeparatorDialog,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void onShowHeaderSeparatorDialog(EnumHeaderSeparatorTab initialTab) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return HeaderSeparatorDialog(
          initialTab: initialTab,
          headerSeparator: _section.headerSeparator,
          onValidate: onHeaderSeparatorChanged,
        );
      },
    );
  }

  void tryCreateOrUpdateSection() async {
    try {
      final map = _section.toMap(withId: false);
      map["updated_at"] = DateTime.now();

      if (_section.id.isEmpty) {
        map["created_at"] = DateTime.now();
        map["sizes"] = ["large"];
        await FirebaseFirestore.instance.collection("sections").add(map);
      } else {
        await FirebaseFirestore.instance
            .collection("sections")
            .doc(_section.id)
            .update(map);
      }

      Beamer.of(context).popRoute();
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    }
  }

  void onTitleChanged(String title) {
    setState(() {
      _section = _section.copyWith(
        name: title,
      );
    });
  }

  void onDescriptionChanged(String description) {
    setState(() {
      _section = _section.copyWith(
        description: description,
      );
    });
  }

  void onBackgroundColorChanged(NamedColor namedColor) {
    setState(() {
      _section = _section.copyWith(
        backgroundColor: namedColor.color.value,
      );
    });
  }

  void onTextColorChanged(NamedColor namedColor) {
    setState(() {
      _section = _section.copyWith(
        textColor: namedColor.color.value,
      );
    });
  }

  void onHeaderSeparatorChanged(HeaderSeparator headerSeparator) {
    setState(() {
      _section = _section.copyWith(
        headerSeparator: headerSeparator,
      );
    });
  }

  void onDataFetchModesChanged(EnumSectionDataMode mode, bool selected) {
    if (selected) {
      _section = _section.copyWith(
        dataFetchModes: _section.dataFetchModes..add(mode),
      );
    } else {
      _section = _section.copyWith(
          dataFetchModes: _section.dataFetchModes..remove(mode));
    }

    setState(() {});
  }

  void onDataTypesChanged(EnumSectionDataType dataType, bool selected) {
    if (selected) {
      _section = _section.copyWith(
        dataTypes: _section.dataTypes..add(dataType),
      );
    } else {
      _section = _section.copyWith(
        dataTypes: _section.dataTypes..remove(dataType),
      );
    }

    setState(() {});
  }
}
