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
    this.onTapIllustration,
    this.onPopupMenuIllustrationSelected,
    this.onTapBook,
    this.onPopupMenuBookSelected,
    this.onUnlikeBook,
    this.onUnlikeIllustration,
    this.onTapBrowse,
  }) : super(key: key);

  final bool loading;

  final EnumLikeType selectedTab;

  final List<Illustration> illustrations;
  final List<Book> books;

  final List<PopupMenuEntry<EnumIllustrationItemAction>>
      illustrationPopupMenuEntries;
  final List<PopupMenuEntry<EnumBookItemAction>> bookPopupMenuEntries;

  final void Function(Illustration)? onTapIllustration;
  final void Function(Book)? onTapBook;
  final void Function(Book, int)? onUnlikeBook;
  final void Function(Illustration, int)? onUnlikeIllustration;
  final void Function()? onTapBrowse;

  final void Function(
    EnumIllustrationItemAction,
    int,
    Illustration,
    String,
  )? onPopupMenuIllustrationSelected;

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
        padding: const EdgeInsets.all(40.0),
        sliver: SliverGrid(
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            mainAxisExtent: 360.0,
            maxCrossAxisExtent: 290.0,
            mainAxisSpacing: 12.0,
            crossAxisSpacing: 12.0,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final book = books.elementAt(index);

              return BookCard(
                book: book,
                index: index,
                width: 280.0,
                height: 332.0,
                onTap: () => onTapBook?.call(book),
                onDoubleTap: () => onUnlikeBook?.call(book, index),
                onTapLike: () => onUnlikeBook?.call(book, index),
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
      padding: const EdgeInsets.only(
        top: 40.0,
        left: 40.0,
        right: 40.0,
        bottom: 100.0,
      ),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 240.0,
          mainAxisSpacing: 20.0,
          crossAxisSpacing: 20.0,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final illustration = illustrations.elementAt(index);

            return IllustrationCard(
              index: index,
              size: 250.0,
              heroTag: illustration.id,
              illustration: illustration,
              onTap: () => onTapIllustration?.call(illustration),
              onDoubleTap: () =>
                  onUnlikeIllustration?.call(illustration, index),
              onTapLike: () => onUnlikeIllustration?.call(illustration, index),
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
