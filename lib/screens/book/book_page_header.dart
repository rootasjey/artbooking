import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/screens/book/book_page_actions.dart';
import 'package:artbooking/screens/book/book_page_group_actions.dart';
import 'package:artbooking/screens/book/book_square_cover.dart';
import 'package:artbooking/types/book/book.dart';
import 'package:artbooking/types/book/popup_entry_book.dart';
import 'package:artbooking/types/enums/enum_book_item_action.dart';
import 'package:artbooking/types/enums/enum_content_visibility.dart';
import 'package:artbooking/types/illustration_map.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jiffy/jiffy.dart';
import 'package:unicons/unicons.dart';

class BookPageHeader extends StatelessWidget {
  const BookPageHeader({
    Key? key,
    required this.book,
    required this.multiSelectedItems,
    this.liked = false,
    this.onAddToBook,
    this.onShowDatesDialog,
    this.onLike,
    this.forceMultiSelect = false,
    this.onClearMultiSelect,
    this.onConfirmRemoveGroup,
    this.onConfirmDeleteBook,
    this.onMultiSelectAll,
    this.onToggleMultiSelect,
    this.onShowRenameBookDialog,
    this.onUploadToThisBook,
    this.isOwner = false,
    this.onUpdateVisibility,
    this.authenticated = false,
    this.heroTag = "",
    this.coverPopupMenuEntries = const [],
    this.onCoverPopupMenuItemSelected,
  }) : super(key: key);

  /// Main page data.
  final Book book;

  /// True if the book is liked by the current authenticated user.
  final bool liked;

  /// True if the current authenticated user is the owner.
  final bool isOwner;

  /// True if the current user is authenticated.
  final bool authenticated;

  /// If true, illustrations in this book can be selected in group.
  final bool forceMultiSelect;

  /// Currently selected illustrations.
  final IllustrationMap multiSelectedItems;

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
  final void Function(EnumBookItemAction, int, Book)?
      onCoverPopupMenuItemSelected;

  /// Callback fired when we switch on/off multiselect.
  final void Function()? onToggleMultiSelect;

  /// Callback fired when we want to show book's creation & last updated dates.
  final void Function()? onShowDatesDialog;

  /// Callback showing an input dialog to rename this book.
  final void Function()? onShowRenameBookDialog;

  /// Callback fired when a file is uploaded and added to this book.
  final void Function()? onUploadToThisBook;

  /// Callback fired when the book's visibility is updated.
  final void Function(EnumContentVisibility)? onUpdateVisibility;
  final List<PopupEntryBook> coverPopupMenuEntries;

  /// Custom hero tag (if `book.id` default tag is not unique).
  final String heroTag;

  @override
  Widget build(BuildContext context) {
    final String bookHeroTag = heroTag.isNotEmpty ? heroTag : book.id;

    return SliverPadding(
      padding: const EdgeInsets.only(
        top: 60.0,
        left: 50.0,
        bottom: 24.0,
      ),
      sliver: SliverList(
        delegate: SliverChildListDelegate.fixed([
          Row(
            children: [
              BookSquareCover(
                book: book,
                bookHeroTag: bookHeroTag,
                index: 0,
                onPopupMenuItemSelected: onCoverPopupMenuItemSelected,
                popupMenuEntries: coverPopupMenuEntries,
              ),
              rightRow(context),
            ],
          ),
          if (isOwner)
            Padding(
              padding: const EdgeInsets.only(
                top: 32.0,
                left: 8.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BookPageActions(
                    forceMultiSelect: forceMultiSelect,
                    multiSelectedItems: multiSelectedItems,
                    onConfirmDeleteBook: onConfirmDeleteBook,
                    onToggleMultiSelect: onToggleMultiSelect,
                    onShowRenameBookDialog: onShowRenameBookDialog,
                    onUploadToThisBook: onUploadToThisBook,
                    visible: multiSelectedItems.isEmpty,
                    visibility: book.visibility,
                    onUpdateVisibility: onUpdateVisibility,
                  ),
                  BookPageGroupActions(
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

  Widget likeButton(BuildContext context) {
    if (!authenticated) {
      return Container();
    }

    if (liked) {
      return IconButton(
        tooltip: "unlike".tr(),
        icon: Icon(
          FontAwesomeIcons.solidHeart,
        ),
        iconSize: 18.0,
        color: Theme.of(context).secondaryHeaderColor,
        onPressed: onLike,
      );
    }

    return IconButton(
      tooltip: "like".tr(),
      icon: Icon(
        UniconsLine.heart,
      ),
      onPressed: onLike,
    );
  }

  Widget rightRow(BuildContext context) {
    String updatedAtStr = "";

    if (DateTime.now().difference(book.updatedAt).inDays > 60) {
      updatedAtStr = "date_updated_on".tr(
        args: [
          Jiffy(book.updatedAt).yMMMMEEEEd,
        ],
      );
    } else {
      updatedAtStr = "date_updated_ago".tr(
        args: [Jiffy(book.updatedAt).fromNow()],
      );
    }

    final Color color = book.illustrations.isEmpty
        ? Theme.of(context).secondaryHeaderColor
        : Theme.of(context).primaryColor;

    return Padding(
      padding: const EdgeInsets.only(left: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Opacity(
            opacity: 0.6,
            child: IconButton(
              tooltip: "back".tr(),
              onPressed: () => Utilities.navigation.back(context),
              icon: Icon(UniconsLine.arrow_left),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Opacity(
                  opacity: 0.8,
                  child: Text(
                    book.name,
                    style: Utilities.fonts.body(
                      fontSize: 40.0,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Opacity(
                  opacity: 0.6,
                  child: Text(
                    book.description,
                    style: Utilities.fonts.body(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                InkWell(
                  onTap: onShowDatesDialog,
                  child: Opacity(
                    opacity: 0.6,
                    child: Text(
                      updatedAtStr,
                      style: Utilities.fonts.body(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Opacity(
                      opacity: 0.8,
                      child: Text(
                        "illustrations_count".plural(book.illustrations.length),
                        style: Utilities.fonts.body(
                          color: color,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    likeButton(context),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
