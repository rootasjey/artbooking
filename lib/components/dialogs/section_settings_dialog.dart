import 'package:artbooking/components/animations/fade_in_y.dart';
import 'package:artbooking/components/buttons/dark_outlined_button.dart';
import 'package:artbooking/components/dialogs/themed_dialog.dart';
import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/data_fetch_mode_tile_data.dart';
import 'package:artbooking/types/enums/enum_section_config_tab.dart';
import 'package:artbooking/types/enums/enum_section_data_mode.dart';
import 'package:artbooking/types/named_color.dart';
import 'package:artbooking/types/section.dart';
import 'package:beamer/beamer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class SectionSettingsDialog extends StatefulWidget {
  const SectionSettingsDialog({
    Key? key,
    this.onValidate,
    required this.section,
    required this.index,
    this.onDataFetchModeChanged,
    this.showDataMode = true,
  }) : super(key: key);

  final bool showDataMode;
  final Section section;
  final int index;
  final void Function(NamedColor, int, Section)? onValidate;
  final void Function(
    Section,
    int,
    EnumSectionDataMode,
  )? onDataFetchModeChanged;

  @override
  State<SectionSettingsDialog> createState() => _SectionSettingsDialogState();
}

class _SectionSettingsDialogState extends State<SectionSettingsDialog> {
  var _selectedTab = EnumSectionConfigTab.backgroundColor;

  @override
  void initState() {
    super.initState();
    loadSavedData();
  }

  @override
  Widget build(BuildContext context) {
    return ThemedDialog(
      useRawDialog: true,
      title: header(),
      body: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: 360.0,
          maxWidth: 400.0,
        ),
        child: body(),
      ),
      textButtonValidation: "close".tr(),
      onCancel: Beamer.of(context).popRoute,
      onValidate: Beamer.of(context).popRoute,
    );
  }

  Widget body() {
    if (_selectedTab == EnumSectionConfigTab.dataFetchMode) {
      return dataFetchWidget();
    }

    return colorsListWidget();
  }

  Widget colorsListWidget() {
    int index = 0;

    return CustomScrollView(
      slivers: [
        SliverList(
          delegate: SliverChildListDelegate.fixed([
            Opacity(
              opacity: 0.6,
              child: Text(
                "section_background_color_chose".tr(),
                textAlign: TextAlign.center,
                style: Utilities.fonts.style(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Padding(
                padding: const EdgeInsets.all(12.0),
                child: Wrap(
                  spacing: 12.0,
                  runSpacing: 12.0,
                  alignment: WrapAlignment.center,
                  children: [
                    NamedColor(
                      name: "Clair Pink",
                      color: Constants.colors.clairPink,
                    ),
                    NamedColor(
                      name: "Light Blue",
                      color: Constants.colors.lightBackground,
                    ),
                    NamedColor(
                      name: "Blue 100",
                      color: Colors.blue.shade100,
                    ),
                    NamedColor(
                      name: "Green 100",
                      color: Colors.green.shade100,
                    ),
                    NamedColor(
                      name: "Lime 100",
                      color: Colors.lime.shade100,
                    ),
                    NamedColor(
                      name: "Amber 100",
                      color: Colors.amber.shade100,
                    ),
                    NamedColor(
                      name: "Yellow 100",
                      color: Colors.yellow.shade100,
                    ),
                    NamedColor(
                      name: "Deep Orange 100",
                      color: Colors.deepOrange.shade100,
                    ),
                    NamedColor(
                      name: "Orange 100",
                      color: Colors.orange.shade100,
                    ),
                    NamedColor(
                      name: "Red 100",
                      color: Colors.red.shade100,
                    ),
                    NamedColor(
                      name: "Pink 100",
                      color: Colors.pink.shade100,
                    ),
                    NamedColor(
                      name: "Deep Purple 100",
                      color: Colors.deepPurple.shade100,
                    ),
                    NamedColor(
                      name: "Purple 100",
                      color: Colors.purple.shade100,
                    ),
                    NamedColor(
                      name: "Indigo 100",
                      color: Colors.indigo.shade100,
                    ),
                    NamedColor(
                      name: "Grey 100",
                      color: Colors.grey.shade100,
                    ),
                    NamedColor(
                      name: "White 54",
                      color: Colors.white54,
                    ),
                    NamedColor(
                      name: "Black 26",
                      color: Colors.black26,
                    ),
                  ].map((NamedColor namedColor) {
                    index++;
                    return FadeInY(
                      beginY: 12.0,
                      delay: Duration(milliseconds: 50 * index),
                      child: colorCard(
                        namedColor,
                        context,
                      ),
                    );
                  }).toList(),
                )),
          ]),
        ),
      ],
    );
  }

  Widget dataFetchWidget() {
    int index = 0;

    return CustomScrollView(
      slivers: [
        SliverList(
          delegate: SliverChildListDelegate.fixed([
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Opacity(
                opacity: 0.6,
                child: Text(
                  "section_data_mode_chose".tr(),
                  textAlign: TextAlign.center,
                  style: Utilities.fonts.style(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            ...[
              DataFetchModeTileData(
                name: "data_fetch_mode_chosen".tr(),
                description: "data_fetch_mode_chosen_description".tr(),
                iconData: UniconsLine.list_ol,
                mode: EnumSectionDataMode.chosen,
              ),
              DataFetchModeTileData(
                name: "data_fetch_mode_sync".tr(),
                description: "data_fetch_mode_sync_description".tr(),
                iconData: UniconsLine.sync_icon,
                mode: EnumSectionDataMode.sync,
              ),
            ].map((data) {
              index++;
              return FadeInY(
                  beginY: 12.0,
                  delay: Duration(milliseconds: 50 * index),
                  child: dataFetchModeTile(data));
            }).toList()
          ]),
        )
      ],
    );
  }

  Widget dataFetchModeTile(DataFetchModeTileData data) {
    final double cardWidth = 100.0;
    final double cardHeight = 100.0;

    final bool selected = widget.section.dataMode == data.mode;
    final Color primaryColor = Theme.of(context).primaryColor;
    final BorderSide borderSide = selected
        ? BorderSide(color: primaryColor, width: 2.0)
        : BorderSide.none;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: cardHeight,
                width: cardWidth,
                child: Card(
                  elevation: 3.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    side: borderSide,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    child: Opacity(
                      opacity: 0.8,
                      child: Icon(
                        data.iconData,
                        size: 32.0,
                      ),
                    ),
                    onTap: () => onTapFetchMode(data),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4.0, right: 12.0),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8.0),
                    onTap: () => onTapFetchMode(data),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Opacity(
                              opacity: 0.7,
                              child: Text(
                                data.name,
                                maxLines: 1,
                                style: Utilities.fonts.style(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            Opacity(
                              opacity: 0.4,
                              child: Text(
                                data.description,
                                maxLines: 3,
                                style: Utilities.fonts.style(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget header() {
    return Opacity(
      opacity: 0.8,
      child: Column(
        children: [
          Text(
            "section_configure".tr().toUpperCase(),
            style: Utilities.fonts.style(
              color: Colors.black,
              fontWeight: FontWeight.w700,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 12.0,
              right: 12.0,
              top: 12.0,
            ),
            child: Wrap(
              spacing: 12.0,
              children: [
                DarkOutlinedButton(
                  selected:
                      _selectedTab == EnumSectionConfigTab.backgroundColor,
                  onPressed: () => onPressedTabButton(
                    EnumSectionConfigTab.backgroundColor,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Icon(UniconsLine.palette),
                      ),
                      Text("colors".tr()),
                    ],
                  ),
                ),
                if (widget.showDataMode)
                  DarkOutlinedButton(
                    selected:
                        _selectedTab == EnumSectionConfigTab.dataFetchMode,
                    onPressed: () => onPressedTabButton(
                      EnumSectionConfigTab.dataFetchMode,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Icon(UniconsLine.cloud_data_connection),
                        ),
                        Text("data_mode".tr()),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget colorCard(NamedColor namedColor, BuildContext context) {
    final bool selected =
        widget.section.backgroundColor == namedColor.color.value;
    final Color primaryColor = Theme.of(context).primaryColor;
    final BorderSide borderSide = selected
        ? BorderSide(color: primaryColor, width: 2.0)
        : BorderSide.none;

    return Column(
      children: [
        SizedBox(
          width: 100.0,
          height: 100.0,
          child: Card(
            color: namedColor.color,
            shape: RoundedRectangleBorder(
              side: borderSide,
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: InkWell(
              onTap: () => onTapNamedColor(namedColor),
            ),
          ),
        ),
        Opacity(
          opacity: 0.7,
          child: Text(
            namedColor.name,
            style: Utilities.fonts.style(
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
              color: selected ? primaryColor : null,
            ),
          ),
        ),
      ],
    );
  }

  /// Load this specific component saved data (e.g. last selected tab).
  void loadSavedData() {
    _selectedTab = Utilities.storage.getSectionConfigTab();

    if (!widget.showDataMode) {
      _selectedTab = EnumSectionConfigTab.backgroundColor;
    }
  }

  void onPressedTabButton(EnumSectionConfigTab selectedTab) {
    setState(() {
      _selectedTab = selectedTab;
    });

    Utilities.storage.saveSectionConfigTab(selectedTab);
  }

  void onTapFetchMode(DataFetchModeTileData data) {
    Beamer.of(context).popRoute();
    widget.onDataFetchModeChanged?.call(
      widget.section,
      widget.index,
      data.mode,
    );
  }

  void onTapNamedColor(NamedColor namedColor) {
    widget.onValidate?.call(namedColor, widget.index, widget.section);
    Beamer.of(context).popRoute();
  }
}
