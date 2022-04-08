import 'package:artbooking/components/popup_menu/popup_menu_item_icon.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/enums/enum_section_action.dart';
import 'package:artbooking/types/section.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

/// A spacing section of 100px height and window screen width.
class TitleDescriptionSection extends StatelessWidget {
  const TitleDescriptionSection({
    Key? key,
    required this.index,
    required this.section,
    this.onPopupMenuItemSelected,
    this.popupMenuEntries = const [],
    this.isLast = false,
    this.usingAsDropTarget = false,
    this.isOwner = false,
  }) : super(key: key);

  final bool isLast;

  /// True if the current authenticated user is the owner.
  final bool isOwner;
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
            padding: const EdgeInsets.only(bottom: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: InkWell(
                    onTap: isOwner ? onTapTitle : null,
                    child: titleChild(),
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

  Widget titleChild() {
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
                  style: Utilities.fonts.style(
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

    return Column(
      children: [
        Container(
          height: 8.0,
          color: Color(section.borderColor),
        ),
        Padding(
          padding: const EdgeInsets.only(
            top: 12.0,
          ),
          child: Opacity(
            opacity: 0.6,
            child: Text(
              section.name,
              textAlign: TextAlign.center,
              style: Utilities.fonts.style(
                fontSize: 18.0,
                fontWeight: FontWeight.w700,
                color: Color(section.textColor),
              ),
            ),
          ),
        ),
        Text(
          section.description,
          textAlign: TextAlign.center,
          overflow: TextOverflow.clip,
          style: Utilities.fonts.style(
            fontSize: 64.0,
            fontWeight: FontWeight.w200,
            color: Color(section.textColor),
          ),
        ),
      ],
    );
  }

  List<PopupMenuItemIcon<EnumSectionAction>> getPopupMenuEntries() {
    var localPopupMenuEntries = popupMenuEntries.sublist(0);

    if (index == 0) {
      localPopupMenuEntries
          .removeWhere((x) => x.value == EnumSectionAction.moveUp);
    }

    if (isLast) {
      localPopupMenuEntries.removeWhere(
        (x) => x.value == EnumSectionAction.moveDown,
      );
    }

    localPopupMenuEntries
        .removeWhere((x) => x.value == EnumSectionAction.rename);
    localPopupMenuEntries
        .removeWhere((x) => x.value == EnumSectionAction.settings);

    localPopupMenuEntries.add(
      PopupMenuItemIcon(
        icon: Icon(UniconsLine.paint_tool),
        textLabel: "edit_background_color".tr(),
        value: EnumSectionAction.editBackgroundColor,
      ),
    );

    localPopupMenuEntries.add(
      PopupMenuItemIcon(
        icon: Icon(UniconsLine.edit_alt),
        textLabel: "title_edit".tr(),
        value: EnumSectionAction.renameTitle,
      ),
    );

    localPopupMenuEntries.add(
      PopupMenuItemIcon(
        icon: Icon(UniconsLine.font),
        textLabel: "text_color_edit".tr(),
        value: EnumSectionAction.editTextColor,
      ),
    );

    localPopupMenuEntries.add(
      PopupMenuItemIcon(
        icon: Icon(UniconsLine.border_out),
        textLabel: "border_color_edit".tr(),
        value: EnumSectionAction.editBorderColor,
      ),
    );

    return localPopupMenuEntries;
  }

  Widget rightPopupMenuButton(BuildContext context) {
    if (!isOwner) {
      return Container();
    }

    final popupMenuEntries = getPopupMenuEntries();

    return Positioned(
      top: 12.0,
      right: 12.0,
      child: PopupMenuButton(
        child: Card(
          elevation: 2.0,
          color: Theme.of(context).backgroundColor,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(UniconsLine.ellipsis_h),
          ),
        ),
        itemBuilder: (_) => popupMenuEntries,
        onSelected: (EnumSectionAction action) {
          onPopupMenuItemSelected?.call(
            action,
            index,
            section,
          );
        },
      ),
    );
  }

  void onTapTitle() {
    onPopupMenuItemSelected?.call(
      EnumSectionAction.rename,
      index,
      section,
    );
  }
}
