import 'package:artbooking/components/buttons/circle_button.dart';
import 'package:artbooking/components/popup_menu/popup_menu_item_icon.dart';
import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/screens/atelier/profile/section_chooser.dart';
import 'package:artbooking/types/drag_data.dart';
import 'package:artbooking/types/enums/enum_navigation_section.dart';
import 'package:artbooking/types/enums/enum_section_action.dart';
import 'package:artbooking/types/enums/enum_select_type.dart';
import 'package:artbooking/types/section.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

/// Wrap a section widget inside a `MouseRegion` to react to hover events
/// (show/hide section control buttons as drag to move or popup menu button).
class SectionWrapper extends StatefulWidget {
  const SectionWrapper({
    Key? key,
    required this.editMode,
    required this.index,
    required this.section,
    required this.sectionCount,
    required this.userId,
    this.onDropSection,
    this.onPopupMenuItemSelected,
    this.popupMenuEntries = const [],
    this.onUpdateSectionItems,
    this.onShowBookDialog,
    this.onShowIllustrationDialog,
    this.onNavigateFromSection,
    this.onDraggableSectionCanceled,
    this.onDragSectionCompleted,
    this.onDragSectionEnd,
    this.onDragSectionStarted,
  }) : super(key: key);

  /// Section's index.
  final int index;

  /// Show edit controls if this is true. Hide controls otherwise.
  final bool editMode;

  /// Section's count.
  /// Useful to quickly find which is the last section in the list.
  final int sectionCount;

  /// Section's data.
  final Section section;

  /// Current authenticated user's id.
  final String userId;

  /// Callback when drag and dropping items on this book card.
  final void Function(
    int dropTargetIndex,
    List<int> dragIndexes,
  )? onDropSection;

  /// List of popup menu item for this section.
  final List<PopupMenuItemIcon<EnumSectionAction>> popupMenuEntries;

  /// Callback fired when a popup menu item has been tapped.
  /// A different action will be performed according to the target item.
  final void Function(EnumSectionAction, int, Section)? onPopupMenuItemSelected;

  /// Callback fired when section's items has been updated.
  final void Function(Section, int, List<String>)? onUpdateSectionItems;

  /// Callback to show book selection.
  final void Function({
    required int index,
    required Section section,
    required EnumSelectType selectType,
  })? onShowBookDialog;

  /// Callback to show illustration selection.
  final void Function({
    required int index,
    int maxPick,
    required Section section,
    required EnumSelectType selectType,
  })? onShowIllustrationDialog;

  /// Callback fired when we navigate from a section.
  final void Function(
    EnumNavigationSection enumNavigationSection,
  )? onNavigateFromSection;

  /// Callback to handle the cancel of a dragged item.
  final void Function(Velocity, Offset)? onDraggableSectionCanceled;

  /// Callback to handle the completion of a dragged item.
  final void Function()? onDragSectionCompleted;

  /// Callback to handle the end of a dragged item.
  final void Function(DraggableDetails)? onDragSectionEnd;

  /// Callback to handle the start of a dragged ite
  final void Function()? onDragSectionStarted;

  @override
  State<SectionWrapper> createState() => _SectionWrapperState();
}

class _SectionWrapperState extends State<SectionWrapper> {
  /// True if the pointer is hover the current widget.
  bool _isHover = false;

  @override
  Widget build(BuildContext context) {
    if (!widget.editMode) {
      return SliverToBoxAdapter(
        child: getSection(usingAsDropTarget: false),
      );
    }

    return SliverToBoxAdapter(
      child: DragTarget<DragData>(
        builder: (BuildContext context, candidateItems, rejectedItems) {
          return getSection(usingAsDropTarget: candidateItems.isNotEmpty);
        },
        onAccept: (DragData dragData) {
          widget.onDropSection?.call(widget.index, [dragData.index]);
        },
        onWillAccept: (DragData? dragData) {
          if (dragData == null) {
            return false;
          }

          if (dragData.type != Section) {
            return false;
          }

          return true;
        },
      ),
    );
  }

  String getDraggableName(Section section) {
    String name = section.name;
    if (name.isEmpty) {
      name = "section_name.${section.id}".tr();
    }

    return name;
  }

  Widget getSection({bool usingAsDropTarget = false}) {
    final Widget sectionWidget = SectionChooser.getSection(
      count: widget.sectionCount,
      editMode: widget.editMode,
      index: widget.index,
      section: widget.section,
      userId: widget.userId,
      usingAsDropTarget: usingAsDropTarget,
      popupMenuEntries: widget.popupMenuEntries,
      onPopupMenuItemSelected: widget.onPopupMenuItemSelected,
      onShowIllustrationDialog: widget.onShowIllustrationDialog,
      onUpdateSectionItems: widget.onUpdateSectionItems,
      isHover: _isHover,
      onNavigateFromSection: widget.onNavigateFromSection,
    );

    if (!widget.editMode) {
      return sectionWidget;
    }

    final bool isMobileSize = Utilities.size.isMobileSize(context);

    return MouseRegion(
      onEnter: (PointerEnterEvent pointerEnterEvent) {
        setState(() => _isHover = true);
      },
      onExit: (PointerExitEvent pointerExitEvent) {
        setState(() => _isHover = false);
      },
      child: Stack(
        children: [
          Card(
            elevation: _isHover ? 10.0 : 0.0,
            margin: _isHover ? const EdgeInsets.all(6.0) : EdgeInsets.zero,
            color: Colors.transparent,
            child: sectionWidget,
          ),
          if (_isHover)
            Positioned(
              top: 24.0,
              right: isMobileSize ? 16.0 : 92.0,
              child: Draggable<DragData>(
                data: DragData(
                  index: widget.index,
                  groupName: "profile-page",
                  type: Section,
                ),
                onDragCompleted: widget.onDragSectionCompleted,
                onDragEnd: widget.onDragSectionEnd,
                onDraggableCanceled: widget.onDraggableSectionCanceled,
                onDragStarted: widget.onDragSectionStarted,
                feedback: Card(
                  elevation: 8.0,
                  color: Constants.colors.clairPink,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 4.0),
                          child: Icon(
                              Utilities.ui.getSectionIcon(widget.section.id)),
                        ),
                        Text(
                          getDraggableName(widget.section),
                          style: Utilities.fonts.body(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                child: CircleButton(
                  onTap: () {},
                  tooltip: "drag_to_move".tr(),
                  radius: 16.0,
                  icon: Icon(
                    UniconsLine.draggabledots,
                    color: Colors.black,
                    size: 16.0,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
