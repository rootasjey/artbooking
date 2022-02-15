import 'dart:async';

import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/book/book.dart';
import 'package:artbooking/types/enums/enum_book_item_action.dart';
import 'package:artbooking/types/illustration/illustration.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
    this.width = 360.0,
    this.height = 402.0,
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

  final double width;
  final double height;

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

  final double _captionHeight = 42.0;
  final double _cardRadius = 8.0;

  int _indexSlideshow = 0;
  List<Illustration> _lastIllustrations = [];
  String _coverLink = "";
  Timer? _timerSlideshow;

  @override
  void initState() {
    super.initState();

    _coverLink = widget.book.getCoverLink();
    _scaleController = createController()..duration = 250.milliseconds;
    _scaleAnimation =
        0.6.tweenTo(1.0).animatedBy(_scaleController).curve(Curves.elasticOut);

    setState(() => _elevation = _initElevation);
  }

  @override
  void dispose() {
    _timerSlideshow?.cancel();
    _lastIllustrations.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: widget.book.id,
      child: OverflowBox(
        // avoid hero animation overflow
        minHeight: widget.height - _captionHeight,
        maxHeight: widget.height,
        child: SizedBox(
          width: widget.width,
          height: widget.height,
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
        width: widget.width - 60.0,
        height: widget.height - _captionHeight,
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
      width: widget.width - 160.0,
      child: SizedBox(
        width: widget.width - 80.0,
        height: widget.height - _captionHeight,
        child: Card(
          elevation: _elevation / 2.0,
          color: Colors.white70,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_cardRadius),
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
      child: Container(
        width: widget.width - 50.0,
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
    return Container(
      width: widget.width - 60.0,
      height: widget.height - _captionHeight,
      padding: const EdgeInsets.only(right: 12.0),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Card(
          color: widget.selected
              ? Theme.of(context).primaryColor
              : Colors.transparent,
          elevation: _elevation,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_cardRadius),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Ink.image(
                image: NetworkImage(_coverLink),
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

  /// Fetch last illustrations of this book.
  Future fetchLastIllustrations() async {
    final Book book = widget.book;
    if (book.illustrations.isEmpty) {
      return;
    }

    _lastIllustrations.clear();

    final int arrayLength = book.illustrations.length;
    final int end = arrayLength > 4 ? 5 : arrayLength;
    final illustrations = book.illustrations.sublist(0, end);

    try {
      for (var illustrationBook in illustrations) {
        final snapshot = await FirebaseFirestore.instance
            .collection("illustrations")
            .doc(illustrationBook.id)
            .get();

        final data = snapshot.data();
        if (!snapshot.exists || data == null) {
          continue;
        }

        final illustration = Illustration.fromMap(data);
        _lastIllustrations.add(illustration);
      }
    } catch (error) {
      Utilities.logger.e(error);
    }
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
      startCoverSlideshow();
    } else {
      _elevation = _initElevation;
      _scaleController.reverse();
      stopCoverSlideshow();
    }

    setState(() {});
  }

  void onLongPress() {
    if (widget.onLongPress != null) {
      widget.onLongPress?.call(widget.selected);
    }
  }

  void startCoverSlideshow() async {
    if (_lastIllustrations.isEmpty) {
      await fetchLastIllustrations();
    }

    if (_lastIllustrations.isEmpty) {
      return;
    }

    _indexSlideshow = 0;

    setState(() {
      _coverLink = _lastIllustrations.first.getThumbnail();
    });

    _timerSlideshow?.cancel();
    _timerSlideshow = Timer.periodic(
      Duration(seconds: 2),
      (time) {
        _indexSlideshow++;

        if (_indexSlideshow >= _lastIllustrations.length) {
          stopCoverSlideshow();
          return;
        }

        setState(() {
          _coverLink =
              _lastIllustrations.elementAt(_indexSlideshow).getThumbnail();
        });
      },
    );
  }

  void stopCoverSlideshow() {
    _timerSlideshow?.cancel();
    _coverLink = widget.book.getCoverLink();
  }
}
