import 'package:artbooking/components/cards/vertical_card.dart';
import 'package:artbooking/components/popup_menu/popup_menu_item_icon.dart';
import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/router/locations/atelier_location.dart';
import 'package:artbooking/screens/atelier/profile/popup_menu_button_section.dart';
import 'package:artbooking/types/enums/enum_section_action.dart';
import 'package:artbooking/types/section.dart';
import 'package:beamer/beamer.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

/// A spacing section of 100px height and window screen width.
class RowFeaturesSection extends StatelessWidget {
  const RowFeaturesSection({
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

    final double height = 420.0;

    return Padding(
      padding: outerPadding,
      child: Stack(
        children: [
          Container(
            decoration: boxDecoration,
            padding: const EdgeInsets.only(bottom: 60.0, left: 80.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                titleWidget(context),
                SizedBox(
                  height: height + 100.0,
                  child: ListView(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(vertical: 32.0),
                    children: [
                      VerticalCard(
                        icon: Icon(
                          UniconsLine.ruler_combined,
                          size: 32.0,
                          color: Constants.colors.tertiary,
                        ),
                        title: "app_features.atelier.title".tr(),
                        description: "app_features.atelier.description".tr(),
                        onTap: () => Beamer.of(context).beamToNamed(
                          AtelierLocationContent.activityRoute,
                        ),
                      ),
                      VerticalCard(
                        icon: Icon(
                          UniconsLine.users_alt,
                          size: 32.0,
                          color: Constants.colors.primary,
                        ),
                        title: "app_features.community.title".tr(),
                        description: "app_features.community.description".tr(),
                        margin: const EdgeInsets.symmetric(horizontal: 32.0),
                      ),
                      VerticalCard(
                        icon: Icon(
                          UniconsLine.heart,
                          size: 32.0,
                          color: Constants.colors.secondary,
                        ),
                        title: "app_features.target_audience.title".tr(),
                        description:
                            "app_features.target_audience.description".tr(),
                      ),
                    ],
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

  Widget titleWidget(BuildContext context) {
    if (section.name.isEmpty && section.description.isEmpty) {
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

    final double width = MediaQuery.of(context).size.width;

    return InkWell(
      onTap: editMode ? onTapTitle : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 8.0,
            color: Color(section.borderColor),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 24.0),
            child: Opacity(
              opacity: 0.4,
              child: Text(
                section.name,
                style: Utilities.fonts.body3(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w700,
                  color: Color(section.textColor),
                ),
              ),
            ),
          ),
          Container(
            width: width / 1.5,
            child: Text(
              section.description,
              overflow: TextOverflow.clip,
              style: Utilities.fonts.body(
                fontSize: 54.0,
                fontWeight: FontWeight.w200,
                color: Color(section.textColor),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Wrap(
              spacing: 12.0,
              children: [
                Container(
                  height: 8.0,
                  width: 8.0,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                Container(
                  height: 8.0,
                  width: 8.0,
                  decoration: BoxDecoration(
                    color: Constants.colors.tertiary,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                Container(
                  height: 8.0,
                  width: 8.0,
                  decoration: BoxDecoration(
                    color: Theme.of(context).secondaryHeaderColor,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
      EnumSectionAction.rename,
      index,
      section,
    );
  }
}
