import 'package:artbooking/components/texts/page_title.dart';
import 'package:artbooking/screens/atelier/books/my_books_page_actions.dart';
import 'package:artbooking/screens/atelier/books/my_books_page_group_actions.dart';
import 'package:artbooking/screens/atelier/books/my_books_page_title.dart';
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
    this.isOwner = false,
    this.onAddToBook,
    this.onChangedTab,
    this.onChangeGroupVisibility,
    this.onClearSelection,
    this.onConfirmDeleteGroup,
    this.onGoToUserProfile,
    this.onShowCreateBookDialog,
    this.onSelectAll,
    this.onTriggerMultiSelect,
    this.username = "",
  }) : super(key: key);

  /// If true, show owner actions (e.g. create).
  /// Otherwise, hide actions and show username if provided.
  final bool isOwner;

  /// Show actions group if true (perform bulk action on multiple books).
  final bool multiSelectActive;

  /// Selected active page tab.
  final EnumVisibilityTab selectedTab;

  /// Callback fired when an illustration is added to a book.
  final void Function()? onAddToBook;

  /// Callback fired on a book group visibility change.
  final void Function()? onChangeGroupVisibility;

  /// Callback fired when changing page tab.
  final void Function(EnumVisibilityTab)? onChangedTab;

  /// Callback to clear group selection.
  final void Function()? onClearSelection;

  /// Callback to confirm group deletion.
  final void Function()? onConfirmDeleteGroup;

  /// Callback fired to show create book dialog.
  final void Function()? onShowCreateBookDialog;

  /// Callback fired to toggle multi-select.
  final void Function()? onTriggerMultiSelect;

  /// Callback fired to select all displayed books.
  final void Function()? onSelectAll;

  /// Callback fired to navigate to user's profile (when they're not the owner).
  final void Function()? onGoToUserProfile;

  /// Group of book selected.
  final Map<String?, Book> multiSelectedItems;

  /// The user's books owner.
  /// Used if the current authenticated user is not the owner.
  final String username;

  @override
  Widget build(BuildContext context) {
    String subtitleValue = "books_my_subtitle_extended".tr();

    if (!isOwner) {
      subtitleValue = "user_books_page".tr(args: [username]);
    }

    return SliverPadding(
      padding: const EdgeInsets.only(
        top: 60.0,
        left: 64.0,
        bottom: 24.0,
      ),
      sliver: SliverList(
        delegate: SliverChildListDelegate.fixed([
          PageTitle(
            renderSliver: false,
            title: MyBooksPageTitle(
              isOwner: isOwner,
              selectedTab: selectedTab,
              onChangedTab: onChangedTab,
              onGoToUserProfile: onGoToUserProfile,
              username: username,
            ),
            subtitleValue: subtitleValue,
            padding: const EdgeInsets.only(bottom: 16.0),
          ),
          MyBooksPageActions(
            isOwner: isOwner,
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
