import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/types/book/book.dart';
import 'package:artbooking/types/book/popup_entry_book.dart';
import 'package:artbooking/types/enums/enum_book_item_action.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class BookSquareCover extends StatefulWidget {
  const BookSquareCover({
    Key? key,
    required this.book,
    required this.bookHeroTag,
    this.popupMenuEntries = const [],
    this.onPopupMenuItemSelected,
    required this.index,
  }) : super(key: key);

  /// Main widget data. A book containing illustrations.
  final Book book;

  /// Callback fired when one of the popup menu item entries is selected.
  final void Function(EnumBookItemAction, int, Book)? onPopupMenuItemSelected;

  /// Index position in a list, if available.
  final int index;

  /// Menu item list displayed after tapping on the corresponding popup button.
  final List<PopupEntryBook> popupMenuEntries;

  /// Hero tag to make a smooth page transition.
  final String bookHeroTag;

  @override
  State<BookSquareCover> createState() => _BookSquareCoverState();
}

class _BookSquareCoverState extends State<BookSquareCover> {
  bool _showPopupMenu = false;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: widget.bookHeroTag,
      child: SizedBox(
        height: 300.0,
        width: 320.0,
        child: Card(
          elevation: 8.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          clipBehavior: Clip.antiAlias,
          child: Ink.image(
            image: NetworkImage(widget.book.getCoverLink()),
            height: 260.0,
            width: 200.0,
            fit: BoxFit.cover,
            child: InkWell(
              onHover: (bool isHover) {
                setState(() => _showPopupMenu = isHover);
              },
              onTap: () {},
              child: Stack(
                children: [
                  popupMenuButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget popupMenuButton() {
    if (widget.popupMenuEntries.isEmpty) {
      return Container();
    }

    return Positioned(
      top: 10.0,
      right: 10.0,
      child: Opacity(
        opacity: _showPopupMenu ? 1.0 : 0.0,
        child: PopupMenuButton(
          child: CircleAvatar(
            radius: 15.0,
            backgroundColor: Constants.colors.clairPink,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Icon(UniconsLine.ellipsis_h, size: 20),
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6.0),
          ),
          onSelected: (EnumBookItemAction action) {
            widget.onPopupMenuItemSelected?.call(
              action,
              widget.index,
              widget.book,
            );
          },
          itemBuilder: (_) => widget.popupMenuEntries,
        ),
      ),
    );
  }
}
