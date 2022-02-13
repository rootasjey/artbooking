import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/book/book.dart';
import 'package:artbooking/types/enums/enum_book_item_action.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
    this.onDoubleTap,
    this.onTapLike,
  });

  /// Book's data for this card.
  final Book book;

  /// Index position in a list, if available.
  final int index;

  /// Trigger when the user long press this card.
  final Function(bool)? onLongPress;

  /// Callback function when popup menu item entries are tapped.
  final void Function(EnumBookItemAction, int, Book)? onPopupMenuItemSelected;

  /// Trigger when the user taps on this card.
  final void Function()? onTap;

  /// Trigger when the user double taps on this card.
  final void Function()? onDoubleTap;

  /// Trigger when heart icon tap.
  final void Function()? onTapLike;

  /// Popup menu item entries.
  final List<PopupMenuEntry<EnumBookItemAction>> popupMenuEntries;

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

  bool _showLikeAnimation = false;
  bool _keepHeartIconVisibile = false;

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

  Widget likeOverlay() {
    if (widget.onTapLike == null) {
      return Container();
    }

    if (_elevation != 8.0 && !_keepHeartIconVisibile) {
      return Container();
    }

    final IconData iconData =
        widget.book.liked ? FontAwesomeIcons.solidHeart : UniconsLine.heart;

    final color = widget.book.liked
        ? Theme.of(context).secondaryHeaderColor
        : Colors.black26;

    return Align(
      alignment: Alignment.topRight,
      child: InkWell(
        borderRadius: BorderRadius.circular(24.0),
        onHover: (isHover) {
          _keepHeartIconVisibile = isHover;
        },
        onTap: widget.onTapLike,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Icon(
            iconData,
            color: color,
            size: 16.0,
          ),
        ),
      ),
    );
  }

  Widget likeAnimationOverlay() {
    if (!_showLikeAnimation) {
      return Container();
    }

    return ScaleTransition(
      scale: _scaleAnimation,
      child: SizedBox(
        width: 300.0,
        height: 360.0,
        child: Material(
          color: Colors.black.withOpacity(0.3),
          child: Center(
            child: Icon(
              widget.book.liked ? UniconsLine.heart : UniconsLine.heart_break,
              size: 42.0,
              color: Theme.of(context).secondaryHeaderColor,
            ),
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

    return Material(
      color: Colors.transparent,
      child: Padding(
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
                  style: Utilities.fonts.style(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            popupMenuButton(),
          ],
        ),
      ),
    );
  }

  Widget frontCard() {
    final book = widget.book;

    return Container(
      width: 300.0,
      height: 360.0,
      padding: const EdgeInsets.only(right: 12.0),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Card(
          color: widget.selected
              ? Theme.of(context).primaryColor
              : Colors.transparent,
          elevation: _elevation,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Ink.image(
                image: NetworkImage(book.getCoverLink()),
                fit: BoxFit.cover,
                child: InkWell(
                  onTap: widget.onTap,
                  onDoubleTap: onDoubleTap,
                  onLongPress: onLongPress,
                  onHover: onHover,
                  child: Stack(
                    children: [
                      multiSelectIndicator(),
                    ],
                  ),
                ),
              ),
              likeOverlay(),
              likeAnimationOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget multiSelectIndicator() {
    if (!widget.selectionMode) {
      return Container();
    }

    if (!widget.selected) {
      return Positioned(
        top: 10.0,
        right: 10.0,
        child: Material(
          elevation: 1.0,
          color: Colors.red.shade100,
          clipBehavior: Clip.hardEdge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6.0),
          ),
          child: Icon(
            UniconsLine.square_full,
            color: Colors.transparent,
          ),
        ),
      );
    }

    return Positioned(
      top: 10.0,
      right: 10.0,
      child: Material(
        elevation: 2.0,
        color: Colors.pink.shade100,
        clipBehavior: Clip.hardEdge,
        shape: RoundedRectangleBorder(
          side: BorderSide.none,
        ),
        child: Icon(
          UniconsLine.check_square,
          color: Theme.of(context).secondaryHeaderColor,
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
      onSelected: (EnumBookItemAction action) {
        widget.onPopupMenuItemSelected?.call(
          action,
          widget.index,
          widget.book,
        );
      },
      itemBuilder: (_) => widget.popupMenuEntries,
    );
  }

  void onDoubleTap() {
    widget.onDoubleTap?.call();
    setState(() => _showLikeAnimation = true);

    Future.delayed(Duration(seconds: 1), () {
      setState(() => _showLikeAnimation = false);
    });
  }

  void onHover(isHover) {
    if (isHover) {
      _elevation = 8.0;
      _scaleController.forward();
    } else {
      _elevation = _initElevation;
      _scaleController.reverse();
    }

    setState(() {});
  }

  void onLongPress() {
    if (widget.onLongPress != null) {
      widget.onLongPress?.call(widget.selected);
    }
  }
}
