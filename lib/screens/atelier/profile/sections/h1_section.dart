import 'package:artbooking/components/popup_menu/popup_menu_item_icon.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/screens/atelier/profile/popup_menu_button_section.dart';
import 'package:artbooking/types/enums/enum_section_action.dart';
import 'package:artbooking/types/section.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

/// A spacing section of 100px height and window screen width.
class H1Section extends StatelessWidget {
  const H1Section({
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

    return Padding(
      padding: outerPadding,
      child: Stack(
        children: [
          Container(
            decoration: boxDecoration,
            padding: const EdgeInsets.all(
              24.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: InkWell(
                    onTap: editMode ? onTapTitle : null,
                    child: textChild(),
                  ),
                ),
              ],
            ),
          ),
          rightPopupMenuButton(context),
        ],
      ),
    );
  }

  Widget textChild() {
    if (section.name.isEmpty) {
      return Center(
        child: Opacity(
          opacity: 0.6,
          child: DottedBorder(
            strokeWidth: 3.0,
            borderType: BorderType.RRect,
            radius: Radius.circular(4),
            dashPattern: [8, 4],
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 8.0,
                ),
                child: Text(
                  "text_enter".tr(),
                  style: Utilities.fonts.body(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Text(
      section.name,
      textAlign: TextAlign.center,
      style: Utilities.fonts.body(
        fontSize: 64.0,
        fontWeight: FontWeight.w800,
        color: Color(section.textColor),
      ),
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

    _popupMenuEntries.add(
      PopupMenuItemIcon(
        icon: Icon(UniconsLine.edit_alt),
        textLabel: "title_edit".tr(),
        value: EnumSectionAction.renameTitle,
      ),
    );

    _popupMenuEntries.add(
      PopupMenuItemIcon(
        icon: Icon(UniconsLine.font),
        textLabel: "text_color_edit".tr(),
        value: EnumSectionAction.editTextColor,
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

  void onTapTitle() {
    onPopupMenuItemSelected?.call(
      EnumSectionAction.renameTitle,
      index,
      section,
    );
  }
}
