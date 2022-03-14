import 'package:artbooking/components/animations/fade_in_y.dart';
import 'package:artbooking/components/buttons/dark_outlined_button.dart';
import 'package:artbooking/components/dialogs/colors_selector.dart';
import 'package:artbooking/components/dialogs/themed_dialog.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/enums/enum_section_config_tab.dart';
import 'package:artbooking/types/enums/enum_section_data_mode.dart';
import 'package:artbooking/types/named_color.dart';
import 'package:artbooking/types/section.dart';
import 'package:artbooking/types/tile_data.dart';
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

  /// If false, hide data fetch mode tab.
  final bool showDataMode;

  /// Current editing section.
  final Section section;

  /// Section's idnex position in a list (if any).
  final int index;

  /// Called when changes are validated
  final void Function(NamedColor, int, Section)? onValidate;

  /// Called after selecting a new data fetch mode.
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

    return ColorsSelector(
      selectedColorInt: widget.section.backgroundColor,
      onTapNamedColor: onTapNamedColor,
      subtitle: "section_background_color_choose".tr(),
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
                  "section_data_mode_choose".tr(),
                  textAlign: TextAlign.center,
                  style: Utilities.fonts.style(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            ...[
              TileData<EnumSectionDataMode>(
                name: "data_fetch_mode_title.chosen".tr(),
                description: "data_fetch_mode_description.chosen".tr(),
                iconData: UniconsLine.list_ol,
                type: EnumSectionDataMode.chosen,
              ),
              TileData<EnumSectionDataMode>(
                name: "data_fetch_mode_title.sync".tr(),
                description: "data_fetch_mode_description.sync".tr(),
                iconData: UniconsLine.sync_icon,
                type: EnumSectionDataMode.sync,
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

  Widget dataFetchModeTile(TileData<EnumSectionDataMode> data) {
    final double cardWidth = 100.0;
    final double cardHeight = 100.0;

    final bool selected = widget.section.dataFetchMode == data.type;
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

  void onTapFetchMode(TileData<EnumSectionDataMode> data) {
    Beamer.of(context).popRoute();
    widget.onDataFetchModeChanged?.call(
      widget.section,
      widget.index,
      data.type,
    );
  }

  void onTapNamedColor(NamedColor namedColor) {
    widget.onValidate?.call(namedColor, widget.index, widget.section);
    Beamer.of(context).popRoute();
  }
}
