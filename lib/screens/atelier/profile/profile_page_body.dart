import 'package:artbooking/components/application_bar/application_bar.dart';
import 'package:artbooking/components/buttons/circle_button.dart';
import 'package:artbooking/components/popup_menu/popup_menu_item_icon.dart';
import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/globals/constants/section_ids.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/screens/atelier/profile/profile_page_fab.dart';
import 'package:artbooking/screens/atelier/profile/section_wrapper.dart';
import 'package:artbooking/types/artistic_page.dart';
import 'package:artbooking/types/enums/enum_section_action.dart';
import 'package:artbooking/types/enums/enum_select_type.dart';
import 'package:artbooking/types/section.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_improved_scrolling/flutter_improved_scrolling.dart';
import 'package:unicons/unicons.dart';

class ProfilePageBody extends StatelessWidget {
  const ProfilePageBody({
    Key? key,
    required this.userId,
    required this.artisticPage,
    required this.scrollController,
    this.onPopupMenuItemSelected,
    this.popupMenuEntries = const [],
    this.onAddSection,
    this.isOwner = false,
    this.editMode = false,
    this.showFabToTop = false,
    this.onToggleFabToTop,
    this.onShowAddSection,
    this.onShowIllustrationDialog,
    this.onUpdateSectionItems,
    this.onShowBookDialog,
    this.onDropSection,
    this.showBackButton = false,
    this.onToggleEditMode,
  }) : super(key: key);

  final bool isOwner;
  final bool showBackButton;
  final bool showFabToTop;

  /// If true, the current user is an admin or owner and can add, remove, and edit
  /// this page sections.
  final bool editMode;

  final String userId;
  final ArtisticPage artisticPage;
  final void Function(EnumSectionAction, int, Section)? onPopupMenuItemSelected;
  final List<PopupMenuItemIcon<EnumSectionAction>> popupMenuEntries;

  final void Function(Section)? onAddSection;
  final void Function(bool show)? onToggleFabToTop;

  /// Callback when drag and dropping items on this book card.
  final void Function(
    int dropTargetIndex,
    List<int> dragIndexes,
  )? onDropSection;
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

  final void Function()? onToggleEditMode;

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final bool hasAppBar =
        artisticPage.sections.any((element) => element.id == SectionIds.appBar);

    final List<Widget> slivers = [
      // Sliver issue: https://github.com/flutter/flutter/issues/55170
      SliverToBoxAdapter(),
      if (hasAppBar) ApplicationBar(),
    ];

    int index = -1;

    for (var section in artisticPage.sections) {
      index++;
      slivers.add(
        SectionWrapper(
          section: section,
          index: index,
          scrollController: scrollController,
          editMode: editMode,
          sectionCount: artisticPage.sections.length - 1,
          userId: userId,
          onDropSection: onDropSection,
          popupMenuEntries: popupMenuEntries,
          onPopupMenuItemSelected: onPopupMenuItemSelected,
          onUpdateSectionItems: onUpdateSectionItems,
          onShowBookDialog: onShowBookDialog,
          onShowIllustrationDialog: onShowIllustrationDialog,
        ),
      );
    }

    if (isOwner) {
      slivers.add(
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 42.0),
          ),
        ),
      );
    }

    return Scaffold(
      floatingActionButton: ProfilePageFAB(
        editMode: editMode,
        isOwner: isOwner,
        onToggleEditMode: onToggleEditMode,
        scrollController: scrollController,
        showFabToTop: showFabToTop,
      ),
      body: Stack(
        children: [
          ImprovedScrolling(
            scrollController: scrollController,
            enableKeyboardScrolling: true,
            onScroll: (double vOffset) {
              if (vOffset > 200.0 && !showFabToTop) {
                onToggleFabToTop?.call(true);
                return;
              }

              if (vOffset < 200.0 && showFabToTop) {
                onToggleFabToTop?.call(false);
                return;
              }
            },
            child: CustomScrollView(
              controller: scrollController,
              slivers: slivers,
            ),
          ),
          if (showBackButton)
            Positioned(
              top: 16.0,
              left: 64.0,
              child: CircleButton(
                tooltip: "back".tr(),
                elevation: 2.0,
                backgroundColor: Constants.colors.tertiary,
                onTap: () => Utilities.navigation.back(context),
                icon: Icon(
                  UniconsLine.arrow_left,
                  color: Colors.black,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
