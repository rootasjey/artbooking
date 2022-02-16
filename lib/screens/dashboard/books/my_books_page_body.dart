import 'package:artbooking/components/cards/book_card.dart';
import 'package:artbooking/components/icons/animated_app_icon.dart';
import 'package:artbooking/screens/dashboard/books/my_books_page_empty.dart';
import 'package:artbooking/types/book/book.dart';
import 'package:artbooking/types/enums/enum_book_item_action.dart';
import 'package:artbooking/types/enums/enum_visibility_tab.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class MyBooksPageBody extends StatelessWidget {
  const MyBooksPageBody({
    Key? key,
    required this.loading,
    required this.books,
    required this.forceMultiSelect,
    required this.multiSelectedItems,
    required this.popupMenuEntries,
    required this.selectedTab,
    this.onShowCreateBookDialog,
    this.onTapBook,
    this.onPopupMenuItemSelected,
    this.onLongPressBook,
    this.onGoToActiveBooks,
  }) : super(key: key);

  final bool forceMultiSelect;
  final bool loading;

  final EnumVisibilityTab selectedTab;

  final void Function()? onShowCreateBookDialog;
  final void Function(Book)? onTapBook;
  final void Function(EnumBookItemAction, int, Book)? onPopupMenuItemSelected;
  final void Function(Book, bool)? onLongPressBook;
  final void Function()? onGoToActiveBooks;

  final List<Book> books;
  final List<PopupMenuEntry<EnumBookItemAction>> popupMenuEntries;
  final Map<String?, Book> multiSelectedItems;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return SliverList(
        delegate: SliverChildListDelegate.fixed([
          Padding(
            padding: const EdgeInsets.only(top: 100.0),
            child: AnimatedAppIcon(textTitle: "loading_books".tr()),
          ),
        ]),
      );
    }

    if (books.isEmpty) {
      return MyBooksPageEmpty(
        createBook: onShowCreateBookDialog,
        selectedTab: selectedTab,
        onGoToActiveBooks: onGoToActiveBooks,
      );
    }

    final selectionMode = forceMultiSelect || multiSelectedItems.isNotEmpty;

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
            final selected = multiSelectedItems.containsKey(book.id);

            return BookCard(
              key: ValueKey(book.id),
              index: index,
              book: book,
              selected: selected,
              selectionMode: selectionMode,
              onTap: () => onTapBook?.call(book),
              onPopupMenuItemSelected: onPopupMenuItemSelected,
              popupMenuEntries: popupMenuEntries,
              onLongPress: (selected) => onLongPressBook?.call(book, selected),
            );
          },
          childCount: books.length,
        ),
      ),
    );
  }
}
