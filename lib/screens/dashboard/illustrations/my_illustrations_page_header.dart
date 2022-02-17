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
    this.onAddToBook,
    this.onChangeVisibility,
  }) : super(key: key);

  final bool multiSelectActive;
  final bool limitThreeInRow;

  final EnumVisibilityTab selectedTab;

  final void Function()? onAddToBook;
  final void Function(EnumVisibilityTab)? onChangedTab;
  final void Function()? onChangeVisibility;
  final void Function()? onClearSelection;
  final void Function()? onConfirmDeleteGroup;
  final void Function()? onSelectAll;
  final void Function()? onTriggerMultiSelect;
  final void Function()? onUpdateLayout;
  final void Function()? onUploadIllustration;

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
            onAddToBook: onAddToBook,
            onChangeVisibility: onChangeVisibility,
          ),
        ]),
      ),
    );
  }
}
