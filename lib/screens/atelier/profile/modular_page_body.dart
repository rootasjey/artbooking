import 'package:artbooking/components/application_bar/application_bar.dart';
import 'package:artbooking/components/application_bar/profile_application_bar.dart';
import 'package:artbooking/components/popup_menu/popup_menu_item_icon.dart';
import 'package:artbooking/globals/constants/section_ids.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/screens/atelier/profile/line_drop_zone.dart';
import 'package:artbooking/screens/atelier/profile/modular_page_fab.dart';
import 'package:artbooking/screens/atelier/profile/section_wrapper.dart';
import 'package:artbooking/types/enums/enum_page_type.dart';
import 'package:artbooking/types/modular_page.dart';
import 'package:artbooking/types/enums/enum_navigation_section.dart';
import 'package:artbooking/types/enums/enum_section_action.dart';
import 'package:artbooking/types/enums/enum_select_type.dart';
import 'package:artbooking/types/section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_improved_scrolling/flutter_improved_scrolling.dart';

class ModularPageBody extends StatelessWidget {
  const ModularPageBody({
    Key? key,
    required this.modularPage,
    required this.pageType,
    required this.scrollController,
    required this.userId,
    required this.username,
    this.editMode = false,
    this.isOwner = false,
    this.onAddSection,
    this.onDraggableSectionCanceled,
    this.onDragSectionCompleted,
    this.onDragSectionEnd,
    this.onDragSectionStarted,
    this.onDropSection,
    this.onDropSectionInBetween,
    this.onNavigateFromSection,
    this.onPageScroll,
    this.onPopupMenuItemSelected,
    this.onPointerMove,
    this.onShowAddSection,
    this.onShowBookDialog,
    this.onShowIllustrationDialog,
    this.onToggleEditMode,
    this.onToggleFabToTop,
    this.onUpdateSectionItems,
    this.popupMenuEntries = const [],
    this.showFab = false,
    this.showNavToTopFab = false,
    this.isMobileSize = false,
    this.showAppBarTitle = false,
  }) : super(key: key);

  /// If true, the current user is an admin or owner and can add, remove, and edit
  /// this page sections.
  final bool editMode;

  /// If true, this widget adapts its layout to small screens.
  final bool isMobileSize;

  /// True if the current authenticated user- if any - is the owner of this page.
  final bool isOwner;

  /// Show profile page username if true, and if it's a profile page type.
  final bool showAppBarTitle;

  /// If true, Floating Action Button will be displayed.
  final bool showFab;

  /// If true, a Floating Action Button to scroll to top will be displayed.
  final bool showNavToTopFab;

  /// The type of this page (e.g. home, profile).
  final EnumPageType pageType;

  /// Modular page fetched and composed of modular sections.
  final ModularPage modularPage;

  /// Callback fired when a popup menu item is tapped.
  final void Function(EnumSectionAction, int, Section)? onPopupMenuItemSelected;

  /// List of popup menu entries.
  final List<PopupMenuItemIcon<EnumSectionAction>> popupMenuEntries;

  /// Callback fired when we want to add a section.
  final void Function(Section section, int index)? onAddSection;

  /// Callback fired when "to the top" FAB's visibility is toggled.
  final void Function(bool show)? onToggleFabToTop;

  /// Callback when drag and dropping items on a section.
  final void Function(
    int dropTargetIndex,
    List<int> dragIndexes,
  )? onDropSection;

  /// Callback when dropping a section on a drop zone
  /// (which is not another section).
  final void Function(
    int dropTargetIndex,
    List<int> dragIndexes,
  )? onDropSectionInBetween;

  /// Callback fired when the page scrolls.
  final void Function(double)? onPageScroll;

  /// Callback to handle add secction action.
  final void Function(int index)? onShowAddSection;

  /// Callback to handle showing illustration selection action.
  final void Function({
    required Section section,
    required int index,
    required EnumSelectType selectType,
    int maxPick,
  })? onShowIllustrationDialog;

  /// Callback to handle showing book selection action.
  final void Function({
    required Section section,
    required int index,
    required EnumSelectType selectType,
    int maxPick,
  })? onShowBookDialog;

  /// Callback to handle section's items update.
  final void Function(
    Section section,
    int index,
    List<String> items,
  )? onUpdateSectionItems;

  /// Callback to handle edit mode toggle.
  final void Function()? onToggleEditMode;

  /// Callback to handle navigation from a section.
  final void Function(
    EnumNavigationSection enumNavigationSection,
  )? onNavigateFromSection;

  /// Callback to handle the cancel of a dragged item.
  final void Function(Velocity, Offset)? onDraggableSectionCanceled;

  /// Callback to handle the completion of a dragged item.
  final void Function()? onDragSectionCompleted;

  /// Callback to handle the end of a dragged item.
  final void Function(DraggableDetails draggableDetails)? onDragSectionEnd;

  /// Callback to handle the start of a dragged item.
  final void Function()? onDragSectionStarted;

  /// Callback to handle the move a pointer on the page.
  /// Useful to scroll the page when dragging a section to the edges.
  final void Function(PointerMoveEvent pointerMoveEvent)? onPointerMove;

  /// Scroll controller to move inside the page.
  final ScrollController scrollController;

  /// Current authenticated user's id;
  final String userId;

  /// This page owner's username.
  final String username;

  @override
  Widget build(BuildContext context) {
    final List<Widget> slivers = [
      // Sliver issue: https://github.com/flutter/flutter/issues/55170
      SliverToBoxAdapter(),
      if (modularPage.hasAppBar)
        ApplicationBar(
          pinned: false,
        ),
    ];

    int index = 0;

    for (final Section section in modularPage.sections) {
      if (editMode && isOwner) {
        Color color = Colors.transparent;
        if (index < modularPage.sections.length) {
          color = Color(
            modularPage.sections.elementAt(index).backgroundColor,
          );
        }

        slivers.add(
          LineDropZone(
            index: index,
            backgroundColor: color,
            onShowAddSection: onShowAddSection,
            onDropSection: onDropSectionInBetween,
          ),
        );
      }

      slivers.add(
        SectionWrapper(
          editMode: editMode && isOwner,
          index: index,
          onDraggableSectionCanceled: onDraggableSectionCanceled,
          onDragSectionCompleted: onDragSectionCompleted,
          onDragSectionEnd: onDragSectionEnd,
          onDragSectionStarted: onDragSectionStarted,
          onDropSection: onDropSection,
          onNavigateFromSection: onNavigateFromSection,
          onPopupMenuItemSelected: onPopupMenuItemSelected,
          onShowBookDialog: onShowBookDialog,
          onShowIllustrationDialog: onShowIllustrationDialog,
          onUpdateSectionItems: onUpdateSectionItems,
          popupMenuEntries: popupMenuEntries,
          section: section,
          sectionCount: modularPage.sections.length - 1,
          userId: userId,
        ),
      );

      index++;
    }

    if (modularPage.sections.last.id != SectionIds.footer) {
      slivers.add(
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 400.0),
          ),
        ),
      );
    }

    if (pageType == EnumPageType.profile) {
      slivers.insert(
        0,
        ProfileApplicationBar(
          title: Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Text(
              showAppBarTitle ? username : "",
              style: Utilities.fonts.body(
                color: Theme.of(context).textTheme.bodyText2?.color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      floatingActionButton: ModularPageFAB(
        editMode: editMode,
        isOwner: isOwner,
        onToggleEditMode: onToggleEditMode,
        pageScrollController: scrollController,
        showFab: showFab,
        showNavToTopFab: showNavToTopFab,
      ),
      body: Listener(
        onPointerMove: onPointerMove,
        child: Stack(
          children: [
            ImprovedScrolling(
              scrollController: scrollController,
              enableKeyboardScrolling: true,
              enableMMBScrolling: true,
              onScroll: onPageScroll,
              child: CustomScrollView(
                controller: scrollController,
                slivers: slivers,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
