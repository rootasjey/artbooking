import 'package:artbooking/components/texts/page_title.dart';
import 'package:artbooking/screens/dashboard/illustrations/my_illustrations_page_actions.dart';
import 'package:artbooking/screens/dashboard/illustrations/my_illustrations_page_group_actions.dart';
import 'package:artbooking/types/illustration/illustration.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class MyIllustrationsPageHeader extends StatelessWidget {
  const MyIllustrationsPageHeader({
    Key? key,
    required this.multiSelectActive,
    this.uploadIllustration,
    this.onTriggerMultiSelect,
    this.onSelectAll,
    this.onClearSelection,
    required this.multiSelectedItems,
    this.onConfirmDeleteGroup,
  }) : super(key: key);

  final bool multiSelectActive;
  final void Function()? uploadIllustration;
  final void Function()? onTriggerMultiSelect;
  final void Function()? onSelectAll;
  final void Function()? onClearSelection;
  final void Function()? onConfirmDeleteGroup;

  final Map<String?, Illustration> multiSelectedItems;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(
        top: 60.0,
        left: 50.0,
        bottom: 24.0,
      ),
      sliver: SliverList(
        delegate: SliverChildListDelegate.fixed([
          PageTitle(
            renderSliver: false,
            titleValue: "illustrations".tr(),
            subtitleValue: "illustrations_subtitle".tr(),
            padding: const EdgeInsets.only(bottom: 16.0),
          ),
          MyIllustrationsPageActions(
            multiSelectActive: multiSelectActive,
            show: multiSelectedItems.isEmpty,
            onTriggerMultiSelect: onTriggerMultiSelect,
            uploadIllustration: uploadIllustration,
          ),
          MyIllustrationsPageGroupActions(
            show: multiSelectedItems.isNotEmpty,
            multiSelectedItems: multiSelectedItems,
            onSelectAll: onSelectAll,
            onClearSelection: onClearSelection,
            onConfirmDeleteGroup: onConfirmDeleteGroup,
          ),
        ]),
      ),
    );
  }
}
