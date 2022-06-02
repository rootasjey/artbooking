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
    required this.scrollController,
    required this.userId,
    this.onDropSection,
    this.onPopupMenuItemSelected,
    this.popupMenuEntries = const [],
    this.onUpdateSectionItems,
    this.onShowBookDialog,
    this.onShowIllustrationDialog,
    this.onNavigateFromSection,
  }) : super(key: key);

  final int index;

  /// Section's count.
  /// Useful to quickly find which is the last section in the list.
  final int sectionCount;
  final bool editMode;
  final Section section;
  final ScrollController scrollController;
  final String userId;

  /// Callback when drag and dropping items on this book card.
  final void Function(
    int dropTargetIndex,
    List<int> dragIndexes,
  )? onDropSection;

  final List<PopupMenuItemIcon<EnumSectionAction>> popupMenuEntries;
  final void Function(EnumSectionAction, int, Section)? onPopupMenuItemSelected;
  final void Function(Section, int, List<String>)? onUpdateSectionItems;

  final void Function({
    required int index,
    required Section section,
    required EnumSelectType selectType,
  })? onShowBookDialog;

  final void Function({
    required int index,
    int maxPick,
    required Section section,
    required EnumSelectType selectType,
  })? onShowIllustrationDialog;

  final void Function(
    EnumNavigationSection enumNavigationSection,
  )? onNavigateFromSection;

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
      onUpdateSectionItems: widget.onUpdateSectionItems,
      isHover: _isHover,
      onNavigateFromSection: widget.onNavigateFromSection,
    );

    if (!widget.editMode) {
      return sectionWidget;
    }

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
              right: 92.0,
              child: Draggable<DragData>(
                data: DragData(
                  index: widget.index,
                  groupName: "profile-page",
                  type: Section,
                ),
                onDragUpdate: (details) => onDragUpdateSection(
                  context: context,
                  details: details,
                  scrollController: widget.scrollController,
                ),
                feedback: Card(
                  elevation: 2.0,
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

  void onDragUpdateSection({
    required BuildContext context,
    required DragUpdateDetails details,
    required ScrollController scrollController,
  }) async {
    /// Amount of offset to jump when dragging an element to the edge.
    final double jumpOffset = 200.0;

    /// Distance to the edge where the scroll viewer starts to jump.
    final double edgeDistance = 50.0;

    final position = details.globalPosition;

    if (position.dy < edgeDistance) {
      if (scrollController.offset <= 0) {
        return;
      }

      await scrollController.animateTo(
        scrollController.offset - jumpOffset,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );

      return;
    }

    final windowHeight = MediaQuery.of(context).size.height;
    if (windowHeight - edgeDistance < position.dy) {
      if (scrollController.position.atEdge && scrollController.offset != 0) {
        return;
      }

      await scrollController.animateTo(
        scrollController.offset + jumpOffset,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }
}
