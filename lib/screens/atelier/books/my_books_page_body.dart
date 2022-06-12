import 'package:artbooking/components/cards/book_card.dart';
import 'package:artbooking/components/icons/animated_app_icon.dart';
import 'package:artbooking/screens/atelier/books/my_books_page_empty.dart';
import 'package:artbooking/types/book/book.dart';
import 'package:artbooking/types/book/popup_entry_book.dart';
import 'package:artbooking/types/enums/enum_book_item_action.dart';
import 'package:artbooking/types/enums/enum_visibility_tab.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class MyBooksPageBody extends StatelessWidget {
  const MyBooksPageBody({
    Key? key,
    required this.books,
    required this.forceMultiSelect,
    required this.loading,
    required this.multiSelectedItems,
    required this.popupMenuEntries,
    required this.selectedTab,
    this.authenticated = false,
    this.isOwner = false,
    this.likePopupMenuEntries = const [],
    this.onDoubleTap,
    this.onDragBookCompleted,
    this.onDragBookEnd,
    this.onDragBookUpdate,
    this.onDraggableBookCanceled,
    this.onDragBookStarted,
    this.onDropBook,
    this.onGoToActiveBooks,
    this.onLongPressBook,
    this.onLike,
    this.onPopupMenuItemSelected,
    this.onShowCreateBookDialog,
    this.onTapBook,
    this.unlikePopupMenuEntries = const [],
  }) : super(key: key);

  /// If true, the current user is authenticated.
  final bool authenticated;

  /// If true, the UI is in multi-select mode.
  final bool forceMultiSelect;

  /// True if the current authenticated user is the owner of these books.
  final bool isOwner;

  /// If true, this composant is currently loading.
  final bool loading;

  /// Selected books tab.
  final EnumVisibilityTab selectedTab;

  /// Callback when drag and dropping item on this book card.
  final void Function(int, List<int>)? onDropBook;

  /// Callback opening a dialog to create a new book.
  final void Function()? onShowCreateBookDialog;

  /// Callback fired after a tap event on a book card.
  final void Function(Book)? onTapBook;

  /// Callback fired after selecting a popup menu item.
  final void Function(EnumBookItemAction, int, Book)? onPopupMenuItemSelected;

  /// Callback fired after a long press on a book card.
  final void Function(Book, bool)? onLongPressBook;

  /// Will navigate to active books tab.
  final void Function()? onGoToActiveBooks;

  /// Callback when a book is being dragged.
  /// This function will be called for every position update.
  final void Function(DragUpdateDetails details)? onDragBookUpdate;

  /// Callback fired when a book card receives a double tap event.
  final void Function(Book book, int index)? onDoubleTap;

  /// Callback when book dragging is completed.
  final void Function()? onDragBookCompleted;

  /// Callback when book dragging has ended.
  final void Function(DraggableDetails)? onDragBookEnd;

  /// Callback when book dragging has been canceled.
  final void Function(Velocity, Offset)? onDraggableBookCanceled;

  /// Callback when book dragging has started.
  final void Function()? onDragBookStarted;

  /// Callback fired on toggle book existence in an user's favourites.
  final void Function(Book book)? onLike;

  /// Book list.
  final List<Book> books;

  /// Owner popup menu entries.
  final List<PopupMenuEntry<EnumBookItemAction>> popupMenuEntries;

  /// Available items for authenticated user and the book target is not liked yet.
  final List<PopupEntryBook> likePopupMenuEntries;

  /// Available items for authenticated user and the book target is already liked.
  final List<PopupEntryBook> unlikePopupMenuEntries;

  /// Group of book selected.
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
            final Book book = books.elementAt(index);
            final bool selected = multiSelectedItems.containsKey(book.id);

            final void Function()? _onDoubleTap = onDoubleTap != null
                ? () => onDoubleTap?.call(book, index)
                : null;

            final List<PopupEntryBook> bookPopupMenuEntries = isOwner
                ? popupMenuEntries
                : book.liked
                    ? unlikePopupMenuEntries
                    : likePopupMenuEntries;

            return BookCard(
              book: book,
              canDrag: isOwner,
              heroTag: book.id,
              index: index,
              key: ValueKey(book.id),
              onDoubleTap: authenticated ? _onDoubleTap : null,
              onDragUpdate: onDragBookUpdate,
              onDragCompleted: onDragBookCompleted,
              onDragEnd: onDragBookEnd,
              onDragStarted: onDragBookStarted,
              onDraggableCanceled: onDraggableBookCanceled,
              onDrop: onDropBook,
              onLike: authenticated ? onLike : null,
              onPopupMenuItemSelected: onPopupMenuItemSelected,
              onTap: () => onTapBook?.call(book),
              popupMenuEntries: authenticated ? bookPopupMenuEntries : [],
              selected: selected,
              selectionMode: selectionMode,
            );
          },
          childCount: books.length,
        ),
      ),
    );
  }
}
