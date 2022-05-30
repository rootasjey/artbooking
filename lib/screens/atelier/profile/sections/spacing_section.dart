import 'package:artbooking/components/popup_menu/popup_menu_item_icon.dart';
import 'package:artbooking/screens/atelier/profile/popup_menu_button_section.dart';
import 'package:artbooking/types/enums/enum_section_action.dart';
import 'package:artbooking/types/section.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

/// A spacing section of 100px height and window screen width.
class SpacingSection extends StatelessWidget {
  const SpacingSection({
    Key? key,
    required this.index,
    required this.section,
    this.onPopupMenuItemSelected,
    this.popupMenuEntries = const [],
    this.isLast = false,
    this.usingAsDropTarget = false,
    this.editMode = false,
    this.isHover = false,
  }) : super(key: key);

  /// If true, the current authenticated user is the owner and
  /// this section can be edited.
  final bool editMode;
  final bool isHover;
  final bool isLast;

  final bool usingAsDropTarget;

  /// Section's position in the layout (e.g. 0 is the first).
  final int index;

  final List<PopupMenuItemIcon<EnumSectionAction>> popupMenuEntries;

  final Section section;

  final void Function(EnumSectionAction, int, Section)? onPopupMenuItemSelected;
  @override
  Widget build(BuildContext context) {
    final EdgeInsets outerPadding =
        usingAsDropTarget ? const EdgeInsets.all(4.0) : EdgeInsets.zero;

    final BoxDecoration boxDecoration = usingAsDropTarget
        ? BoxDecoration(
            borderRadius: BorderRadius.circular(4.0),
            border: Border.all(
              color: Theme.of(context).primaryColor,
              width: 3.0,
            ),
            color: Color(section.backgroundColor),
          )
        : BoxDecoration(
            color: Color(section.backgroundColor),
          );

    return Stack(
      children: [
        Padding(
          padding: outerPadding,
          child: Container(
            decoration: boxDecoration,
            child: SizedBox(
              height: 64.0,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
              ),
            ),
          ),
        ),
        rightPopupMenuButton(context),
      ],
    );
  }

  List<PopupMenuItemIcon<EnumSectionAction>> getPopupMenuEntries() {
    var _popupMenuEntries = popupMenuEntries.sublist(0);

    if (index == 0) {
      _popupMenuEntries.removeWhere((x) => x.value == EnumSectionAction.moveUp);
    }

    if (isLast) {
      _popupMenuEntries.removeWhere(
        (x) => x.value == EnumSectionAction.moveDown,
      );
    }

    _popupMenuEntries.removeWhere((x) => x.value == EnumSectionAction.rename);
    _popupMenuEntries.removeWhere((x) => x.value == EnumSectionAction.settings);

    _popupMenuEntries.add(
      PopupMenuItemIcon(
        icon: Icon(UniconsLine.paint_tool),
        textLabel: "edit_background_color".tr(),
        value: EnumSectionAction.editBackgroundColor,
      ),
    );

    return _popupMenuEntries;
  }

  Widget rightPopupMenuButton(BuildContext context) {
    if (!editMode) {
      return Container();
    }

    return PopupMenuButtonSection(
      show: isHover,
      itemBuilder: (_) => getPopupMenuEntries(),
      onSelected: (EnumSectionAction action) {
        onPopupMenuItemSelected?.call(
          action,
          index,
          section,
        );
      },
    );
  }
}
