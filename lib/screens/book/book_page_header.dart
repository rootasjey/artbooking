import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/screens/book/book_page_actions.dart';
import 'package:artbooking/screens/book/book_page_group_actions.dart';
import 'package:artbooking/types/book/book.dart';
import 'package:artbooking/types/enums/enum_content_visibility.dart';
import 'package:artbooking/types/illustration_map.dart';
import 'package:beamer/beamer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jiffy/jiffy.dart';
import 'package:unicons/unicons.dart';

class BookPageHeader extends StatelessWidget {
  const BookPageHeader({
    Key? key,
    required this.book,
    required this.multiSelectedItems,
    this.liked = false,
    this.onAddToBook,
    this.onShowDatesDialog,
    this.onLike,
    this.forceMultiSelect = false,
    this.onClearMultiSelect,
    this.onConfirmRemoveGroup,
    this.onConfirmDeleteBook,
    this.onMultiSelectAll,
    this.onToggleMultiSelect,
    this.onShowRenameBookDialog,
    this.onUploadToThisBook,
    this.owner = false,
    this.onUpdateVisibility,
    this.authenticated = false,
  }) : super(key: key);

  final Book book;
  final bool liked;
  final bool owner;
  final bool authenticated;
  final bool forceMultiSelect;

  /// Currently selected illustrations.
  final IllustrationMap multiSelectedItems;

  final void Function()? onAddToBook;
  final void Function()? onClearMultiSelect;
  final void Function()? onConfirmRemoveGroup;
  final void Function()? onConfirmDeleteBook;
  final void Function()? onLike;
  final void Function()? onMultiSelectAll;
  final void Function()? onToggleMultiSelect;
  final void Function()? onShowDatesDialog;
  final void Function()? onShowRenameBookDialog;
  final void Function()? onUploadToThisBook;
  final void Function(EnumContentVisibility)? onUpdateVisibility;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(
        top: 60.0,
        left: 50.0,
        bottom: 24.0,
      ),
      sliver: SliverList(
        delegate: SliverChildListDelegate.fixed([
          Row(
            children: [
              Hero(
                tag: book.id,
                child: SizedBox(
                  height: 260.0,
                  width: 200.0,
                  child: Card(
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Ink.image(
                      image: NetworkImage(book.getCoverLink()),
                      height: 260.0,
                      width: 200.0,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              rightRow(context),
            ],
          ),
          if (owner)
            Padding(
              padding: const EdgeInsets.only(
                top: 32.0,
                left: 8.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BookPageActions(
                    forceMultiSelect: forceMultiSelect,
                    multiSelectedItems: multiSelectedItems,
                    onConfirmDeleteBook: onConfirmDeleteBook,
                    onToggleMultiSelect: onToggleMultiSelect,
                    onShowRenameBookDialog: onShowRenameBookDialog,
                    onUploadToThisBook: onUploadToThisBook,
                    visible: multiSelectedItems.isEmpty,
                    visibility: book.visibility,
                    onUpdateVisibility: onUpdateVisibility,
                  ),
                  BookPageGroupActions(
                    onAddToBook: onAddToBook,
                    onClearMultiSelect: onClearMultiSelect,
                    onConfirmRemoveGroup: onConfirmRemoveGroup,
                    onMultiSelectAll: onMultiSelectAll,
                    multiSelectedItems: multiSelectedItems,
                    visible: multiSelectedItems.isNotEmpty,
                  ),
                ],
              ),
            ),
        ]),
      ),
    );
  }

  Widget likeButton(BuildContext context) {
    if (!authenticated) {
      return Container();
    }

    if (liked) {
      return IconButton(
        tooltip: "unlike".tr(),
        icon: Icon(
          FontAwesomeIcons.solidHeart,
        ),
        iconSize: 18.0,
        color: Theme.of(context).secondaryHeaderColor,
        onPressed: onLike,
      );
    }

    return IconButton(
      tooltip: "like".tr(),
      icon: Icon(
        UniconsLine.heart,
      ),
      onPressed: onLike,
    );
  }

  Widget rightRow(BuildContext context) {
    String updatedAtStr = "";

    if (DateTime.now().difference(book.updatedAt).inDays > 60) {
      updatedAtStr = "date_updated_on".tr(
        args: [
          Jiffy(book.updatedAt).yMMMMEEEEd,
        ],
      );
    } else {
      updatedAtStr = "date_updated_ago".tr(
        args: [Jiffy(book.updatedAt).fromNow()],
      );
    }

    final Color color = book.illustrations.isEmpty
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
              onPressed: Beamer.of(context).beamBack,
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
                    book.name,
                    style: Utilities.fonts.style(
                      fontSize: 40.0,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Opacity(
                  opacity: 0.6,
                  child: Text(
                    book.description,
                    style: Utilities.fonts.style(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                InkWell(
                  onTap: onShowDatesDialog,
                  child: Opacity(
                    opacity: 0.6,
                    child: Text(
                      updatedAtStr,
                      style: Utilities.fonts.style(
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
                        "illustrations_count".plural(book.illustrations.length),
                        style: Utilities.fonts.style(
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
}
