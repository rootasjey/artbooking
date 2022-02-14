import 'package:artbooking/components/cards/book_card.dart';
import 'package:artbooking/components/icons/animated_app_icon.dart';
import 'package:artbooking/types/book/book.dart';
import 'package:artbooking/types/enums/enum_book_item_action.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class DashboardPageBooksBody extends StatelessWidget {
  const DashboardPageBooksBody({
    Key? key,
    required this.loading,
    required this.books,
    required this.forceMultiSelect,
    required this.multiSelectedItems,
    required this.popupMenuEntries,
    this.onShowCreateBookDialog,
    this.onTapBook,
    this.onPopupMenuItemSelected,
    this.onLongPressBook,
  }) : super(key: key);

  final bool forceMultiSelect;
  final bool loading;
  final List<Book> books;
  final void Function()? onShowCreateBookDialog;
  final void Function(Book)? onTapBook;
  final void Function(EnumBookItemAction, int, Book)? onPopupMenuItemSelected;
  final List<PopupMenuEntry<EnumBookItemAction>> popupMenuEntries;
  final void Function(Book, bool)? onLongPressBook;

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
      return SliverPadding(
        padding: const EdgeInsets.only(
          top: 40.0,
          left: 50.0,
        ),
        sliver: SliverList(
          delegate: SliverChildListDelegate.fixed([
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 12.0,
                  ),
                  child: Text(
                    "lonely_there".tr(),
                    style: TextStyle(
                      fontSize: 32.0,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 12.0,
                  ),
                  child: Opacity(
                    opacity: 0.6,
                    child: Text(
                      "books_none_created".tr(),
                      style: TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: onShowCreateBookDialog,
                  icon: Icon(UniconsLine.book_medical),
                  label: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      "create".tr(),
                      style: TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ]),
        ),
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
