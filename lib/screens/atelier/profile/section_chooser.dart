import 'package:artbooking/components/popup_menu/popup_menu_item_icon.dart';
import 'package:artbooking/globals/constants/section_ids.dart';
import 'package:artbooking/screens/atelier/profile/sections/book_grid_section.dart';
import 'package:artbooking/screens/atelier/profile/sections/bordered_poster_section.dart';
import 'package:artbooking/screens/atelier/profile/sections/featured_artists_section.dart';
import 'package:artbooking/screens/atelier/profile/sections/footer_section.dart';
import 'package:artbooking/screens/atelier/profile/sections/h1_section.dart';
import 'package:artbooking/screens/atelier/profile/sections/h4_section.dart';
import 'package:artbooking/screens/atelier/profile/sections/illustration_grid_section.dart';
import 'package:artbooking/screens/atelier/profile/sections/illustration_row_section.dart';
import 'package:artbooking/screens/atelier/profile/sections/illustration_window_section.dart';
import 'package:artbooking/screens/atelier/profile/sections/mozaic_section.dart';
import 'package:artbooking/screens/atelier/profile/sections/news_section.dart';
import 'package:artbooking/screens/atelier/profile/sections/poster_section.dart';
import 'package:artbooking/screens/atelier/profile/sections/spacing_section.dart';
import 'package:artbooking/screens/atelier/profile/sections/title_description_section.dart';
import 'package:artbooking/screens/atelier/profile/sections/user_illustration_section.dart';
import 'package:artbooking/screens/atelier/profile/sections/user_section.dart';
import 'package:artbooking/types/enums/enum_section_action.dart';
import 'package:artbooking/types/enums/enum_select_type.dart';
import 'package:artbooking/types/section.dart';
import 'package:flutter/material.dart';

/// Decide which section widget to build according to an id.
class SectionChooser {
  static Widget getSection({
    required Section section,
    required int index,
    required String userId,

    /// Sections' count.
    required int count,
    bool editMode = false,
    bool isHover = false,
    bool usingAsDropTarget = false,
    void Function(EnumSectionAction, int, Section)? onPopupMenuItemSelected,
    List<PopupMenuItemIcon<EnumSectionAction>> popupMenuEntries = const [],
    final void Function({
      required Section section,
      required int index,
      required EnumSelectType selectType,
      int maxPick,
    })?
        onShowIllustrationDialog,
    void Function(Section, int, List<String>)? onUpdateSectionItems,
    void Function({
      required int index,
      required Section section,
      required EnumSelectType selectType,
    })?
        onShowBookDialog,
  }) {
    if (section.id == SectionIds.user) {
      return UserSection(
        index: index,
        section: section,
        userId: userId,
        editMode: editMode,
        usingAsDropTarget: usingAsDropTarget,
        onPopupMenuItemSelected: onPopupMenuItemSelected,
        popupMenuEntries: popupMenuEntries,
        isLast: index == count,
        isHover: isHover,
      );
    }

    if (section.id == SectionIds.illustrationGrid) {
      return IllustrationGridSection(
        index: index,
        section: section,
        userId: userId,
        editMode: editMode,
        usingAsDropTarget: usingAsDropTarget,
        onPopupMenuItemSelected: onPopupMenuItemSelected,
        popupMenuEntries: popupMenuEntries,
        isLast: index == count,
        onShowIllustrationDialog: onShowIllustrationDialog,
        onUpdateSectionItems: onUpdateSectionItems,
        isHover: isHover,
      );
    }

    if (section.id == SectionIds.bookGrid) {
      return BookGridSection(
        index: index,
        section: section,
        userId: userId,
        editMode: editMode,
        usingAsDropTarget: usingAsDropTarget,
        isLast: index == count,
        onPopupMenuItemSelected: onPopupMenuItemSelected,
        popupMenuEntries: popupMenuEntries,
        onUpdateSectionItems: onUpdateSectionItems,
        onShowBookDialog: onShowBookDialog,
        isHover: isHover,
      );
    }

    if (section.id == SectionIds.userWithIllustration) {
      return UserIllustrationSection(
        index: index,
        section: section,
        userId: userId,
        editMode: editMode,
        usingAsDropTarget: usingAsDropTarget,
        isLast: index == count,
        onPopupMenuItemSelected: onPopupMenuItemSelected,
        onShowIllustrationDialog: onShowIllustrationDialog,
        popupMenuEntries: popupMenuEntries,
        onUpdateSectionItems: onUpdateSectionItems,
        isHover: isHover,
      );
    }

    if (section.id == SectionIds.borderedPoster) {
      return BorderedPosterSection(
        index: index,
        section: section,
        editMode: editMode,
        usingAsDropTarget: usingAsDropTarget,
        isLast: index == count,
        onPopupMenuItemSelected: onPopupMenuItemSelected,
        onShowIllustrationDialog: onShowIllustrationDialog,
        popupMenuEntries: popupMenuEntries,
        onUpdateSectionItems: onUpdateSectionItems,
        isHover: isHover,
      );
    }

    if (section.id == SectionIds.poster) {
      return PosterSection(
        index: index,
        section: section,
        editMode: editMode,
        usingAsDropTarget: usingAsDropTarget,
        isLast: index == count,
        onPopupMenuItemSelected: onPopupMenuItemSelected,
        onShowIllustrationDialog: onShowIllustrationDialog,
        popupMenuEntries: popupMenuEntries,
        onUpdateSectionItems: onUpdateSectionItems,
        isHover: isHover,
      );
    }

    if (section.id == SectionIds.illustrationRow) {
      return IllustrationRowSection(
        index: index,
        section: section,
        userId: userId,
        editMode: editMode,
        usingAsDropTarget: usingAsDropTarget,
        isLast: index == count,
        onPopupMenuItemSelected: onPopupMenuItemSelected,
        onShowIllustrationDialog: onShowIllustrationDialog,
        popupMenuEntries: popupMenuEntries,
        onUpdateSectionItems: onUpdateSectionItems,
        isHover: isHover,
      );
    }

    if (section.id == SectionIds.spacing) {
      return SpacingSection(
        index: index,
        section: section,
        editMode: editMode,
        usingAsDropTarget: usingAsDropTarget,
        isLast: index == count,
        onPopupMenuItemSelected: onPopupMenuItemSelected,
        popupMenuEntries: popupMenuEntries,
        isHover: isHover,
      );
    }

    if (section.id == SectionIds.h1) {
      return H1Section(
        index: index,
        section: section,
        editMode: editMode,
        usingAsDropTarget: usingAsDropTarget,
        isLast: index == count,
        onPopupMenuItemSelected: onPopupMenuItemSelected,
        popupMenuEntries: popupMenuEntries,
        isHover: isHover,
      );
    }

    if (section.id == SectionIds.h4) {
      return H4Section(
        index: index,
        section: section,
        editMode: editMode,
        usingAsDropTarget: usingAsDropTarget,
        isLast: index == count,
        onPopupMenuItemSelected: onPopupMenuItemSelected,
        popupMenuEntries: popupMenuEntries,
        isHover: isHover,
      );
    }

    if (section.id == SectionIds.titleDescription) {
      return TitleDescriptionSection(
        index: index,
        section: section,
        editMode: editMode,
        usingAsDropTarget: usingAsDropTarget,
        isLast: index == count,
        onPopupMenuItemSelected: onPopupMenuItemSelected,
        popupMenuEntries: popupMenuEntries,
        isHover: isHover,
      );
    }

    if (section.id == SectionIds.illustrationWindow) {
      return IllustrationWindowSection(
        index: index,
        section: section,
        userId: userId,
        editMode: editMode,
        usingAsDropTarget: usingAsDropTarget,
        isLast: index == count,
        onShowIllustrationDialog: onShowIllustrationDialog,
        popupMenuEntries: popupMenuEntries,
        onPopupMenuItemSelected: onPopupMenuItemSelected,
        isHover: isHover,
      );
    }

    if (section.id == SectionIds.featuredArtist) {
      return FeaturedArtistsSection(
        index: index,
        section: section,
        userId: userId,
        editMode: editMode,
        usingAsDropTarget: usingAsDropTarget,
        isLast: index == count,
        onShowIllustrationDialog: onShowIllustrationDialog,
        popupMenuEntries: popupMenuEntries,
        onPopupMenuItemSelected: onPopupMenuItemSelected,
        isHover: isHover,
      );
    }

    if (section.id == SectionIds.footer) {
      return FooterSection(
        index: index,
        section: section,
        editMode: editMode,
        usingAsDropTarget: usingAsDropTarget,
        isLast: index == count,
        popupMenuEntries: popupMenuEntries,
        onPopupMenuItemSelected: onPopupMenuItemSelected,
        isHover: isHover,
      );
    }

    if (section.id == SectionIds.news) {
      return NewsSection(
        index: index,
        section: section,
        editMode: editMode,
        usingAsDropTarget: usingAsDropTarget,
        isLast: index == count,
        popupMenuEntries: popupMenuEntries,
        onPopupMenuItemSelected: onPopupMenuItemSelected,
        isHover: isHover,
      );
    }

    if (section.id == SectionIds.mozaic) {
      return MozaicSection(
        index: index,
        section: section,
        userId: userId,
        editMode: editMode,
        usingAsDropTarget: usingAsDropTarget,
        isLast: index == count,
        onShowIllustrationDialog: onShowIllustrationDialog,
        popupMenuEntries: popupMenuEntries,
        onPopupMenuItemSelected: onPopupMenuItemSelected,
        onUpdateSectionItems: onUpdateSectionItems,
        isHover: isHover,
      );
    }

    return Container();
  }
}
