import 'package:artbooking/components/animations/fade_in_y.dart';
import 'package:artbooking/components/cards/book_card.dart';
import 'package:artbooking/components/popup_menu/popup_menu_item_icon.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/router/locations/atelier_location.dart';
import 'package:artbooking/router/navigation_state_helper.dart';
import 'package:artbooking/types/book/book.dart';
import 'package:artbooking/types/enums/enum_section_action.dart';
import 'package:artbooking/types/enums/enum_section_data_mode.dart';
import 'package:artbooking/types/firestore/doc_snap_map.dart';
import 'package:artbooking/types/section.dart';
import 'package:beamer/beamer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flash/src/flash_helper.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

/// A 3x2 book grid.
class BookGridSection extends StatefulWidget {
  const BookGridSection({
    Key? key,
    required this.title,
    required this.userId,
    this.mode = EnumSectionDataMode.sync,
    this.onPopupMenuItemSelected,
    this.popupMenuEntries = const [],
    required this.index,
    required this.section,
    this.isLast = false,
  }) : super(key: key);

  final bool isLast;
  final String title;
  final EnumSectionDataMode mode;
  final String userId;
  final void Function(EnumSectionAction, int, Section)? onPopupMenuItemSelected;
  final List<PopupMenuItemIcon<EnumSectionAction>> popupMenuEntries;

  /// Section's position in the layout (e.g. 0 is the first).
  final int index;
  final Section section;

  @override
  State<BookGridSection> createState() => _BookGridSectionState();
}

class _BookGridSectionState extends State<BookGridSection> {
  bool _isLoading = false;
  List<Book> _books = [];

  @override
  void initState() {
    super.initState();
    fetchBooks();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SliverList(
        delegate: SliverChildListDelegate.fixed([]),
      );
    }

    var popupMenuEntries = widget.popupMenuEntries;

    if (widget.index == 0) {
      popupMenuEntries = popupMenuEntries.toList();
      popupMenuEntries.removeWhere((x) => x.value == EnumSectionAction.moveUp);
    }

    if (widget.isLast) {
      popupMenuEntries = popupMenuEntries.toList();
      popupMenuEntries
          .removeWhere((x) => x.value == EnumSectionAction.moveDown);
    }

    int index = -1;

    return SliverToBoxAdapter(
      child: FadeInY(
        beginY: 24.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 70.0,
            vertical: 24.0,
          ),
          child: Stack(
            children: [
              Column(
                children: [
                  Opacity(
                    opacity: 0.6,
                    child: Text(
                      widget.title.toUpperCase(),
                      style: Utilities.fonts.style(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 200.0,
                    child: Divider(
                      color: Theme.of(context).secondaryHeaderColor,
                      thickness: 4.0,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 34.0),
                    child: GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      mainAxisSpacing: 24.0,
                      crossAxisSpacing: 24.0,
                      children: _books.map((Book book) {
                        index++;

                        return BookCard(
                          index: index,
                          book: book,
                          width: 300.0,
                          height: 342.0,
                          onTap: () => navigateToBookPage(book),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              Positioned(
                right: 0.0,
                child: PopupMenuButton(
                  icon: Opacity(
                    opacity: 0.8,
                    child: Icon(
                      UniconsLine.ellipsis_h,
                    ),
                  ),
                  itemBuilder: (_) => popupMenuEntries,
                  onSelected: (EnumSectionAction action) {
                    widget.onPopupMenuItemSelected?.call(
                      action,
                      widget.index,
                      widget.section,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void fetchBooks() async {
    setState(() {
      _isLoading = true;
      _books.clear();
    });

    try {
      final bookSnapshot = await FirebaseFirestore.instance
          .collection("books")
          .where("user_id", isEqualTo: widget.userId)
          .limit(6)
          .orderBy("updated_at", descending: true)
          .get();

      if (bookSnapshot.size == 0) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      for (DocSnapMap document in bookSnapshot.docs) {
        final data = document.data();
        data['id'] = document.id;
        _books.add(Book.fromMap(data));
      }
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void navigateToBookPage(Book book) {
    NavigationStateHelper.book = book;
    Beamer.of(context).beamToNamed(
      AtelierLocationContent.bookRoute.replaceFirst(
        ":bookId",
        book.id,
      ),
      data: {
        "bookId": book.id,
      },
    );
  }
}