import 'package:artbooking/components/cards/book_card.dart';
import 'package:artbooking/components/icons/animated_app_icon.dart';
import 'package:artbooking/types/book/book.dart';
import 'package:artbooking/types/enums/enum_book_item_action.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class BooksPageBody extends StatelessWidget {
  const BooksPageBody({
    Key? key,
    required this.loading,
    required this.books,
    this.onLongPressBook,
    this.onTap,
    this.onDoubleTap,
    this.onPopupMenuItemSelected,
    this.likePopupMenuEntries = const [],
    this.unlikePopupMenuEntries = const [],
  }) : super(key: key);

  final bool loading;
  final List<Book> books;
  final void Function(bool)? onLongPressBook;
  final void Function(Book)? onTap;
  final void Function(Book, int)? onDoubleTap;
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
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("books_public_empty".tr()),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(40.0),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          mainAxisExtent: 410.0,
          maxCrossAxisExtent: 340.0,
          mainAxisSpacing: 20.0,
          crossAxisSpacing: 20.0,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final book = books.elementAt(index);

            final onDoubleTapOrNull = onDoubleTap != null
                ? () => onDoubleTap?.call(book, index)
                : null;

            final popupMenuEntries =
                book.liked ? unlikePopupMenuEntries : likePopupMenuEntries;

            return BookCard(
              book: book,
              index: index,
              heroTag: book.id,
              onTap: () => onTap?.call(book),
              onDoubleTap: onDoubleTapOrNull,
              onTapLike: onDoubleTapOrNull,
              onPopupMenuItemSelected: onPopupMenuItemSelected,
              popupMenuEntries: popupMenuEntries,
              onLongPress: onLongPressBook,
            );
          },
          childCount: books.length,
        ),
      ),
    );
  }
}
