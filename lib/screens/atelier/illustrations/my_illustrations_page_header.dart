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
    required this.multiSelectActive,
    required this.multiSelectedItems,
    required this.selectedTab,
    required this.limitThreeInRow,
    this.onUploadIllustration,
    this.onTriggerMultiSelect,
    this.onSelectAll,
    this.onClearSelection,
    this.onConfirmDeleteGroup,
    this.onChangedTab,
    this.onUpdateLayout,
    this.onAddGroupToBook,
    this.onChangeGroupVisibility,
    this.showBackButton = false,
    this.isOwner = false,
    this.username = "",
    this.onGoToUserProfile,
  }) : super(key: key);

  final bool isOwner;
  final bool multiSelectActive;
  final bool limitThreeInRow;
  final bool showBackButton;

  final EnumVisibilityTab selectedTab;

  final String username;

  /// Add a group of illustrations to a book.
  final void Function()? onAddGroupToBook;

  /// Trigger on tab change.
  final void Function(EnumVisibilityTab)? onChangedTab;

  /// Update visibility of a group of illustrations.
  final void Function()? onChangeGroupVisibility;

  /// Cancel multiple section.
  final void Function()? onClearSelection;

  /// Show a popup to confirm illustrations group deletion.
  final void Function()? onConfirmDeleteGroup;

  /// Select all displayed illustrations.
  final void Function()? onSelectAll;

  /// Toggle multi-select
  final void Function()? onTriggerMultiSelect;

  /// Limit illustrations to 3-in-a-row.
  final void Function()? onUpdateLayout;

  /// Create a new illustration.
  final void Function()? onUploadIllustration;

  /// Selected items.
  final Map<String?, Illustration> multiSelectedItems;

  final void Function()? onGoToUserProfile;

  @override
  Widget build(BuildContext context) {
    EdgeInsets padding = const EdgeInsets.only(
      top: 60.0,
      left: 50.0,
      bottom: 24.0,
    );

    if (limitThreeInRow) {
      padding = const EdgeInsets.only(
        top: 60.0,
        left: 120.0,
        bottom: 24.0,
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
                  tooltip: "back".tr(),
                  onTap: () => Utilities.navigation.back(context),
                  icon: Icon(UniconsLine.arrow_left, color: Colors.black),
                ),
              ),
            ),
          PageTitle(
            renderSliver: false,
            title: MyIllustrationsPageTitle(
              isOwner: isOwner,
              selectedTab: selectedTab,
              onChangedTab: onChangedTab,
              username: username,
              onGoToUserProfile: onGoToUserProfile,
            ),
            subtitleValue: subtitleValue,
            padding: const EdgeInsets.only(bottom: 4.0),
          ),
          MyIllustrationsPageActions(
            isOwner: isOwner,
            multiSelectActive: multiSelectActive,
            show: multiSelectedItems.isEmpty,
            onTriggerMultiSelect: onTriggerMultiSelect,
            onUploadIllustration: onUploadIllustration,
            limitThreeInRow: limitThreeInRow,
            onUpdateLayout: onUpdateLayout,
          ),
          MyIllustrationsPageGroupActions(
            show: multiSelectedItems.isNotEmpty,
            multiSelectedItems: multiSelectedItems,
            onSelectAll: onSelectAll,
            onClearSelection: onClearSelection,
            onConfirmDeleteGroup: onConfirmDeleteGroup,
            onAddToBook: onAddGroupToBook,
            onChangeGroupVisibility: onChangeGroupVisibility,
          ),
        ]),
      ),
    );
  }
}
