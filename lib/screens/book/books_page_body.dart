import 'package:artbooking/components/cards/book_card.dart';
import 'package:artbooking/components/icons/animated_app_icon.dart';
import 'package:artbooking/screens/book/books_page_empty.dart';
import 'package:artbooking/types/book/book.dart';
import 'package:artbooking/types/enums/enum_book_item_action.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Body part of a page showing all books.
class BooksPageBody extends StatelessWidget {
  const BooksPageBody({
    Key? key,
    required this.books,
    required this.loading,
    this.isMobileSize = false,
    this.onDoubleTap,
    this.onLongPressBook,
    this.onLike,
    this.onPopupMenuItemSelected,
    this.onTap,
    this.likePopupMenuEntries = const [],
    this.unlikePopupMenuEntries = const [],
  }) : super(key: key);

  /// If true, this widget adapts its layout to small screens.
  final bool isMobileSize;

  /// Currently fetching books if true.
  final bool loading;

  /// List of books.
  final List<Book> books;

  /// Callback fired when a card is long pressed.
  final void Function(Book book, bool selected)? onLongPressBook;

  /// Callback fired when a card is tapped.
  final void Function(Book book)? onTap;

  /// Callback fired when a card is double tapped.
  final void Function(Book book, int index)? onDoubleTap;

  /// Callback fired on toggle book existence in an user's favourites.
  final void Function(Book book)? onLike;

  /// Callback fired when a popup item is selected.
  final void Function(EnumBookItemAction, int, Book)? onPopupMenuItemSelected;

  /// Entries if this book is NOT already liked.
  final List<PopupMenuEntry<EnumBookItemAction>> likePopupMenuEntries;

  /// Entries if this book is already liked.
  final List<PopupMenuEntry<EnumBookItemAction>> unlikePopupMenuEntries;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.only(top: 100.0),
          child: AnimatedAppIcon(textTitle: "loading_books".tr()),
        ),
      );
    }

    if (books.isEmpty) {
      return BooksPageEmpty();
    }

    return SliverPadding(
      padding: EdgeInsets.all(isMobileSize ? 12.0 : 40.0),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          mainAxisExtent: isMobileSize ? 171.0 : 380.0,
          maxCrossAxisExtent: isMobileSize ? 230.0 : 380.0,
          mainAxisSpacing: 0.0,
          crossAxisSpacing: 0.0,
        ),
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            final Book book = books.elementAt(index);

            final void Function()? onDoubleTapOrNull = onDoubleTap != null
                ? () => onDoubleTap?.call(book, index)
                : null;

            final List<PopupMenuEntry<EnumBookItemAction>> popupMenuEntries =
                book.liked ? unlikePopupMenuEntries : likePopupMenuEntries;

            return BookCard(
              book: book,
              index: index,
              height: isMobileSize ? 171.0 : 342.0,
              heroTag: book.id,
              onTap: () => onTap?.call(book),
              onDoubleTap: onDoubleTapOrNull,
              onLike: onLike,
              onPopupMenuItemSelected: onPopupMenuItemSelected,
              popupMenuEntries: popupMenuEntries,
              onLongPress: onLongPressBook,
              useBottomSheet: isMobileSize,
              width: isMobileSize ? 230.0 : 400.0,
            );
          },
          childCount: books.length,
        ),
      ),
    );
  }
}
