import 'package:artbooking/components/application_bar/application_bar.dart';
import 'package:artbooking/components/buttons/circle_button.dart';
import 'package:artbooking/components/popup_menu/popup_menu_item_icon.dart';
import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/globals/constants/section_ids.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/screens/atelier/profile/line_drop_zone.dart';
import 'package:artbooking/screens/atelier/profile/profile_page_fab.dart';
import 'package:artbooking/screens/atelier/profile/section_wrapper.dart';
import 'package:artbooking/types/modular_page.dart';
import 'package:artbooking/types/enums/enum_navigation_section.dart';
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
    required this.modularPage,
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
    this.onDropSectionInBetween,
    this.onNavigateFromSection,
    this.onDraggableSectionCanceled,
    this.onDragSectionCompleted,
    this.onDragSectionEnd,
    this.onDragSectionStarted,
    this.onPointerMove,
  }) : super(key: key);

  /// True if the current authenticated user- if any - is the owner of this page.
  final bool isOwner;

  /// If true, a back button will be display on the page.
  final bool showBackButton;

  /// If true, a Floating Action Button to scroll to top will be displayed.
  final bool showFabToTop;

  /// If true, the current user is an admin or owner and can add, remove, and edit
  /// this page sections.
  final bool editMode;

  /// Current authenticated user's id;
  final String userId;

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

  /// Scroll controller to move inside the page.
  final ScrollController scrollController;

  /// Callback to handle navigation from a section.
  final void Function(
    EnumNavigationSection enumNavigationSection,
  )? onNavigateFromSection;

  /// Callback to handle the cancel of a dragged item.
  final void Function(Velocity, Offset)? onDraggableSectionCanceled;

  /// Callback to handle the completion of a dragged item.
  final void Function()? onDragSectionCompleted;

  /// Callback to handle the end of a dragged item.
  final void Function(DraggableDetails)? onDragSectionEnd;

  /// Callback to handle the start of a dragged item.
  final void Function()? onDragSectionStarted;

  /// Callback to handle the move a pointer on the page.
  /// Useful to scroll the page when dragging a section to the edges.
  final void Function(PointerMoveEvent)? onPointerMove;

  @override
  Widget build(BuildContext context) {
    final List<Widget> slivers = [
      // Sliver issue: https://github.com/flutter/flutter/issues/55170
      SliverToBoxAdapter(),
      if (modularPage.hasAppBar) ApplicationBar(),
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
          onDragSectionStarted: onDragSectionStarted,
          onDragSectionCompleted: onDragSectionCompleted,
          onDragSectionEnd: onDragSectionEnd,
          onDraggableSectionCanceled: onDraggableSectionCanceled,
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

    return Scaffold(
      floatingActionButton: ProfilePageFAB(
        editMode: editMode,
        isOwner: isOwner,
        onToggleEditMode: onToggleEditMode,
        scrollController: scrollController,
        showFabToTop: showFabToTop,
      ),
      body: Listener(
        onPointerMove: onPointerMove,
        child: Stack(
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
      ),
    );
  }
}
