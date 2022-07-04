import 'package:artbooking/components/footer/footer.dart';
import 'package:artbooking/components/popup_menu/popup_menu_icon.dart';
import 'package:artbooking/components/popup_menu/popup_menu_item_icon.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/screens/atelier/profile/popup_menu_button_section.dart';
import 'package:artbooking/types/enums/enum_section_action.dart';
import 'package:artbooking/types/popup_item_section.dart';
import 'package:artbooking/types/section.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';

/// A spacing section of 100px height and window screen width.
class FooterSection extends StatelessWidget {
  const FooterSection({
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

  final bool isLast;
  final bool isHover;
  final bool usingAsDropTarget;

  /// Section's position in the layout (e.g. 0 is the first).
  final int index;

  final List<PopupMenuItemIcon<EnumSectionAction>> popupMenuEntries;

  final Section section;

  final void Function(EnumSectionAction, int, Section)? onPopupMenuItemSelected;

  @override
  Widget build(BuildContext context) {
    final bool isMobileSize = Utilities.size.isMobileSize(context);

    if (isMobileSize) {
      return Container();
    }

    final EdgeInsets outerPadding =
        usingAsDropTarget ? const EdgeInsets.all(4.0) : EdgeInsets.zero;

    final BoxDecoration boxDecoration = usingAsDropTarget
        ? BoxDecoration(
            borderRadius: BorderRadius.circular(4.0),
            border: Border.all(
              color: Theme.of(context).primaryColor,
              width: 3.0,
            ),
            color: Colors.transparent,
          )
        : BoxDecoration(
            color: Colors.transparent,
          );

    final Widget footer = Footer();

    // Mobile footer.
    // The following code is commented
    // as it's simpler to completely hide the footer.
    // --------------
    // if (isMobileSize) {
    //   return Stack(
    //     children: [
    //       Container(
    //         padding: outerPadding,
    //         color: Color(section.backgroundColor),
    //         child: footer,
    //       ),
    //       rightPopupMenuButton(context),
    //     ],
    //   );
    // }

    return Stack(
      children: [
        Container(
          padding: outerPadding,
          color: Color(section.backgroundColor),
          child: Stack(
            children: [
              WaveWidget(
                config: CustomConfig(
                  colors: [
                    Colors.white70,
                    Colors.white54,
                    Colors.white30,
                    Colors.white24,
                  ],
                  durations: [35000, 19440, 10800, 6000],
                  heightPercentages: [0.20, 0.23, 0.25, 0.30],
                ),
                size: Size(double.maxFinite, 640.0),
              ),
              Container(
                decoration: boxDecoration,
                padding: const EdgeInsets.all(24.0),
                child: footer,
              ),
            ],
          ),
        ),
        rightPopupMenuButton(context),
      ],
    );
  }

  List<PopupMenuItemSection> getPopupMenuEntries() {
    final List<PopupMenuItemSection> localPopupMenuEntries =
        popupMenuEntries.sublist(0);

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
      ..removeWhere((x) => x.value == EnumSectionAction.rename)
      ..removeWhere((x) => x.value == EnumSectionAction.settings);

    final int millisecondsDelay = localPopupMenuEntries.length * 25;

    localPopupMenuEntries.add(
      PopupMenuItemIcon(
        icon: PopupMenuIcon(UniconsLine.paint_tool),
        textLabel: "edit_background_color".tr(),
        value: EnumSectionAction.editBackgroundColor,
        delay: Duration(milliseconds: millisecondsDelay * 1),
      ),
    );

    localPopupMenuEntries.add(
      PopupMenuItemIcon(
        icon: PopupMenuIcon(UniconsLine.edit_alt),
        textLabel: "title_edit".tr(),
        value: EnumSectionAction.renameTitle,
        delay: Duration(milliseconds: millisecondsDelay * 2),
      ),
    );

    localPopupMenuEntries.add(
      PopupMenuItemIcon(
        icon: PopupMenuIcon(UniconsLine.font),
        textLabel: "text_color_edit".tr(),
        value: EnumSectionAction.editTextColor,
        delay: Duration(milliseconds: millisecondsDelay * 3),
      ),
    );

    return localPopupMenuEntries;
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
