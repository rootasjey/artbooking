import 'package:artbooking/components/cards/book_card.dart';
import 'package:artbooking/components/icons/animated_app_icon.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/screens/atelier/books/my_books_page_empty.dart';
import 'package:artbooking/types/book/book.dart';
import 'package:artbooking/types/book/popup_entry_book.dart';
import 'package:artbooking/types/enums/enum_book_item_action.dart';
import 'package:artbooking/types/enums/enum_visibility_tab.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Body part of a page showing an user's books.
class MyBooksPageBody extends StatelessWidget {
  const MyBooksPageBody({
    Key? key,
    required this.books,
    required this.draggingActive,
    required this.forceMultiSelect,
    required this.loading,
    required this.multiSelectedItems,
    required this.popupMenuEntries,
    required this.selectedTab,
    this.authenticated = false,
    this.isOwner = false,
    this.likePopupMenuEntries = const [],
    this.onDragFileDone,
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
    this.onDragFileEntered,
    this.onDragFileExited,
    this.onTapBookCaption,
    this.isMobileSize = false,
  }) : super(key: key);

  /// If true, the current user is authenticated.
  final bool authenticated;

  /// (Mobile specific) If true, long pressing a card will start a drag.
  /// Otherwise, long pressing a card will display a context menu.
  final bool draggingActive;

  /// If true, the UI is in multi-select mode.
  final bool forceMultiSelect;

  /// If true, this widget adapt its layout to small screens.
  final bool isMobileSize;

  /// True if the current authenticated user is the owner of these books.
  final bool isOwner;

  /// If true, this composant is currently loading.
  final bool loading;

  /// Selected books tab.
  final EnumVisibilityTab selectedTab;

  final void Function(
    Book book,
    DropDoneDetails dropDoneDetails,
  )? onDragFileDone;

  /// Callback event fired when files started to being dragged over this book.
  final void Function(DropEventDetails details)? onDragFileEntered;

  /// Callback event fired when files exited to being dragged over this book.
  final void Function(DropEventDetails details)? onDragFileExited;

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

  final void Function(Book book)? onTapBookCaption;

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

    final bool selectionMode =
        forceMultiSelect || multiSelectedItems.isNotEmpty;

    return SliverPadding(
      padding: isMobileSize
          ? const EdgeInsets.only(top: 24.0, left: 8.0, right: 8.0)
          : const EdgeInsets.all(40.0),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          mainAxisExtent: isMobileSize ? 170.0 : 380.0,
          maxCrossAxisExtent: isMobileSize ? 200.0 : 380.0,
          mainAxisSpacing: 8.0,
          crossAxisSpacing: 8.0,
        ),
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
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
              backIcon: Utilities.ui.generateIcon(book.name),
              book: book,
              canDrag: isOwner && draggingActive,
              heroTag: book.id,
              index: index,
              key: ValueKey(book.id),
              width: isMobileSize ? 200.0 : 400.0,
              height: isMobileSize ? 170.0 : 342.0,
              canDropFile: isOwner,
              onDragFileDone: onDragFileDone,
              onDragFileEntered: onDragFileEntered,
              onDragFileExited: onDragFileExited,
              onDoubleTap: authenticated ? _onDoubleTap : null,
              onDragUpdate: onDragBookUpdate,
              onDragCompleted: onDragBookCompleted,
              onDragEnd: onDragBookEnd,
              onDragStarted: onDragBookStarted,
              onDraggableCanceled: onDraggableBookCanceled,
              onDrop: onDropBook,
              onLike: authenticated ? onLike : null,
              onPopupMenuItemSelected: onPopupMenuItemSelected,
              onTapCaption: onTapBookCaption,
              onTap: () => onTapBook?.call(book),
              popupMenuEntries: authenticated ? bookPopupMenuEntries : [],
              selected: selected,
              selectionMode: selectionMode,
              useBottomSheet: isMobileSize,
            );
          },
          childCount: books.length,
        ),
      ),
    );
  }
}
