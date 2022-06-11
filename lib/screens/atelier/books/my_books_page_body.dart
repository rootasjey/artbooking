import 'package:artbooking/components/cards/book_card.dart';
import 'package:artbooking/components/icons/animated_app_icon.dart';
import 'package:artbooking/screens/atelier/books/my_books_page_empty.dart';
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
    this.onDropBook,
    this.onDragUpdateBook,
    this.onDragBookCompleted,
    this.onDragBookEnd,
    this.onDraggableBookCanceled,
    this.onDragBookStarted,
  }) : super(key: key);

  final bool forceMultiSelect;
  final bool loading;

  final EnumVisibilityTab selectedTab;

  /// Callback when drag and dropping item on this book card.
  final void Function(int, List<int>)? onDropBook;
  final void Function()? onShowCreateBookDialog;
  final void Function(Book)? onTapBook;
  final void Function(EnumBookItemAction, int, Book)? onPopupMenuItemSelected;
  final void Function(Book, bool)? onLongPressBook;
  final void Function()? onGoToActiveBooks;
  final void Function(DragUpdateDetails details)? onDragUpdateBook;

  /// Callback when book dragging is completed.
  final void Function()? onDragBookCompleted;

  /// Callback when book dragging has ended.
  final void Function(DraggableDetails)? onDragBookEnd;

  /// Callback when book dragging has been canceled.
  final void Function(Velocity, Offset)? onDraggableBookCanceled;

  /// Callback when book dragging has started.
  final void Function()? onDragBookStarted;

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
          mainAxisExtent: 380.0,
          maxCrossAxisExtent: 380.0,
          mainAxisSpacing: 0.0,
          crossAxisSpacing: 0.0,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final book = books.elementAt(index);
            final selected = multiSelectedItems.containsKey(book.id);

            return BookCard(
              key: ValueKey(book.id),
              heroTag: book.id,
              index: index,
              book: book,
              selected: selected,
              selectionMode: selectionMode,
              canDrag: true,
              onDragUpdate: onDragUpdateBook,
              onDrop: onDropBook,
              onTap: () => onTapBook?.call(book),
              onPopupMenuItemSelected: onPopupMenuItemSelected,
              popupMenuEntries: popupMenuEntries,
              onDragCompleted: onDragBookCompleted,
              onDragEnd: onDragBookEnd,
              onDragStarted: onDragBookStarted,
              onDraggableCanceled: onDraggableBookCanceled,
            );
          },
          childCount: books.length,
        ),
      ),
    );
  }
}
