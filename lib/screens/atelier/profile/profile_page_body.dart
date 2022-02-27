import 'package:artbooking/components/popup_menu/popup_menu_item_icon.dart';
import 'package:artbooking/globals/constants/section_ids.dart';
import 'package:artbooking/screens/atelier/profile/profile_page_add_section.dart';
import 'package:artbooking/screens/atelier/profile/profile_page_books.dart';
import 'package:artbooking/screens/atelier/profile/profile_page_hero.dart';
import 'package:artbooking/screens/atelier/profile/profile_page_illustrations.dart';
import 'package:artbooking/types/artistic_page.dart';
import 'package:artbooking/types/enums/enum_section_action.dart';
import 'package:artbooking/types/section.dart';
import 'package:flutter/material.dart';

class ProfilePageBody extends StatelessWidget {
  const ProfilePageBody({
    Key? key,
    required this.userId,
    required this.artisticPage,
    this.onPopupMenuItemSelected,
    this.popupMenuEntries = const [],
    this.onAddSection,
  }) : super(key: key);

  final String userId;
  final ArtisticPage artisticPage;
  final void Function(EnumSectionAction, int, Section)? onPopupMenuItemSelected;
  final List<PopupMenuItemIcon<EnumSectionAction>> popupMenuEntries;
  final void Function(Section)? onAddSection;

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

    slivers.add(ProfilePageAddSection(
      onAddSection: onAddSection,
    ));

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: slivers,
          ),
        ],
      ),
    );
  }

  Widget getSectionWidget(Section section, int index) {
    if (section.id == SectionIds.userWithArtworks) {
      return ProfilePageHero(
        index: index,
        section: section,
        userId: userId,
        onPopupMenuItemSelected: onPopupMenuItemSelected,
        popupMenuEntries: popupMenuEntries,
        isLast: index == artisticPage.sections.length - 1,
      );
    }

    if (section.id == SectionIds.illustrationGrid) {
      return ProfilePageIllustrations(
        index: index,
        section: section,
        title: section.name,
        mode: section.mode,
        userId: userId,
        onPopupMenuItemSelected: onPopupMenuItemSelected,
        popupMenuEntries: popupMenuEntries,
        isLast: index == artisticPage.sections.length - 1,
      );
    }

    if (section.id == SectionIds.bookGrid) {
      return ProfilePageBooks(
        index: index,
        section: section,
        title: section.name,
        mode: section.mode,
        userId: userId,
        onPopupMenuItemSelected: onPopupMenuItemSelected,
        popupMenuEntries: popupMenuEntries,
      );
    }

    return SliverToBoxAdapter();
  }
}
