import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/book/book.dart';
import 'package:artbooking/types/book/popup_entry_book.dart';
import 'package:artbooking/types/enums/enum_book_item_action.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jiffy/jiffy.dart';
import 'package:unicons/unicons.dart';

class BookSquareCover extends StatefulWidget {
  const BookSquareCover({
    Key? key,
    required this.book,
    required this.bookHeroTag,
    required this.index,
    this.authenticated = false,
    this.liked = false,
    this.onLike,
    this.popupMenuEntries = const [],
    this.onPopupMenuItemSelected,
    this.onShowDatesDialog,
  }) : super(key: key);

  /// Main widget data. A book containing illustrations.
  final Book book;

  /// True if the current user is authenticated.
  final bool authenticated;

  /// Callback fired when one of the popup menu item entries is selected.
  final void Function(EnumBookItemAction, int, Book)? onPopupMenuItemSelected;

  /// Index position in a list, if available.
  final int index;

  /// Menu item list displayed after tapping on the corresponding popup button.
  final List<PopupEntryBook> popupMenuEntries;

  /// Hero tag to make a smooth page transition.
  final String bookHeroTag;

  /// Callback fired when we want to show book's creation & last updated dates.
  final void Function()? onShowDatesDialog;

  /// Callback fired when the book is liked.
  final void Function()? onLike;

  /// True if the book is liked by the current authenticated user.
  final bool liked;

  @override
  State<BookSquareCover> createState() => _BookSquareCoverState();
}

class _BookSquareCoverState extends State<BookSquareCover> {
  bool _showPopupMenu = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Hero(
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
        ),
        rightRow(context),
      ],
    );
  }

  Widget likeButton(BuildContext context) {
    if (!widget.authenticated) {
      return Container();
    }

    if (widget.liked) {
      return IconButton(
        tooltip: "unlike".tr(),
        icon: Icon(
          FontAwesomeIcons.solidHeart,
        ),
        iconSize: 18.0,
        color: Theme.of(context).secondaryHeaderColor,
        onPressed: widget.onLike,
      );
    }

    return IconButton(
      tooltip: "like".tr(),
      icon: Icon(
        UniconsLine.heart,
      ),
      onPressed: widget.onLike,
    );
  }

  Widget rightRow(BuildContext context) {
    String updatedAtStr = "";

    if (DateTime.now().difference(widget.book.updatedAt).inDays > 60) {
      updatedAtStr = "date_updated_on".tr(
        args: [
          Jiffy(widget.book.updatedAt).yMMMMEEEEd,
        ],
      );
    } else {
      updatedAtStr = "date_updated_ago".tr(
        args: [Jiffy(widget.book.updatedAt).fromNow()],
      );
    }

    final Color color = widget.book.illustrations.isEmpty
        ? Theme.of(context).secondaryHeaderColor
        : Theme.of(context).primaryColor;

    return Padding(
      padding: const EdgeInsets.only(left: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Opacity(
            opacity: 0.6,
            child: IconButton(
              tooltip: "back".tr(),
              onPressed: () => Utilities.navigation.back(context),
              icon: Icon(UniconsLine.arrow_left),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Opacity(
                  opacity: 0.8,
                  child: Text(
                    widget.book.name,
                    style: Utilities.fonts.body(
                      fontSize: 40.0,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Opacity(
                  opacity: 0.6,
                  child: Text(
                    widget.book.description,
                    style: Utilities.fonts.body(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                InkWell(
                  onTap: widget.onShowDatesDialog,
                  child: Opacity(
                    opacity: 0.6,
                    child: Text(
                      updatedAtStr,
                      style: Utilities.fonts.body(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Opacity(
                      opacity: 0.8,
                      child: Text(
                        "illustrations_count"
                            .plural(widget.book.illustrations.length),
                        style: Utilities.fonts.body(
                          color: color,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    likeButton(context),
                  ],
                ),
              ],
            ),
          ),
        ],
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
