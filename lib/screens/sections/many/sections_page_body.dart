import 'package:artbooking/components/buttons/dark_elevated_button.dart';
import 'package:artbooking/components/loading_view.dart';
import 'package:artbooking/components/popup_menu/popup_menu_item_icon.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/screens/sections/many/section_card_item.dart';
import 'package:artbooking/types/enums/enum_section_item_action.dart';
import 'package:artbooking/types/section.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class SectionsPageBody extends StatelessWidget {
  const SectionsPageBody({
    Key? key,
    required this.sections,
    this.isMobileSize = false,
    this.loading = false,
    this.onDeleteSection,
    this.onEditSection,
    this.onTapSection,
    this.onCreateSection,
    this.popupMenuEntries = const [],
    this.onPopupMenuItemSelected,
  }) : super(key: key);

  /// If true, this widget adapt its layout to small screens.
  final bool isMobileSize;

  /// Data list.
  final List<Section> sections;

  /// Currently fetching data if true.
  final bool loading;

  /// Callback event fired when we want to delete a section.
  final Function(Section, int)? onDeleteSection;

  /// Callback event fired when we want to edit a section.
  final Function(Section, int)? onEditSection;

  /// Callback event fired when we want to create a section.
  final Function()? onCreateSection;

  /// Callback event fired when we tap on a section.
  final Function(Section, int)? onTapSection;

  /// Menu item list displayed after tapping on the corresponding popup button.
  final List<PopupMenuItemIcon<EnumSectionItemAction>> popupMenuEntries;

  /// Callback fired when one of the popup menu item entries is selected.
  final void Function(
    EnumSectionItemAction action,
    Section section,
    int index,
  )? onPopupMenuItemSelected;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return LoadingView(
        sliver: true,
        title: Text(
          "sections_loading".tr() + "...",
          style: Utilities.fonts.body(
            fontSize: 32.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    if (sections.isEmpty) {
      return SliverPadding(
        padding: EdgeInsets.symmetric(
          horizontal: isMobileSize ? 12.0 : 80.0,
          vertical: 69.0,
        ),
        sliver: SliverList(
          delegate: SliverChildListDelegate.fixed([
            Align(
              alignment: Alignment.topLeft,
              child: Opacity(
                opacity: 0.6,
                child: Icon(
                  UniconsLine.no_entry,
                  size: 80.0,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: DarkElevatedButton(
                  onPressed: onCreateSection,
                  child: Text(
                    "section_create".tr(),
                  ),
                ),
              ),
            ),
          ]),
        ),
      );
    }

    if (isMobileSize) {
      return SliverPadding(
        padding: EdgeInsets.only(
          top: 24.0,
          bottom: 300.0,
        ),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              final Section section = sections.elementAt(index);

              return SectionCardItem(
                key: ValueKey(section.id),
                margin: const EdgeInsets.only(bottom: 6.0),
                index: index,
                isWide: isMobileSize,
                section: section,
                onTap: onTapSection,
                onDelete: onDeleteSection,
                onEdit: onEditSection,
                popupMenuEntries: popupMenuEntries,
                onPopupMenuItemSelected: onPopupMenuItemSelected,
                useBottomSheet: isMobileSize,
              );
            },
            childCount: sections.length,
          ),
        ),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.only(
        top: isMobileSize ? 24.0 : 42.0,
        left: isMobileSize ? 12.0 : 34.0,
        right: isMobileSize ? 12.0 : 30.0,
        bottom: 300.0,
      ),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 280.0,
          mainAxisSpacing: 24.0,
          crossAxisSpacing: 24.0,
          childAspectRatio: 0.9,
        ),
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            final Section section = sections.elementAt(index);

            return SectionCardItem(
              key: ValueKey(section.id),
              index: index,
              section: section,
              onTap: onTapSection,
              onDelete: onDeleteSection,
              onEdit: onEditSection,
              popupMenuEntries: popupMenuEntries,
              onPopupMenuItemSelected: onPopupMenuItemSelected,
              useBottomSheet: isMobileSize,
            );
          },
          childCount: sections.length,
        ),
      ),
    );
  }
}
