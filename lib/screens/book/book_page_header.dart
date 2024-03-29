import 'package:artbooking/screens/book/book_page_actions.dart';
import 'package:artbooking/screens/book/book_page_group_actions.dart';
import 'package:artbooking/screens/book/book_square_cover.dart';
import 'package:artbooking/screens/book/book_wide_cover.dart';
import 'package:artbooking/types/book/book.dart';
import 'package:artbooking/types/book/popup_entry_book.dart';
import 'package:artbooking/types/enums/enum_book_item_action.dart';
import 'package:artbooking/types/enums/enum_content_visibility.dart';
import 'package:artbooking/types/illustration_map.dart';
import 'package:flutter/material.dart';

class BookPageHeader extends StatelessWidget {
  const BookPageHeader({
    Key? key,
    required this.book,
    required this.multiSelectedItems,
    this.authenticated = false,
    this.draggingActive = false,
    this.forceMultiSelect = false,
    this.isMobileSize = false,
    this.isOwner = false,
    this.liked = false,
    this.onAddToBook,
    this.onClearMultiSelect,
    this.onConfirmRemoveGroup,
    this.onConfirmDeleteBook,
    this.onCoverPopupMenuItemSelected,
    this.onLike,
    this.onMultiSelectAll,
    this.onShareBook,
    this.onShowDatesDialog,
    this.onShowRenameBookDialog,
    this.onToggleDrag,
    this.onToggleMultiSelect,
    this.onUpdateVisibility,
    this.onUploadToThisBook,
    this.coverPopupMenuEntries = const [],
    this.heroTag = "",
  }) : super(key: key);

  /// Main page data.
  final Book book;

  /// (Mobile specific) If true, long pressing a card will start a drag.
  /// Otherwise, long pressing a card will display a context menu.
  final bool draggingActive;

  /// If true, this widget adapt its layout to small screens.
  final bool isMobileSize;

  /// True if the book is liked by the current authenticated user.
  final bool liked;

  /// True if the current authenticated user is the owner.
  final bool isOwner;

  /// True if the current user is authenticated.
  final bool authenticated;

  /// If true, illustrations in this book can be selected in group.
  final bool forceMultiSelect;

  /// Callback fired when an illustration is added to a book.
  final void Function()? onAddToBook;

  /// Callback fired when multiple selection is cleared.
  final void Function()? onClearMultiSelect;

  /// Callback fired when (illustrations) selection group is removed/deleted.
  final void Function()? onConfirmRemoveGroup;

  /// Callback showing a popup to confirm book deletion.
  final void Function()? onConfirmDeleteBook;

  /// Callback fired when the book is liked.
  final void Function()? onLike;

  /// Callback fired when all illustrations inside the book are selected.
  final void Function()? onMultiSelectAll;

  /// Callback fired when one of the popup menu item entries is selected.
  final void Function(
    EnumBookItemAction,
    int,
    Book,
  )? onCoverPopupMenuItemSelected;

  /// Callback fired when we switch on/off multiselect.
  final void Function()? onToggleMultiSelect;

  /// Callback fired when we want to show book's creation & last updated dates.
  final void Function()? onShowDatesDialog;

  /// Callback showing an input dialog to rename this book.
  final void Function()? onShowRenameBookDialog;

  /// Callback fired when activate/deactivate drag status.
  final void Function()? onToggleDrag;

  /// Callback fired when a file is uploaded and added to this book.
  final void Function()? onUploadToThisBook;

  /// Callback fired when the book's visibility is updated.
  final void Function(
    EnumContentVisibility contentVisibility,
  )? onUpdateVisibility;

  /// Callback showing a popup/bottom sheet to share the target book
  /// on social network, by link or any other means.
  final void Function()? onShareBook;

  /// Currently selected illustrations.
  final IllustrationMap multiSelectedItems;

  /// List of popup items for book's cover.
  final List<PopupEntryBook> coverPopupMenuEntries;

  /// Custom hero tag (if `book.id` default tag is not unique).
  final String heroTag;

  @override
  Widget build(BuildContext context) {
    final String bookHeroTag = heroTag.isNotEmpty ? heroTag : book.id;

    final Widget cover = isMobileSize
        ? BookWideCover(
            authenticated: authenticated,
            book: book,
            bookHeroTag: bookHeroTag,
            index: 0,
            liked: liked,
            onDoubleTap: onLike,
            onLike: onLike,
            onPopupMenuItemSelected: onCoverPopupMenuItemSelected,
            onShowDatesDialog: onShowDatesDialog,
            popupMenuEntries: coverPopupMenuEntries,
            useBottomSheet: isMobileSize,
          )
        : BookSquareCover(
            authenticated: authenticated,
            book: book,
            bookHeroTag: bookHeroTag,
            index: 0,
            liked: liked,
            onLike: onLike,
            onPopupMenuItemSelected: onCoverPopupMenuItemSelected,
            onShowDatesDialog: onShowDatesDialog,
            popupMenuEntries: coverPopupMenuEntries,
          );

    return SliverPadding(
      padding: EdgeInsets.only(
        top: isMobileSize ? 24.0 : 60.0,
        left: isMobileSize ? 0.0 : 50.0,
        bottom: 24.0,
      ),
      sliver: SliverList(
        delegate: SliverChildListDelegate.fixed([
          cover,
          if (isOwner)
            Padding(
              padding: const EdgeInsets.only(top: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  BookPageActions(
                    draggingActive: draggingActive,
                    forceMultiSelect: forceMultiSelect,
                    isMobileSize: isMobileSize,
                    multiSelectedItems: multiSelectedItems,
                    onConfirmDeleteBook: onConfirmDeleteBook,
                    onToggleMultiSelect: onToggleMultiSelect,
                    onShareBook: onShareBook,
                    onShowRenameBookDialog: onShowRenameBookDialog,
                    onToggleDrag: onToggleDrag,
                    onUploadToThisBook: onUploadToThisBook,
                    onUpdateVisibility: onUpdateVisibility,
                    visible: multiSelectedItems.isEmpty,
                    visibility: book.visibility,
                  ),
                  BookPageGroupActions(
                    isMobileSize: isMobileSize,
                    onAddToBook: onAddToBook,
                    onClearMultiSelect: onClearMultiSelect,
                    onConfirmRemoveGroup: onConfirmRemoveGroup,
                    onMultiSelectAll: onMultiSelectAll,
                    multiSelectedItems: multiSelectedItems,
                    visible: multiSelectedItems.isNotEmpty,
                  ),
                ],
              ),
            ),
        ]),
      ),
    );
  }
}
