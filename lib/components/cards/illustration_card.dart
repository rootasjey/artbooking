import 'package:artbooking/actions/illustrations.dart';
import 'package:artbooking/components/resizer/frame.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/drag_data.dart';
import 'package:artbooking/types/enums/enum_illustration_item_action.dart';
import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/types/illustration/illustration.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:supercharged/supercharged.dart';
import 'package:unicons/unicons.dart';

/// A component representing an illustration with its main content (an image).
class IllustrationCard extends StatefulWidget {
  /// Create a new illustration card.
  const IllustrationCard({
    Key? key,
    required this.heroTag,
    required this.illustration,
    required this.index,
    this.illustrationKey = '',
    this.selected = false,
    this.selectionMode = false,
    this.onLongPress,
    this.size = 300.0,
    this.onPopupMenuItemSelected,
    this.onTap,
    this.popupMenuEntries = const [],
    this.onDoubleTap,
    this.onTapLike,
    this.onDrop,
    this.onGrowUp,
    this.onDragUpdate,
    this.onResizeEnd,
    this.canDrag = false,
    this.canResize = false,
    this.useAsPlaceholder = false,
    this.useIconPlaceholder = false,
    this.dragGroupName = "",
    this.padding = EdgeInsets.zero,
  }) : super(key: key);

  /// Index position in a list, if available.
  final int index;

  /// If true, this card will be used as a placeholder.
  final bool useAsPlaceholder;

  /// If true, a "plus" icon will be used as the placeholder child.
  final bool useIconPlaceholder;

  /// If true, the card will be marked with a check circle.
  final bool selected;

  /// If true, this card is in selection mode
  /// alongside all other cards in the list/grid, if any.
  final bool selectionMode;

  /// If true, the card can be dragged.
  /// Usually used to re-order items.
  final bool canDrag;

  /// If true, the card can be resized.
  final bool canResize;

  /// Illustration's data for this card.
  final Illustration illustration;

  /// Trigger when the user long press this card.
  final void Function(String, Illustration, bool)? onLongPress;

  /// Card's size (width = height).
  final double size;

  /// Card's padding.
  final EdgeInsets padding;

  /// Trigger when the user double taps on this card.
  final void Function()? onDoubleTap;

  /// Trigger when this illustration card' resize ends.
  final void Function(
    Size endSize,
    Size originalSize,
    DragEndDetails details,
    int index,
  )? onResizeEnd;

  /// Function callback to handle illustration card grows up.
  /// This fires after onTap on a button.
  final void Function(int index)? onGrowUp;

  /// Trigger when the user taps on this card.
  final void Function()? onTap;

  /// Trigger when heart icon tap.
  final void Function()? onTapLike;

  /// Popup menu item entries.
  final List<PopupMenuEntry<EnumIllustrationItemAction>> popupMenuEntries;

  /// Callback function when popup menu item entries are tapped.
  final void Function(
    EnumIllustrationItemAction action,
    int index,
    Illustration illustration,
    String illustrationKey,
  )? onPopupMenuItemSelected;

  /// An arbitrary name given to this item's drag group
  ///  (e.g. "home-illustrations"). Thus to avoid dragging items between sections.
  final String dragGroupName;

  /// Custom app generated key to perform operations quicker.
  final String illustrationKey;

  /// An unique tag to identify a single component for animation.
  /// This tag must be unique on the page and among a list.
  /// If you're not sure what to put, just use the illustration's id.
  final String heroTag;

  /// Callback when drag and dropping items on this illustration card.
  final void Function(int dropTargetIndex, List<int> dragIndexes)? onDrop;

  /// Callback when illustration is being dragged.
  final void Function(DragUpdateDetails details)? onDragUpdate;

  @override
  _IllustrationCardState createState() => _IllustrationCardState();
}

class _IllustrationCardState extends State<IllustrationCard>
    with AnimationMixin {
  late Animation<double> _scaleAnimation;
  late AnimationController _scaleController;

  bool _showPopupMenu = false;

  bool _showLikeAnimation = false;
  bool _keepHeartIconVisibile = false;

  double _startElevation = 3.0;
  double _endElevation = 6.0;
  double _elevation = 4.0;

  @override
  void initState() {
    super.initState();

    _scaleController = createController()..duration = 250.milliseconds;
    _scaleAnimation =
        0.6.tweenTo(1.0).animatedBy(_scaleController).curve(Curves.elasticOut);

    setState(() => _elevation = _startElevation);
    checkProperties();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.useAsPlaceholder) {
      return childWhenDragging(
        textValue: "illustration_add_new".tr(),
        onTapPlaceholder: widget.onTap,
      );
    }

    final illustration = widget.illustration;
    Widget child = Container();

    if (widget.canDrag) {
      child = dropTarget();
    } else {
      child = imageCard(
        usingAsDropTarget: false,
      );
    }

    if (illustration.getThumbnail().isEmpty) {
      child = loadingCard();
    }

    return Padding(
      padding: widget.padding,
      child: Hero(
        tag: widget.heroTag,
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: child,
          ),
        ),
      ),
    );
  }

  Widget dropTarget() {
    return DragTarget<DragData>(
      builder: (BuildContext context, candidateItems, rejectedItems) {
        return imageCard(
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

        if (dragData.type != IllustrationCard) {
          return false;
        }

        if (dragData.groupName != widget.dragGroupName) {
          return false;
        }

        return true;
      },
    );
  }

  Widget imageCard({bool usingAsDropTarget = false}) {
    final String imageUrl = widget.illustration.getThumbnail();
    final Color defaultColor = Colors.transparent;
    final Color primaryColor = Theme.of(context).primaryColor;

    BorderSide borderSide = BorderSide.none;

    if (usingAsDropTarget || widget.selected) {
      borderSide = BorderSide(color: primaryColor, width: 4.0);
    }

    Widget cardChild = Card(
      color: widget.selected ? primaryColor : defaultColor,
      elevation: _elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: borderSide,
      ),
      clipBehavior: Clip.antiAlias,
      child: ExtendedImage.network(
        imageUrl,
        fit: BoxFit.cover,
        width: widget.size,
        height: widget.size,
        clearMemoryCacheWhenDispose: true,
        loadStateChanged: (state) {
          switch (state.extendedImageLoadState) {
            case LoadState.loading:
              return loadingCard();
            case LoadState.completed:
              return Ink.image(
                image: state.imageProvider,
                fit: BoxFit.cover,
                child: InkWell(
                  onTap: widget.onTap,
                  // onLongPress: onLongPressImage,
                  onHover: onHoverImage,
                  onDoubleTap: widget.onDoubleTap != null ? onDoubleTap : null,
                  child: Stack(
                    children: [
                      multiSelectIndicator(),
                      likeOverlay(),
                      likeAnimationOverlay(),
                      borderOverlay(),
                      popupMenuButton(),
                    ],
                  ),
                ),
              );
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
    );

    if (widget.canDrag) {
      cardChild = LongPressDraggable<DragData>(
        data: DragData(
          index: widget.index,
          groupName: widget.dragGroupName,
          type: IllustrationCard,
        ),
        feedback: draggingCard(),
        childWhenDragging: childWhenDragging(),
        onDragUpdate: widget.onDragUpdate,
        child: cardChild,
      );
    }

    if (widget.illustration.id.isEmpty) {
      cardChild = Opacity(
        opacity: 0.4,
        child: cardChild,
      );
    }

    return cardChild;
  }

  Widget childWhenDragging({
    String textValue = "",
    Function()? onTapPlaceholder,
  }) {
    return Container(
      width: widget.size - 30.0,
      height: widget.size - 30.0,
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
                    child: getVisualChild(
                      textValue: textValue,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget getVisualChild({
    required String textValue,
  }) {
    if (widget.useIconPlaceholder) {
      return Icon(UniconsLine.plus);
    }

    return Text(
      textValue.isNotEmpty
          ? textValue
          : "illustration_permutation_description".tr(),
      textAlign: TextAlign.center,
      style: Utilities.fonts.body(
        fontSize: 18.0,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget draggingCard() {
    String imageUrl = widget.illustration.getThumbnail();

    return Card(
      elevation: 8.0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: ExtendedImage.network(
        imageUrl,
        fit: BoxFit.cover,
        width: widget.size / 1.3,
        height: widget.size / 1.3,
        clearMemoryCacheWhenDispose: true,
      ),
    );
  }

  Widget likeOverlay() {
    if (widget.onTapLike == null) {
      return Container();
    }

    if (_elevation != _endElevation && !_keepHeartIconVisibile) {
      return Container();
    }

    final IconData iconData = widget.illustration.liked
        ? FontAwesomeIcons.solidHeart
        : UniconsLine.heart;

    final color = widget.illustration.liked
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
        width: widget.size,
        height: widget.size,
        child: Material(
          color: Colors.black.withOpacity(0.3),
          child: Center(
            child: Icon(
              widget.illustration.liked
                  ? UniconsLine.heart
                  : UniconsLine.heart_break,
              size: 42.0,
              color: Theme.of(context).secondaryHeaderColor,
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
        borderRadius: BorderRadius.circular(16.0),
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

  void onDoubleTap() {
    widget.onDoubleTap?.call();
    setState(() => _showLikeAnimation = true);

    Future.delayed(Duration(seconds: 1), () {
      setState(() => _showLikeAnimation = false);
    });
  }

  Widget popupMenuButton() {
    if (widget.popupMenuEntries.isEmpty) {
      return Container();
    }

    final Widget child = Opacity(
      opacity: _showPopupMenu ? 1.0 : 0.0,
      child: PopupMenuButton<EnumIllustrationItemAction>(
        icon: MirrorAnimation<Color?>(
          tween: Theme.of(context)
              .primaryColor
              .tweenTo(Theme.of(context).secondaryHeaderColor),
          duration: Duration(seconds: 2),
          curve: Curves.decelerate,
          builder: (context, child, value) {
            return Icon(
              UniconsLine.ellipsis_h,
              color: value,
            );
          },
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6.0),
        ),
        onSelected: (EnumIllustrationItemAction action) {
          widget.onPopupMenuItemSelected?.call(
            action,
            widget.index,
            widget.illustration,
            widget.illustrationKey,
          );
        },
        itemBuilder: (_) => widget.popupMenuEntries,
      ),
    );

    if (widget.canDrag) {
      return Positioned(
        top: 10.0,
        right: 10.0,
        child: child,
      );
    }

    return Positioned(
      bottom: 10.0,
      right: 10.0,
      child: child,
    );
  }

  /// If all thumbnails' urls are empty,
  /// try retrieve the urls from Firebase Storage
  /// and set them to the Firestore document.
  void checkProperties() async {
    final illustration = widget.illustration;

    if (illustration.version < 1) {
      return;
    }

    final thumbnailUrl = illustration.getThumbnail();
    if (thumbnailUrl.isNotEmpty) {
      return;
    }

    try {
      await IllustrationsActions.checkProperties(
        illustrationId: illustration.id,
      );
    } catch (error) {
      Utilities.logger.e(error);
    }
  }

  void onHoverImage(isHover) {
    if (isHover) {
      setState(() {
        _elevation = _endElevation;
        _showPopupMenu = true;
        _scaleController.forward();
      });

      return;
    }

    setState(() {
      _elevation = _startElevation;
      _showPopupMenu = false;
      _scaleController.reverse();
    });
  }

  void onLongPressImage() {
    widget.onLongPress?.call(
      widget.illustrationKey,
      widget.illustration,
      widget.selected,
    );
  }

  Widget borderOverlay() {
    if (!widget.canResize) {
      return Container();
    }

    if (!_showPopupMenu) {
      return Container();
    }

    return Resizer(
      onTap: () => widget.onGrowUp?.call(widget.index),
      onResizeEnd: (endSize, originalSize, details) {
        widget.onResizeEnd?.call(endSize, originalSize, details, widget.index);
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).primaryColor,
            width: 4.0,
          ),
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),
    );
  }
}
