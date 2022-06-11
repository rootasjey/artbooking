import 'dart:async';

import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/book/book.dart';
import 'package:artbooking/types/drag_data.dart';
import 'package:artbooking/types/enums/enum_book_item_action.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:supercharged/supercharged.dart';
import 'package:unicons/unicons.dart';

/// A card representing a book;
class BookCard extends StatefulWidget {
  const BookCard({
    Key? key,
    required this.book,
    required this.heroTag,
    required this.index,
    this.onLongPress,
    this.onPopupMenuItemSelected,
    this.onTap,
    this.onDoubleTap,
    this.onTapLike,
    this.popupMenuEntries = const [],
    this.selected = false,
    this.selectionMode = false,
    this.width = 400.0,
    this.height = 342.0,
    this.onDrop,
    this.onDragUpdate,
    this.canDrag = false,
    this.useAsPlaceholder = false,
    this.dragGroupName = "",
  }) : super(key: key);

  /// If true, this card will be used as a place holder.
  final bool useAsPlaceholder;

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

  /// Callback when book is being dragged.
  final void Function(DragUpdateDetails details)? onDragUpdate;

  /// Popup menu item entries.
  final List<PopupMenuEntry<EnumBookItemAction>> popupMenuEntries;

  /// If true, this card is in selection mode
  /// alongside all other cards in the list/grid, if any.
  final bool selected;

  /// If true, this card is in selection mode
  /// alongside all other cards in the list/grid, if any.
  final bool selectionMode;

  /// If true, the card can be dragged.
  /// Usually used to re-order items.
  final bool canDrag;

  /// Book card width.
  final double width;

  /// Book card height.
  final double height;

  /// Callback when drag and dropping items on this book card.
  final void Function(int dropTargetIndex, List<int> dragIndexes)? onDrop;

  /// An arbitrary name given to this item's drag group
  ///  (e.g. "home-books"). Thus to avoid dragging items between sections.
  final String dragGroupName;

  /// An unique tag to identify a single component for animation.
  /// This tag must be unique on the page and among a list.
  /// If you're not sure what to put, just use the illustration's id.
  final String heroTag;

  @override
  _BookCardState createState() => _BookCardState();
}

class _BookCardState extends State<BookCard> with AnimationMixin {
  late Animation<double> _scaleAnimation;
  late AnimationController _scaleController;

  double _initElevation = 6.0;
  double _elevation = 4.0;

  bool _showLikeAnimation = false;
  bool _keepHeartIconVisibile = false;

  final double _captionHeight = 42.0;
  final double _cardRadius = 8.0;

  @override
  void initState() {
    super.initState();

    _scaleController = createController()..duration = 250.milliseconds;
    _scaleAnimation =
        0.6.tweenTo(1.0).animatedBy(_scaleController).curve(Curves.elasticOut);

    setState(() => _elevation = _initElevation);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.useAsPlaceholder) {
      return childWhenDragging(
        textValue: "book_add_new".tr(),
        onTapPlaceholder: widget.onTap,
      );
    }

    return Hero(
      tag: widget.heroTag,
      child: OverflowBox(
        // avoid hero animation overflow
        minHeight: widget.height - _captionHeight,
        maxHeight: widget.height,
        child: SizedBox(
          width: widget.width,
          height: widget.height,
          child: widget.canDrag ? dropTarget() : fullstackCard(),
        ),
      ),
    );
  }

  /// Card wrapper to enable using book card as drop target.
  Widget dropTarget() {
    return DragTarget<DragData>(
      builder: (BuildContext context, candidateItems, rejectedItems) {
        return draggableCard(
          usingAsDropTarget: candidateItems.isNotEmpty,
        );
      },
      onAccept: (DragData dragData) {
        widget.onDrop?.call(widget.index, [dragData.index]);
      },
      onWillAccept: (DragData? dragData) {
        if (dragData == null) {
          return false;
        }

        if (dragData.type != BookCard) {
          return false;
        }

        if (dragData.groupName != widget.dragGroupName) {
          return false;
        }

        return true;
      },
    );
  }

  /// Card wrapper to enable dragging.
  Widget draggableCard({bool usingAsDropTarget = false}) {
    return LongPressDraggable<DragData>(
      data: DragData(
        index: widget.index,
        groupName: widget.dragGroupName,
        type: BookCard,
      ),
      feedback: draggingCard(),
      childWhenDragging: childWhenDragging(),
      onDragUpdate: widget.onDragUpdate,
      child: fullstackCard(
        usingAsDropTarget: usingAsDropTarget,
      ),
    );
  }

  /// Actual card with back, front & caption.
  Widget fullstackCard({bool usingAsDropTarget = false}) {
    return Column(
      children: [
        Stack(
          children: [
            backCardAfter(),
            backCardBefore(),
            frontCard(
              usingAsDropTarget: usingAsDropTarget,
            ),
          ],
        ),
        caption(),
      ],
    );
  }

  /// Widget which stays at the original place when dragging starts.
  Widget childWhenDragging({
    String textValue = "",
    Function()? onTapPlaceholder,
  }) {
    return Column(
      children: [
        Container(
          width: widget.width - 40.0,
          height: widget.height - 30.0,
          padding: const EdgeInsets.all(8.0),
          child: DottedBorder(
            strokeWidth: 3.0,
            borderType: BorderType.RRect,
            radius: Radius.circular(16),
            color: Theme.of(context).primaryColor.withOpacity(0.6),
            dashPattern: [8, 4],
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(16)),
              child: Card(
                elevation: 0.0,
                color: Constants.colors.clairPink.withOpacity(0.6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                clipBehavior: Clip.hardEdge,
                child: InkWell(
                  onTap: onTapPlaceholder,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Opacity(
                      opacity: 0.6,
                      child: Center(
                        child: Text(
                          textValue.isNotEmpty
                              ? textValue
                              : "book_permutation_description".tr(),
                          textAlign: TextAlign.center,
                          style: Utilities.fonts.body(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget draggingCard() {
    return Stack(
      children: [
        backCardAfter(),
        backCardBefore(),
        frontCard(),
      ],
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

  Widget backCardAfter() {
    return Positioned(
      top: 0.0,
      right: 0.0,
      width: widget.width - 100.0,
      child: SizedBox(
        width: widget.width - 80.0,
        height: widget.height - _captionHeight,
        child: Card(
          elevation: _elevation / 3.0,
          color: Constants.colors.clairPink,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_cardRadius),
          ),
          clipBehavior: Clip.hardEdge,
        ),
      ),
    );
  }

  Widget backCardBefore() {
    return Positioned(
      top: 0.0,
      right: 12.0,
      width: widget.width - 100.0,
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
                  style: Utilities.fonts.body(
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

  Widget frontCard({bool usingAsDropTarget = false}) {
    final Color primaryColor = Theme.of(context).primaryColor;
    final onDoubleTapOrNull = widget.onDoubleTap != null ? onDoubleTap : null;
    final double width = widget.width - 80.0;

    return Opacity(
      opacity: widget.book.available ? 1.0 : 0.9,
      child: Container(
        width: width,
        height: widget.height - _captionHeight,
        padding: const EdgeInsets.only(right: 24.0),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Card(
            color: widget.selected ? primaryColor : Colors.transparent,
            elevation: _elevation,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_cardRadius),
              side: usingAsDropTarget
                  ? BorderSide(color: primaryColor, width: 4.0)
                  : BorderSide.none,
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                ExtendedImage.network(
                  widget.book.getCoverLink(),
                  fit: BoxFit.cover,
                  width: width,
                  height: widget.height - _captionHeight,
                  clearMemoryCacheWhenDispose: true,
                  loadStateChanged: (state) {
                    switch (state.extendedImageLoadState) {
                      case LoadState.completed:
                        return Ink.image(
                          image: state.imageProvider,
                          fit: BoxFit.cover,
                          child: InkWell(
                            onTap: widget.onTap,
                            onDoubleTap: onDoubleTapOrNull,
                            // onLongPress: onLongPress,
                            onHover: onHover,
                            child: Stack(
                              children: [
                                multiSelectIndicator(),
                              ],
                            ),
                          ),
                        );
                      case LoadState.loading:
                        return loadingCard();
                      case LoadState.failed:
                        return InkWell(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                "image_load_failed".tr(),
                                style: Utilities.fonts.body(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          onTap: () {
                            state.reLoadImage();
                          },
                        );
                      default:
                        return state.completedWidget;
                    }
                  },
                ),
                likeOverlay(),
                likeAnimationOverlay(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget loadingCard() {
    return Card(
      color: Constants.colors.clairPink,
      elevation: _elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_cardRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: Shimmer(
        colorOpacity: 0.2,
        color: Theme.of(context).primaryColor,
        child: Container(),
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
    if (widget.popupMenuEntries.isEmpty) {
      return Container();
    }

    return PopupMenuButton(
      icon: Opacity(
        opacity: 0.8,
        child: Icon(
          UniconsLine.ellipsis_h,
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
      _elevation = _initElevation * 1.5;
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
