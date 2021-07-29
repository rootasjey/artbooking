import 'package:artbooking/state/colors.dart';
import 'package:artbooking/types/book.dart';
import 'package:artbooking/types/enums.dart';
import 'package:artbooking/utils/fonts.dart';
import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:supercharged/supercharged.dart';
import 'package:unicons/unicons.dart';

/// A card representing a book;
class BookCard extends StatefulWidget {
  BookCard({
    required this.book,
    this.selected = false,
    this.selectionMode = false,
    this.onLongPress,
    this.popupMenuEntries = const [],
    this.onPopupMenuItemSelected,
    this.index = 0,
    this.onTap,
  });

  /// Book's data for this card.
  final Book book;

  /// Index position in a list, if available.
  final int index;

  /// Trigger when the user long press this card.
  final Function(bool)? onLongPress;

  /// Callback function when popup menu item entries are tapped.
  final void Function(BookItemAction, int, Book)? onPopupMenuItemSelected;

  /// Trigger when the user taps on this card.
  final Function()? onTap;

  /// Popup menu item entries.
  final List<PopupMenuEntry<BookItemAction>> popupMenuEntries;

  /// If true, this card is in selection mode
  /// alongside all other cards in the list/grid, if any.
  final bool selected;

  /// If true, this card is in selection mode
  /// alongside all other cards in the list/grid, if any.
  final bool selectionMode;

  @override
  _BookCardState createState() => _BookCardState();
}

class _BookCardState extends State<BookCard> with AnimationMixin {
  late Animation<double> _scaleAnimation;
  late AnimationController _scaleController;

  double _initElevation = 4.0;
  double _elevation = 4.0;

  @override
  void initState() {
    super.initState();

    _scaleController = createController()..duration = 250.milliseconds;

    _scaleAnimation =
        0.6.tweenTo(1.0).animatedBy(_scaleController).curve(Curves.elasticOut);

    setState(() {
      _elevation = _initElevation;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: widget.book.id,
      child: OverflowBox(
        // avoid hero animation overflow
        minHeight: 360.0,
        maxHeight: 402.0,
        child: SizedBox(
          width: 360.0,
          height: 440.0,
          child: Column(
            children: [
              Stack(
                children: [
                  backCard(),
                  frontCard(),
                ],
              ),
              caption(),
            ],
          ),
        ),
      ),
    );
  }

  Widget backCard() {
    return Positioned(
      top: 0.0,
      right: 0.0,
      width: 200.0,
      child: SizedBox(
        width: 280.0,
        height: 360.0,
        child: Card(
          elevation: _elevation / 2.0,
          color: Colors.white70,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          clipBehavior: Clip.hardEdge,
        ),
      ),
    );
  }

  Widget caption() {
    final illustration = widget.book;

    return Padding(
      padding: const EdgeInsets.only(
        left: 16.0,
        right: 16.0,
      ),
      child: Row(
        children: [
          Expanded(
            child: Opacity(
              opacity: 0.8,
              child: Text(
                illustration.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: FontsUtils.mainStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          popupMenuButton(),
        ],
      ),
    );
  }

  Widget frontCard() {
    final book = widget.book;
    ImageProvider imageProvider;

    if (book.cover.custom.url.isNotEmpty) {
      imageProvider = NetworkImage(book.cover.custom.url);
    } else if (book.cover.auto.url.isNotEmpty) {
      imageProvider = NetworkImage(book.cover.auto.url);
    } else {
      imageProvider = NetworkImage(
        "https://firebasestorage.googleapis.com/"
        "v0/b/artbooking-54d22.appspot.com/o/static"
        "%2Fimages%2Fbook_cover_512x683.png"
        "?alt=media&token=d77bc23b-90d7-4663-be3a-e878c6403e51",
      );
    }

    return Container(
      width: 300.0,
      height: 360.0,
      padding: const EdgeInsets.only(right: 12.0),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Card(
          color: widget.selected ? stateColors.primary : Colors.transparent,
          elevation: _elevation,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          clipBehavior: Clip.antiAlias,
          child: Ink.image(
            image: imageProvider,
            fit: BoxFit.cover,
            child: InkWell(
              onTap: widget.onTap,
              onLongPress: () {
                if (widget.onLongPress != null) {
                  widget.onLongPress!(widget.selected);
                }
              },
              onHover: (isHover) {
                if (isHover) {
                  _elevation = 8.0;
                  _scaleController.forward();
                } else {
                  _elevation = _initElevation;
                  _scaleController.reverse();
                }

                setState(() {});
              },
              child: Stack(
                children: [
                  // caption(),
                  multiSelectButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget multiSelectButton() {
    if (!widget.selectionMode) {
      return Container();
    }

    if (!widget.selected) {
      return Positioned(
        top: 10.0,
        right: 10.0,
        child: Material(
          elevation: 2.0,
          color: Colors.white,
          clipBehavior: Clip.hardEdge,
          shape: CircleBorder(),
          child: Icon(
            Icons.circle,
            color: stateColors.primary,
          ),
        ),
      );
    }

    return Positioned(
      top: 10.0,
      right: 10.0,
      child: Material(
        elevation: 2.0,
        color: Colors.white,
        clipBehavior: Clip.hardEdge,
        shape: CircleBorder(),
        child: Icon(
          Icons.check_circle,
          color: stateColors.primary,
        ),
      ),
    );
  }

  Widget popupMenuButton() {
    return PopupMenuButton(
      icon: Opacity(
        opacity: 0.8,
        child: Icon(
          UniconsLine.ellipsis_h,
        ),
      ),
      onSelected: (BookItemAction action) {
        widget.onPopupMenuItemSelected?.call(
          action,
          widget.index,
          widget.book,
        );
      },
      itemBuilder: (_) => widget.popupMenuEntries,
    );
  }
}
