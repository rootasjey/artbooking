import 'package:artbooking/components/application_bar/profile_application_bar.dart';
import 'package:artbooking/components/cards/book_card.dart';
import 'package:artbooking/components/cards/illustration_card.dart';
import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/book/book.dart';
import 'package:artbooking/types/illustration/illustration.dart';
import 'package:artbooking/types/user/user_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_improved_scrolling/flutter_improved_scrolling.dart';
import 'package:unicons/unicons.dart';

class DefaultProfilePageBody extends StatelessWidget {
  const DefaultProfilePageBody({
    Key? key,
    required this.scrollController,
    required this.userFirestore,
    this.illustrations = const [],
    this.books = const [],
    this.isMobileSize = false,
    this.showAppBarTitle = false,
    this.onPageScroll,
    this.onTapIllustration,
    this.onTapBook,
  }) : super(key: key);

  /// If true, this widget adapts its layout to small screens.
  final bool isMobileSize;

  /// Show profile page username if true, and if it's a profile page type.
  final bool showAppBarTitle;

  /// User's illustrations.
  final List<Illustration> illustrations;

  /// User's books.
  final List<Book> books;

  /// Callback fired when the page scrolls.
  final void Function(double)? onPageScroll;

  /// Callback fired when an illustration card receives a tap event.
  final void Function(Book)? onTapBook;

  /// Callback fired when an illustration card receives a tap event.
  final void Function(Illustration)? onTapIllustration;

  /// Profile page's owner.
  final UserFirestore userFirestore;

  /// Scroll controller to move inside the page.
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ImprovedScrolling(
        onScroll: onPageScroll,
        scrollController: scrollController,
        enableKeyboardScrolling: true,
        enableMMBScrolling: true,
        child: CustomScrollView(
          controller: scrollController,
          slivers: [
            ProfileApplicationBar(
              title: Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child: Text(
                  showAppBarTitle ? userFirestore.name : "",
                  style: Utilities.fonts.body(
                    color: Theme.of(context).textTheme.bodyText2?.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: CircleAvatar(
                        backgroundColor: Constants.colors.clairPink,
                        radius: 80.0,
                        foregroundImage: NetworkImage(
                          userFirestore.getProfilePicture(),
                        ),
                      ),
                    ),
                    Text(
                      userFirestore.name,
                      style: Utilities.fonts.body4(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (books.isEmpty && illustrations.isEmpty)
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 24.0,
                        left: 12.0,
                        right: 12.0,
                      ),
                      child: Opacity(
                        opacity: 1.0,
                        child: Icon(
                          UniconsLine.desert,
                          size: 70.0,
                          color: Colors.lightGreen,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        "profile_page_no_content".tr(),
                        textAlign: TextAlign.center,
                        style: Utilities.fonts.body(
                          fontSize: 24.0,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            SliverPadding(
              padding: EdgeInsets.only(
                top: 40.0,
                left: isMobileSize ? 12.0 : 40.0,
                right: isMobileSize ? 12.0 : 40.0,
                bottom: 100.0,
              ),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: isMobileSize ? 100.0 : 300.0,
                  mainAxisSpacing: isMobileSize ? 8.0 : 20.0,
                  crossAxisSpacing: isMobileSize ? 8.0 : 20.0,
                ),
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    final Illustration illustration =
                        illustrations.elementAt(index);

                    return IllustrationCard(
                      borderRadius:
                          BorderRadius.circular(isMobileSize ? 24.0 : 16.0),
                      elevation: 8.0,
                      heroTag: illustration.id,
                      illustration: illustration,
                      index: index,
                      onTap: () => onTapIllustration?.call(illustration),
                    );
                  },
                  childCount: illustrations.length,
                ),
              ),
            ),
            SliverPadding(
              padding:
                  isMobileSize ? EdgeInsets.zero : const EdgeInsets.all(40.0),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  mainAxisExtent: isMobileSize ? 161.0 : 380.0,
                  maxCrossAxisExtent: isMobileSize ? 220.0 : 380.0,
                  mainAxisSpacing: 0.0,
                  crossAxisSpacing: 0.0,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final Book book = books.elementAt(index);

                    return BookCard(
                      book: book,
                      heroTag: book.id,
                      index: index,
                      key: ValueKey(book.id),
                      width: isMobileSize ? 220.0 : 400.0,
                      height: isMobileSize ? 161.0 : 342.0,
                      onTap: () => onTapBook?.call(book),
                    );
                  },
                  childCount: books.length,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
