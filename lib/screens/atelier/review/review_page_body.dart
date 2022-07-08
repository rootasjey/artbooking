import 'package:artbooking/components/cards/book_card.dart';
import 'package:artbooking/components/cards/illustration_card.dart';
import 'package:artbooking/components/icons/animated_app_icon.dart';
import 'package:artbooking/screens/atelier/review/review_page_empty.dart';
import 'package:artbooking/types/book/book.dart';
import 'package:artbooking/types/enums/enum_book_item_action.dart';
import 'package:artbooking/types/enums/enum_illustration_item_action.dart';
import 'package:artbooking/types/enums/enum_tab_data_type.dart';
import 'package:artbooking/types/illustration/illustration.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ReviewPageBody extends StatelessWidget {
  const ReviewPageBody({
    Key? key,
    required this.books,
    required this.bookPopupMenuEntries,
    required this.illustrations,
    required this.illustrationPopupMenuEntries,
    required this.loading,
    required this.selectedTab,
    this.isMobileSize = false,
    this.onTapIllustration,
    this.onPopupMenuIllustrationSelected,
    this.onTapBook,
    this.onPopupMenuBookSelected,
    this.onApproveBook,
    this.onApproveIllustration,
  }) : super(key: key);

  /// If true, this widget adapt its layout to small screens.
  final bool isMobileSize;

  /// True if data is currently loading.
  final bool loading;

  /// Currently selected tab (books or illustrations).
  final EnumTabDataType selectedTab;

  /// List of illustrations (main data).
  final List<Illustration> illustrations;

  /// List of books (main data).
  final List<Book> books;

  /// List of popup menu entry for illustrations.
  final List<PopupMenuEntry<EnumIllustrationItemAction>>
      illustrationPopupMenuEntries;

  /// List of popup menu entry for books.
  final List<PopupMenuEntry<EnumBookItemAction>> bookPopupMenuEntries;

  /// Callback fired after tapping on an illustration.
  final void Function(Illustration)? onTapIllustration;

  /// Callback fired after tapping on aa book.
  final void Function(Book)? onTapBook;

  /// Callback fired when a book is approved.
  final void Function(Book, int)? onApproveBook;

  /// Callback fired when an illustration is approved.
  final void Function(Illustration, int)? onApproveIllustration;

  /// Callback fired when an item from the illustration menu popup is selected.
  final void Function(
    EnumIllustrationItemAction,
    int,
    Illustration,
    String,
  )? onPopupMenuIllustrationSelected;

  /// Callback fired when an item from the book menu popup is selected.
  final void Function(
    EnumBookItemAction,
    int,
    Book,
  )? onPopupMenuBookSelected;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 100.0),
          child: AnimatedAppIcon(
            textTitle: selectedTab == EnumTabDataType.books
                ? "books_loading".tr()
                : "illustrations_loading".tr(),
          ),
        ),
      );
    }

    final bool illustrationsEmpty =
        selectedTab == EnumTabDataType.illustrations && illustrations.isEmpty;
    final bool booksEmpty =
        selectedTab == EnumTabDataType.books && books.isEmpty;

    if (illustrationsEmpty || booksEmpty) {
      return ReviewPageEmpty(
        selectedTab: selectedTab,
      );
    }

    if (selectedTab == EnumTabDataType.books) {
      return SliverPadding(
        padding: EdgeInsets.all(isMobileSize ? 12.0 : 40.0),
        sliver: SliverGrid(
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            mainAxisExtent: isMobileSize ? 161.0 : 360.0,
            maxCrossAxisExtent: isMobileSize ? 220.0 : 290.0,
            mainAxisSpacing: isMobileSize ? 0.0 : 12.0,
            crossAxisSpacing: isMobileSize ? 0.0 : 12.0,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final book = books.elementAt(index);

              return BookCard(
                book: book,
                index: index,
                heroTag: book.id,
                width: isMobileSize ? 220.0 : 280.0,
                height: isMobileSize ? 161.0 : 332.0,
                onTap: () => onTapBook?.call(book),
                onPopupMenuItemSelected: onPopupMenuBookSelected,
                popupMenuEntries: bookPopupMenuEntries,
              );
            },
            childCount: books.length,
          ),
        ),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.only(
        top: isMobileSize ? 12.0 : 40.0,
        left: isMobileSize ? 12.0 : 40.0,
        right: isMobileSize ? 12.0 : 40.0,
        bottom: 100.0,
      ),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 240.0,
          mainAxisSpacing: 12.0,
          crossAxisSpacing: 12.0,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final illustration = illustrations.elementAt(index);

            return IllustrationCard(
              borderRadius: BorderRadius.circular(16.0),
              index: index,
              size: 250.0,
              heroTag: illustration.id,
              illustration: illustration,
              onTap: () => onTapIllustration?.call(illustration),
              onPopupMenuItemSelected: onPopupMenuIllustrationSelected,
              popupMenuEntries: illustrationPopupMenuEntries,
            );
          },
          childCount: illustrations.length,
        ),
      ),
    );
  }
}
