import 'package:artbooking/components/animations/fade_in_y.dart';
import 'package:artbooking/components/cards/book_card.dart';
import 'package:artbooking/components/popup_menu/popup_menu_item_icon.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/book/book.dart';
import 'package:artbooking/types/enums/enum_section_action.dart';
import 'package:artbooking/types/enums/enum_section_data_mode.dart';
import 'package:artbooking/types/firestore/doc_snap_map.dart';
import 'package:artbooking/types/section.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flash/src/flash_helper.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class ProfilePageBooks extends StatefulWidget {
  const ProfilePageBooks({
    Key? key,
    required this.title,
    required this.userId,
    this.mode = EnumSectionDataMode.lastUpdated,
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
  State<ProfilePageBooks> createState() => _ProfilePageBooksState();
}

class _ProfilePageBooksState extends State<ProfilePageBooks> {
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

    int bookIndex = -1;

    return SliverToBoxAdapter(
      child: FadeInY(
        beginY: 24.0,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
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
                    child: Wrap(
                      spacing: 24.0,
                      runSpacing: 24.0,
                      children: _books.map((book) {
                        bookIndex++;

                        return SizedBox(
                          width: 260.0,
                          height: 400.0,
                          child: BookCard(
                            index: bookIndex,
                            book: book,
                          ),
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
          .where("user.id", isEqualTo: widget.userId)
          .limit(6)
          .orderBy("updatedAt", descending: true)
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
        _books.add(Book.fromJSON(data));
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
}
