import 'package:artbooking/components/popup_menu/popup_menu_item_icon.dart';
import 'package:artbooking/globals/constants/section_ids.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/screens/atelier/profile/sections/book_grid_section.dart';
import 'package:artbooking/screens/atelier/profile/sections/user_illustration_section.dart';
import 'package:artbooking/screens/atelier/profile/sections/user_section.dart';
import 'package:artbooking/screens/atelier/profile/sections/illustration_grid_section.dart';
import 'package:artbooking/types/artistic_page.dart';
import 'package:artbooking/types/enums/enum_section_action.dart';
import 'package:artbooking/types/enums/enum_select_type.dart';
import 'package:artbooking/types/section.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class ProfilePageBody extends StatelessWidget {
  const ProfilePageBody({
    Key? key,
    required this.userId,
    required this.artisticPage,
    this.onPopupMenuItemSelected,
    this.popupMenuEntries = const [],
    this.onAddSection,
    this.isOwner = false,
    this.onShowAddSection,
    this.onShowIllustrationDialog,
    this.onUpdateSectionItems,
    this.onShowBookDialog,
  }) : super(key: key);

  final bool isOwner;
  final String userId;
  final ArtisticPage artisticPage;
  final void Function(EnumSectionAction, int, Section)? onPopupMenuItemSelected;
  final List<PopupMenuItemIcon<EnumSectionAction>> popupMenuEntries;

  final void Function(Section)? onAddSection;
  final void Function()? onShowAddSection;
  final void Function({
    required Section section,
    required int index,
    required EnumSelectType selectType,
    int maxPick,
  })? onShowIllustrationDialog;

  final void Function({
    required Section section,
    required int index,
    required EnumSelectType selectType,
    int maxPick,
  })? onShowBookDialog;

  final void Function(
    Section section,
    int index,
    List<String> items,
  )? onUpdateSectionItems;

  @override
  Widget build(BuildContext context) {
    final List<Widget> slivers = [
      // Sliver issue: https://github.com/flutter/flutter/issues/55170
      SliverToBoxAdapter(),
    ];

    int index = -1;

    for (var section in artisticPage.sections) {
      index++;
      slivers.add(getSectionWidget(section, index));
    }

    if (isOwner) {
      slivers.add(newSectionButton(context));
    }

    return Scaffold(
      floatingActionButton: fab(context),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: slivers,
          ),
        ],
      ),
    );
  }

  Widget newSectionButton(BuildContext context) {
    return SliverToBoxAdapter(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 32.0,
          ),
          child: DottedBorder(
            strokeWidth: 3.0,
            borderType: BorderType.RRect,
            radius: Radius.circular(8),
            color: Theme.of(context).primaryColor.withOpacity(0.6),
            dashPattern: [8, 4],
            child: InkWell(
              onTap: onShowAddSection,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
                child: Opacity(
                  opacity: 0.6,
                  child: Text(
                    "section_add_new".tr(),
                    style: Utilities.fonts.style(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget fab(BuildContext context) {
    if (!isOwner) {
      return Container();
    }

    return FloatingActionButton(
      onPressed: onShowAddSection,
      backgroundColor: Theme.of(context).primaryColor,
      child: Icon(UniconsLine.plus),
    );
  }

  Widget getSectionWidget(Section section, int index) {
    if (section.id == SectionIds.user) {
      return UserSection(
        index: index,
        section: section,
        userId: userId,
        onPopupMenuItemSelected: onPopupMenuItemSelected,
        popupMenuEntries: popupMenuEntries,
        isLast: index == artisticPage.sections.length - 1,
      );
    }

    if (section.id == SectionIds.illustrationGrid) {
      return IllustrationGridSection(
        index: index,
        section: section,
        userId: userId,
        onPopupMenuItemSelected: onPopupMenuItemSelected,
        popupMenuEntries: popupMenuEntries,
        isLast: index == artisticPage.sections.length - 1,
        onShowIllustrationDialog: onShowIllustrationDialog,
        onUpdateSectionItems: onUpdateSectionItems,
      );
    }

    if (section.id == SectionIds.bookGrid) {
      return BookGridSection(
        index: index,
        section: section,
        userId: userId,
        isLast: index == artisticPage.sections.length - 1,
        onPopupMenuItemSelected: onPopupMenuItemSelected,
        popupMenuEntries: popupMenuEntries,
        onUpdateSectionItems: onUpdateSectionItems,
        onShowBookDialog: onShowBookDialog,
      );
    }

    if (section.id == SectionIds.userWithIllustration) {
      return UserIllustrationSection(
        index: index,
        section: section,
        userId: userId,
        isLast: index == artisticPage.sections.length - 1,
        onPopupMenuItemSelected: onPopupMenuItemSelected,
        onShowIllustrationDialog: onShowIllustrationDialog,
        popupMenuEntries: popupMenuEntries,
        onUpdateSectionItems: onUpdateSectionItems,
      );
    }

    return SliverToBoxAdapter();
  }
}
