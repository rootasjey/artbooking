import 'dart:async';

import 'package:artbooking/components/popup_menu/popup_menu_item_icon.dart';
import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/book/book.dart';
import 'package:artbooking/types/book/popup_entry_book.dart';
import 'package:artbooking/types/drag_data.dart';
import 'package:artbooking/types/enums/enum_book_item_action.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:supercharged/supercharged.dart';
import 'package:unicons/unicons.dart';

/// A card representing a book;
class BookCard extends StatefulWidget {
  const BookCard({
    Key? key,
    required this.book,
    required this.index,
    required this.heroTag,
    this.canDropFile = false,
    this.canDrag = false,
    this.selected = false,
    this.selectionMode = false,
    this.useAsPlaceholder = false,
    this.useBottomSheet = false,
    this.width = 400.0,
    this.height = 342.0,
    this.onDoubleTap,
    this.onDragCompleted,
    this.onDragEnd,
    this.onDragFileDone,
    this.onDragFileEntered,
    this.onDragFileExited,
    this.onDraggableCanceled,
    this.onDragStarted,
    this.onDragUpdate,
    this.onDrop,
    this.onLike,
    this.onLongPress,
    this.onPopupMenuItemSelected,
    this.onTap,
    this.onTapCaption,
    this.backIcon = UniconsLine.tear,
    this.popupMenuEntries = const [],
    this.dragGroupName = "",
  }) : super(key: key);

  /// Book's data for this card.
  final Book book;

  /// If true, the card can be dragged. Usually used to re-order items.
  final bool canDrag;

  /// If true, this book card can receive file drop to create illustration,
  /// and then adding this illustration in this book.
  final bool canDropFile;

  /// A visual indicator is built around this card, if true.
  final bool selected;

  /// If true, this card is in selection mode
  /// alongside all other cards in the list/grid, if any.
  final bool selectionMode;

  /// If true, this card will be used as a place holder.
  final bool useAsPlaceholder;

  /// If true, a bottom sheet will be displayed on long press event.
  /// Setting this property to true will deactivate popup menu and
  /// hide like button.
  final bool useBottomSheet;

  /// Book card's width.
  final double width;

  /// Book card's height.
  final double height;

  /// Callback fired on double tap.
  final void Function()? onDoubleTap;

  /// Callback fired on drag completed.
  final void Function()? onDragCompleted;

  /// Callback fired on drag end .
  final void Function(DraggableDetails)? onDragEnd;

  /// Callback fired on drag canceled.
  final void Function(Velocity, Offset)? onDraggableCanceled;

  final void Function(
    Book book,
    DropDoneDetails dropDoneDetails,
  )? onDragFileDone;

  /// Callback fired on drag started.
  final void Function()? onDragStarted;

  /// Callback fired on drag update.
  final void Function(DragUpdateDetails details)? onDragUpdate;

  /// Callback fired when drag and dropping items on this card.
  final void Function(int dropTargetIndex, List<int> dragIndexes)? onDrop;

  /// Callback fired on long press.
  final void Function(Book book, bool selected)? onLongPress;

  /// Callback fired when one of the popup menu item entries is selected.
  final void Function(
    EnumBookItemAction action,
    int index,
    Book book,
  )? onPopupMenuItemSelected;

  /// Callback fired on tap.
  final void Function()? onTap;

  final void Function(Book book)? onTapCaption;

  /// Callback fired on tap heart icon.
  final void Function(Book book)? onLike;

  /// Callback event fired when files started to being dragged over this book.
  final void Function(DropEventDetails details)? onDragFileEntered;

  /// Callback event fired when files exited to being dragged over this book.
  final void Function(DropEventDetails details)? onDragFileExited;

  /// `IconData` behind this card while dragging.
  final IconData backIcon;

  /// Index position in a list, if available.
  final int index;

  /// Menu item list displayed after tapping on the corresponding popup button.
  final List<PopupEntryBook> popupMenuEntries;

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
  /// Carde scale animation.
  late Animation<double> _scaleAnimation;

  /// Carde scale animation controller.
  /// Animation can be started, paused, stopped, reversed etc. with this.
  late AnimationController _scaleController;

  bool _isFileHover = false;

  /// Briefly show like animation if true.
  bool _showLikeAnimation = false;

  /// Display popup menu if true.
  /// Because we only show popup menu on hover.
  bool _showPopupMenu = false;

  /// Book's name height.
  final double _captionHeight = 42.0;

  /// Card's border radius.
  final double _cardRadius = 8.0;

  /// Initial elevation.
  double _initElevation = 6.0;

  /// Current elevation.
  double _elevation = 4.0;

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
          child: widget.canDrag ? dragTarget() : fullstackCard(),
        ),
      ),
    );
  }

  /// Card wrapper to enable using book card as drop target.
  Widget dragTarget() {
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
      child: DropTarget(
        enable: widget.canDropFile,
        onDragDone: onDragFileDone,
        onDragEntered: onDragFileEntered,
        onDragExited: onDragFileExited,
        child: fullstackCard(
          usingAsDropTarget: usingAsDropTarget,
        ),
      ),
      childWhenDragging: childWhenDragging(),
      data: DragData(
        index: widget.index,
        groupName: widget.dragGroupName,
        type: BookCard,
      ),
      feedback: draggingCard(),
      onDragCompleted: widget.onDragCompleted,
      onDragEnd: widget.onDragEnd,
      onDragStarted: widget.onDragStarted,
      onDraggableCanceled: widget.onDraggableCanceled,
      onDragUpdate: widget.onDragUpdate,
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
          width: widget.width - 80.0,
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
                        child: getVisualChild(textValue: textValue),
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

  Widget getVisualChild({required String textValue}) {
    if (widget.width < 300.0) {
      return Icon(widget.backIcon);
    }

    return Text(
      textValue.isNotEmpty ? textValue : "book_permutation_description".tr(),
      textAlign: TextAlign.center,
      style: Utilities.fonts.body4(
        fontSize: 18.0,
        fontWeight: FontWeight.w400,
      ),
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
    return Material(
      color: Colors.transparent,
      child: Container(
        width: widget.width - 50.0,
        padding: const EdgeInsets.only(
          left: 20.0,
          right: 16.0,
          top: 8.0,
        ),
        child: InkWell(
          onTap: widget.onTapCaption != null
              ? () => widget.onTapCaption?.call(widget.book)
              : null,
          child: Opacity(
            opacity: 0.8,
            child: Text(
              widget.book.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Utilities.fonts.body(
                fontSize: 14.0,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget dropHint() {
    if (!_isFileHover) {
      return Container();
    }

    return Positioned(
      bottom: 12.0,
      left: 0.0,
      right: 0.0,
      child: Align(
        alignment: Alignment.center,
        child: SizedBox(
          width: widget.width / 1.5,
          child: Card(
            elevation: 12.0,
            color: Constants.colors.tertiary,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                "illustration_upload_file_to_book".tr(),
                style: Utilities.fonts.body(
                  color: Colors.black,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget frontCard({
    bool usingAsDropTarget = false,
  }) {
    final Color borderColor = _isFileHover
        ? Constants.colors.tertiary
        : Theme.of(context).primaryColor;
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
            color: widget.selected ? borderColor : Colors.transparent,
            elevation: _elevation,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_cardRadius),
              side: usingAsDropTarget || _isFileHover
                  ? BorderSide(color: borderColor, width: 4.0)
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
                            onLongPress:
                                widget.useBottomSheet && !widget.canDrag
                                    ? onLongPress
                                    : null,
                            onHover: onHoverFrontCard,
                            child: Stack(
                              children: [
                                multiSelectIndicator(),
                                likeIcon(),
                                popupMenuButton(),
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
                likeAnimationOverlay(),
                dropHint(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Like icon to toggle favourite.
  Widget likeIcon() {
    if (widget.onLike == null) {
      return Container();
    }

    if (!_showPopupMenu) {
      return Container();
    }

    final IconData iconData =
        widget.book.liked ? FontAwesomeIcons.solidHeart : UniconsLine.heart;

    final color = widget.book.liked
        ? Theme.of(context).secondaryHeaderColor
        : Colors.black;

    return Positioned(
      top: 10.0,
      left: 10.0,
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0, top: 8.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(24.0),
          onTap: () => widget.onLike?.call(widget.book),
          child: Container(
            padding: const EdgeInsets.all(6.0),
            decoration: BoxDecoration(
              color: Constants.colors.clairPink,
              borderRadius: BorderRadius.circular(24.0),
            ),
            child: Icon(
              iconData,
              color: color,
              size: 16.0,
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
    if (widget.popupMenuEntries.isEmpty || widget.useBottomSheet) {
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

  void onDoubleTap() {
    widget.onDoubleTap?.call();
    setState(() => _showLikeAnimation = true);

    Future.delayed(Duration(seconds: 1), () {
      setState(() => _showLikeAnimation = false);
    });
  }

  void onDragFileDone(DropDoneDetails details) {
    if (widget.onDragFileDone == null) {
      return;
    }

    widget.onDragFileDone?.call(widget.book, details);
  }

  /// Callback fired when the hover state of the front card of the book changes.
  void onHoverFrontCard(isHover) {
    if (isHover) {
      // Don't show popup menu button if we're using modal bottom sheet.
      if (!widget.useBottomSheet) {
        _showPopupMenu = true;
      }

      setState(() {
        _elevation = _initElevation * 1.5;
        _scaleController.forward();
      });

      return;
    }

    setState(() {
      _elevation = _initElevation;
      _scaleController.reverse();
      _showPopupMenu = false;
    });
  }

  void onLongPress() {
    showCupertinoModalBottomSheet(
      context: context,
      expand: false,
      backgroundColor: Colors.white70,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Material(
            borderRadius: BorderRadius.circular(8.0),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: widget.popupMenuEntries.map((popupMenuEntry) {
                  final popupMenuItemIcon =
                      popupMenuEntry as PopupMenuItemIcon<EnumBookItemAction>;

                  return ListTile(
                    title: Opacity(
                      opacity: 0.8,
                      child: Text(
                        popupMenuItemIcon.textLabel,
                        style: Utilities.fonts.body(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    trailing: popupMenuItemIcon.icon,
                    onTap: () {
                      Navigator.of(context).pop();
                      final EnumBookItemAction? action =
                          popupMenuItemIcon.value;

                      if (action == null) {
                        return;
                      }

                      widget.onPopupMenuItemSelected?.call(
                        action,
                        widget.index,
                        widget.book,
                      );
                    },
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );

    widget.onLongPress?.call(
      widget.book,
      widget.selected,
    );
  }

  void onDragFileEntered(DropEventDetails details) {
    setState(() => _isFileHover = true);
    widget.onDragFileEntered?.call(details);
  }

  void onDragFileExited(DropEventDetails details) {
    setState(() => _isFileHover = false);
    widget.onDragFileExited?.call(details);
  }
}
