import 'package:artbooking/components/buttons/circle_button.dart';
import 'package:artbooking/components/texts/page_title.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/screens/atelier/illustrations/my_illustrations_page_actions.dart';
import 'package:artbooking/screens/atelier/illustrations/my_illustrations_page_group_actions.dart';
import 'package:artbooking/screens/atelier/illustrations/my_illustrations_page_title.dart';
import 'package:artbooking/types/enums/enum_visibility_tab.dart';
import 'package:artbooking/types/illustration/illustration.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class MyIllustrationsPageHeader extends StatelessWidget {
  const MyIllustrationsPageHeader({
    Key? key,
    required this.draggingActive,
    required this.limitThreeInRow,
    required this.multiSelectActive,
    required this.multiSelectedItems,
    required this.selectedTab,
    this.isOwner = false,
    this.isMobileSize = false,
    this.onAddGroupToBook,
    this.onChangedTab,
    this.onChangeGroupVisibility,
    this.onClearSelection,
    this.onConfirmDeleteGroup,
    this.onGoToUserProfile,
    this.onSelectAll,
    this.onUploadIllustration,
    this.onToggleDrag,
    this.onTriggerMultiSelect,
    this.onUpdateLayout,
    this.showBackButton = false,
    this.username = "",
  }) : super(key: key);

  /// (Mobile specific) If true, long pressing a card will start a drag.
  /// Otherwise, long pressing a card will display a context menu.
  final bool draggingActive;

  /// If true, this widget adapt its layout to small screens.
  final bool isMobileSize;

  /// If true, show owner actions (e.g. create).
  /// Otherwise, hide actions and show username if provided.
  final bool isOwner;

  /// Show actions group if true (perform bulk action on multiple books).
  final bool multiSelectActive;

  /// If true, set additinal padding on header
  /// to match 3 illustration a row layout.
  final bool limitThreeInRow;

  /// Display back button if true.
  final bool showBackButton;

  /// Selected active page tab.
  final EnumVisibilityTab selectedTab;

  /// Callback fired to add a group of illustrations to a book.
  final void Function()? onAddGroupToBook;

  /// Callback fired when changing page tab.
  final void Function(EnumVisibilityTab)? onChangedTab;

  /// Callback fired on an illustration group visibility change.
  final void Function()? onChangeGroupVisibility;

  /// Callback to cancel group section.
  final void Function()? onClearSelection;

  /// Callback showing a popup to confirm illustrations group deletion.
  final void Function()? onConfirmDeleteGroup;

  /// Callback fired to select all displayed illustrations.
  final void Function()? onSelectAll;

  /// Callback fired when activate/deactivate drag status.
  final void Function()? onToggleDrag;

  /// Callback fired to toggle multi-select.
  final void Function()? onTriggerMultiSelect;

  /// Callback to toggle the 3-in-a-row limit.
  final void Function()? onUpdateLayout;

  /// Callback fired to upload a new illustration.
  final void Function()? onUploadIllustration;

  /// Group of illustrations selected.
  final Map<String?, Illustration> multiSelectedItems;

  /// Callback fired to navigate to user's profile (when they're not the owner).
  final void Function()? onGoToUserProfile;

  /// The user's illustrations owner.
  /// Used if the current authenticated user is not the owner.
  final String username;
  @override
  Widget build(BuildContext context) {
    EdgeInsets padding = EdgeInsets.only(
      bottom: 24.0,
      left: isMobileSize ? 12.0 : 50.0,
      top: isMobileSize ? 24.0 : 60.0,
    );

    if (limitThreeInRow) {
      padding = EdgeInsets.only(
        bottom: 24.0,
        left: isMobileSize ? 12.0 : 120.0,
        top: isMobileSize ? 24.0 : 60.0,
      );
    }

    String subtitleValue = "illustrations_my_subtitle_extended".tr();

    if (!isOwner) {
      subtitleValue = "user_illustrations_page".tr(args: [username]);
    }

    return SliverPadding(
      padding: padding,
      sliver: SliverList(
        delegate: SliverChildListDelegate.fixed([
          if (showBackButton)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: CircleButton(
                  icon: Icon(UniconsLine.arrow_left, color: Colors.black),
                  onTap: () => Utilities.navigation.back(context),
                  tooltip: "back".tr(),
                ),
              ),
            ),
          PageTitle(
            isMobileSize: isMobileSize,
            renderSliver: false,
            title: MyIllustrationsPageTitle(
              isMobileSize: isMobileSize,
              isOwner: isOwner,
              onChangedTab: onChangedTab,
              onGoToUserProfile: onGoToUserProfile,
              selectedTab: selectedTab,
              username: username,
            ),
            subtitleValue: subtitleValue,
            padding: const EdgeInsets.only(bottom: 16.0),
          ),
          MyIllustrationsPageActions(
            draggingActive: draggingActive,
            isMobileSize: isMobileSize,
            isOwner: isOwner,
            limitThreeInRow: limitThreeInRow,
            multiSelectActive: multiSelectActive,
            onToggleDrag: onToggleDrag,
            onTriggerMultiSelect: onTriggerMultiSelect,
            onUpdateLayout: onUpdateLayout,
            onUploadIllustration: onUploadIllustration,
            show: multiSelectedItems.isEmpty,
          ),
          MyIllustrationsPageGroupActions(
            isMobileSize: isMobileSize,
            multiSelectedItems: multiSelectedItems,
            onAddToBook: onAddGroupToBook,
            onChangeGroupVisibility: onChangeGroupVisibility,
            onClearSelection: onClearSelection,
            onConfirmDeleteGroup: onConfirmDeleteGroup,
            onSelectAll: onSelectAll,
            show: multiSelectedItems.isNotEmpty,
          ),
        ]),
      ),
    );
  }
}
