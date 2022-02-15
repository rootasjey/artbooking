import 'package:artbooking/components/texts/page_title.dart';
import 'package:artbooking/screens/dashboard/books/my_books_page_actions.dart';
import 'package:artbooking/screens/dashboard/books/my_books_page_group_actions.dart';
import 'package:artbooking/types/book/book.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class MyBooksPageHeader extends StatelessWidget {
  const MyBooksPageHeader({
    Key? key,
    required this.multiSelectActive,
    this.onShowCreateBookDialog,
    this.onTriggerMultiSelect,
    this.onSelectAll,
    required this.multiSelectedItems,
    this.onClearSelection,
  }) : super(key: key);

  final bool multiSelectActive;
  final void Function()? onShowCreateBookDialog;
  final void Function()? onTriggerMultiSelect;
  final void Function()? onSelectAll;
  final void Function()? onClearSelection;

  final Map<String?, Book> multiSelectedItems;

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
            titleValue: "books".tr(),
            subtitleValue: "books_subtitle".tr(),
            padding: const EdgeInsets.only(bottom: 16.0),
          ),
          MyBooksPageActions(
            show: multiSelectedItems.isEmpty,
            multiSelectActive: multiSelectActive,
            onTriggerMultiSelect: onTriggerMultiSelect,
            onShowCreateBookDialog: onShowCreateBookDialog,
          ),
          MyBooksPageGroupActions(
            show: multiSelectedItems.isNotEmpty,
            multiSelectedItems: multiSelectedItems,
            onSelectAll: onSelectAll,
            onClearSelection: onClearSelection,
          ),
        ]),
      ),
    );
  }
}