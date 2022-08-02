import 'package:artbooking/components/cards/book_card.dart';
import 'package:artbooking/components/cards/illustration_card.dart';
import 'package:artbooking/components/icons/animated_app_icon.dart';
import 'package:artbooking/screens/likes/likes_page_empty.dart';
import 'package:artbooking/types/book/book.dart';
import 'package:artbooking/types/enums/enum_book_item_action.dart';
import 'package:artbooking/types/enums/enum_illustration_item_action.dart';
import 'package:artbooking/types/enums/enum_like_type.dart';
import 'package:artbooking/types/illustration/illustration.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class LikesPageBody extends StatelessWidget {
  const LikesPageBody({
    Key? key,
    required this.books,
    required this.bookPopupMenuEntries,
    required this.illustrations,
    required this.illustrationPopupMenuEntries,
    required this.loading,
    required this.selectedTab,
    this.isMobileSize = false,
    this.onPopupMenuIllustrationSelected,
    this.onPopupMenuBookSelected,
    this.onTapBook,
    this.onTapBrowse,
    this.onTapIllustration,
    this.onUnlikeBook,
    this.onUnlikeIllustration,
  }) : super(key: key);

  /// If true, this widget adapt its layout to small screens.
  final bool isMobileSize;

  /// The data is loading if true.
  final bool loading;

  /// Current tab selected (illustration or books).
  final EnumLikeType selectedTab;

  /// Illustrations data list.
  final List<Illustration> illustrations;

  /// Books data list.
  final List<Book> books;

  /// Popup entries for illustrations.
  final List<PopupMenuEntry<EnumIllustrationItemAction>>
      illustrationPopupMenuEntries;

  /// Popup entries for books.
  final List<PopupMenuEntry<EnumBookItemAction>> bookPopupMenuEntries;

  /// Callback fired on illustration tap.
  final void Function(Illustration)? onTapIllustration;

  /// Callback fired on book tap.
  final void Function(Book)? onTapBook;

  /// Callback fired when a book is removed from favourite.
  final void Function(Book, int)? onUnlikeBook;

  /// Callback fired when an illustration is removed from favourite.
  final void Function(Illustration, int)? onUnlikeIllustration;

  /// Callback to redirect user to books page if they favourites are empty.
  final void Function()? onTapBrowse;

  /// Callback fired after selecting an item from an illustration popup menu.
  final void Function(
    EnumIllustrationItemAction,
    int,
    Illustration,
    String,
  )? onPopupMenuIllustrationSelected;

  /// Callback fired after selecting an item from a book popup menu.
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
            textTitle: selectedTab == EnumLikeType.book
                ? "books_loading".tr()
                : "illustrations_loading".tr(),
          ),
        ),
      );
    }

    final bool illustrationsEmpty =
        selectedTab == EnumLikeType.illustration && illustrations.isEmpty;

    final bool booksEmpty = selectedTab == EnumLikeType.book && books.isEmpty;

    if (illustrationsEmpty || booksEmpty) {
      return LikesPageEmpty(
        selectedTab: selectedTab,
        onTapBrowse: onTapBrowse,
      );
    }

    if (selectedTab == EnumLikeType.book) {
      return SliverPadding(
        padding: isMobileSize
            ? const EdgeInsets.only(top: 40.0)
            : const EdgeInsets.all(40.0),
        sliver: SliverGrid(
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            mainAxisExtent: isMobileSize ? 161.0 : 360.0,
            maxCrossAxisExtent: isMobileSize ? 220.0 : 290.0,
            mainAxisSpacing: isMobileSize ? 0.0 : 12.0,
            crossAxisSpacing: isMobileSize ? 0.0 : 12.0,
          ),
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              final book = books.elementAt(index);

              return BookCard(
                book: book,
                height: isMobileSize ? 161.0 : 332.0,
                heroTag: book.id,
                index: index,
                onTap: () => onTapBook?.call(book),
                onDoubleTap: () => onUnlikeBook?.call(book, index),
                onLike: (_) => onUnlikeBook?.call(book, index),
                onPopupMenuItemSelected: onPopupMenuBookSelected,
                popupMenuEntries: bookPopupMenuEntries,
                useBottomSheet: isMobileSize,
                width: isMobileSize ? 220.0 : 280.0,
              );
            },
            childCount: books.length,
          ),
        ),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.only(
        top: 40.0,
        left: isMobileSize ? 12.0 : 40.0,
        right: isMobileSize ? 12.0 : 40.0,
        bottom: 100.0,
      ),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 240.0,
          mainAxisSpacing: 20.0,
          crossAxisSpacing: 20.0,
        ),
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            final Illustration illustration = illustrations.elementAt(index);

            return IllustrationCard(
              borderRadius: BorderRadius.circular(16.0),
              elevation: 6.0,
              heroTag: illustration.id,
              illustration: illustration,
              index: index,
              onDoubleTap: () => onUnlikeIllustration?.call(
                illustration,
                index,
              ),
              onPopupMenuItemSelected: onPopupMenuIllustrationSelected,
              popupMenuEntries: illustrationPopupMenuEntries,
              onTap: () => onTapIllustration?.call(illustration),
              onTapLike: () => onUnlikeIllustration?.call(illustration, index),
              size: 250.0,
              useBottomSheet: isMobileSize,
            );
          },
          childCount: illustrations.length,
        ),
      ),
    );
  }
}
