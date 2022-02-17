import 'package:artbooking/components/texts/page_title.dart';
import 'package:artbooking/screens/dashboard/books/my_books_page_actions.dart';
import 'package:artbooking/screens/dashboard/books/my_books_page_group_actions.dart';
import 'package:artbooking/screens/dashboard/books/my_books_page_title.dart';
import 'package:artbooking/types/book/book.dart';
import 'package:artbooking/types/enums/enum_visibility_tab.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class MyBooksPageHeader extends StatelessWidget {
  const MyBooksPageHeader({
    Key? key,
    required this.multiSelectActive,
    required this.multiSelectedItems,
    required this.selectedTab,
    this.onShowCreateBookDialog,
    this.onTriggerMultiSelect,
    this.onSelectAll,
    this.onClearSelection,
    this.onChangedTab,
    this.onAddToBook,
    this.onChangeGroupVisibility,
    this.onConfirmDeleteGroup,
  }) : super(key: key);

  final bool multiSelectActive;
  final EnumVisibilityTab selectedTab;
  final void Function()? onAddToBook;
  final void Function()? onChangeGroupVisibility;
  final void Function()? onConfirmDeleteGroup;
  final void Function()? onShowCreateBookDialog;
  final void Function()? onTriggerMultiSelect;
  final void Function()? onSelectAll;
  final void Function()? onClearSelection;
  final void Function(EnumVisibilityTab)? onChangedTab;

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
            title: MyBooksPageTitle(
              selectedTab: selectedTab,
              onChangedTab: onChangedTab,
            ),
            subtitleValue: "books_my_subtitle_extended".tr(),
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
            onAddToBook: onAddToBook,
            onChangeGroupVisibility: onChangeGroupVisibility,
            onConfirmDeleteGroup: onConfirmDeleteGroup,
          ),
        ]),
      ),
    );
  }
}
