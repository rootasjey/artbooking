import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/book/book.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:unicons/unicons.dart';

/// A tile representing a book.
class BookTile extends StatelessWidget {
  const BookTile({
    Key? key,
    required this.book,
    this.selected = false,
    this.onTapBook,
  }) : super(key: key);

  /// Main data.
  final Book book;

  /// If true, This tile will be highlited.
  final bool selected;

  /// Callback fired when this tile is tapped.
  final void Function(Book book)? onTapBook;

  @override
  Widget build(BuildContext context) {
    String updatedAt = "";

    if (DateTime.now().difference(book.updatedAt).inDays > 60) {
      updatedAt = "date_updated_on".tr(
        args: [Jiffy(book.updatedAt).yMMMMEEEEd],
      ).toLowerCase();
    } else {
      updatedAt = "date_updated_ago".tr(
        args: [Jiffy(book.updatedAt).fromNow()],
      ).toLowerCase();
    }

    final double cardWidth = 100.0;
    final double cardHeight = 100.0;

    final Color primaryColor = Theme.of(context).primaryColor;
    final BorderSide borderSide = selected
        ? BorderSide(color: primaryColor, width: 2.0)
        : BorderSide.none;

    final Color? textColor = selected ? Colors.white : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Positioned(
                    top: 0.0,
                    right: 0.0,
                    width: cardWidth,
                    child: SizedBox(
                      width: cardWidth,
                      height: cardHeight,
                      child: Card(
                        elevation: 2.0,
                        color: Constants.colors.clairPink,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        clipBehavior: Clip.hardEdge,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0.0,
                    right: 4.0,
                    width: cardWidth - 4,
                    child: SizedBox(
                      width: cardWidth,
                      height: cardHeight,
                      child: Card(
                        elevation: 2.0,
                        color: Colors.white70,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        clipBehavior: Clip.hardEdge,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(right: 8.0),
                    height: cardHeight,
                    width: cardWidth,
                    child: Card(
                      elevation: 3.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        side: borderSide,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Ink.image(
                        image: NetworkImage(book.getCoverLink()),
                        width: cardWidth,
                        height: cardHeight,
                        fit: BoxFit.cover,
                        child: InkWell(
                          onTap: () => onTapBook?.call(book),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4.0, right: 12.0),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8.0),
                    onTap: () => onTapBook?.call(book),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Container(
                        color: selected ? primaryColor : null,
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Opacity(
                              opacity: 0.8,
                              child: Text(
                                book.name,
                                maxLines: 1,
                                style: Utilities.fonts.body(
                                  color: textColor,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            Opacity(
                              opacity: 0.4,
                              child: Text(
                                book.description,
                                maxLines: 1,
                                style: Utilities.fonts.body(
                                  color: textColor,
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Opacity(
                              opacity: 0.6,
                              child: Text(
                                "illustrations_count".plural(book.count),
                                maxLines: 1,
                                style: Utilities.fonts.body(
                                  color: textColor,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Opacity(
                              opacity: 0.3,
                              child: Text(
                                updatedAt,
                                maxLines: 1,
                                style: Utilities.fonts.body(
                                  color: textColor,
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (selected)
            Positioned(
              right: 18.0,
              top: 0.0,
              bottom: 0.0,
              child: Icon(
                UniconsLine.check_circle,
                color: textColor,
              ),
            ),
        ],
      ),
    );
  }
}
