import 'package:artbooking/components/texts/page_title.dart';
import 'package:artbooking/screens/dashboard/illustrations/my_illustrations_page_actions.dart';
import 'package:artbooking/screens/dashboard/illustrations/my_illustrations_page_group_actions.dart';
import 'package:artbooking/screens/dashboard/illustrations/my_illustrations_page_title.dart';
import 'package:artbooking/types/enums/enum_visibility_tab.dart';
import 'package:artbooking/types/illustration/illustration.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

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
  }) : super(key: key);

  final bool multiSelectActive;
  final bool limitThreeInRow;

  final EnumVisibilityTab selectedTab;

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

    return SliverPadding(
      padding: padding,
      sliver: SliverList(
        delegate: SliverChildListDelegate.fixed([
          PageTitle(
            renderSliver: false,
            title: MyIllustrationsPageTitle(
              selectedTab: selectedTab,
              onChangedTab: onChangedTab,
            ),
            subtitleValue: "illustrations_my_subtitle_extended".tr(),
            padding: const EdgeInsets.only(bottom: 4.0),
          ),
          MyIllustrationsPageActions(
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
