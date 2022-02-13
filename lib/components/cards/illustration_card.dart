import 'package:artbooking/actions/illustrations.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/enums/enum_illustration_item_action.dart';
import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/types/illustration/illustration.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:supercharged/supercharged.dart';
import 'package:unicons/unicons.dart';

/// A component representing an illustration with its main content (an image).
class IllustrationCard extends StatefulWidget {
  /// A component representing an illustration with its main content (an image).
  const IllustrationCard({
    Key? key,
    required this.heroTag,
    required this.illustration,
    this.illustrationKey = '',
    required this.index,
    this.selected = false,
    this.selectionMode = false,
    this.onLongPress,
    this.size = 300.0,
    this.onPopupMenuItemSelected,
    this.onTap,
    this.popupMenuEntries = const [],
    this.onDoubleTap,
    this.onTapLike,
  }) : super(key: key);

  /// Index position in a list, if available.
  final int index;

  /// If true, the card will be marked with a check circle.
  final bool selected;

  /// If true, this card is in selection mode
  /// alongside all other cards in the list/grid, if any.
  final bool selectionMode;

  /// Illustration's data for this card.
  final Illustration illustration;

  /// Trigger when the user long press this card.
  final Function(String, Illustration, bool)? onLongPress;

  /// Card's size (width = height).
  final double size;

  /// Trigger when the user double taps on this card.
  final void Function()? onDoubleTap;

  /// Trigger when the user taps on this card.
  final void Function()? onTap;

  /// Trigger when heart icon tap.
  final void Function()? onTapLike;

  /// Popup menu item entries.
  final List<PopupMenuEntry<EnumIllustrationItemAction>> popupMenuEntries;

  /// Callback function when popup menu item entries are tapped.
  final void Function(
    EnumIllustrationItemAction,
    int,
    Illustration,
    String,
  )? onPopupMenuItemSelected;

  /// Custom app generated key to perform operations quicker.
  final String illustrationKey;

  /// An unique tag to identify a single component for animation.
  /// This tag must be unique on the page and among a list.
  /// If you're not sure what to put, just use the illustration's id.
  final String heroTag;

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

    setState(() {
      _elevation = _startElevation;
    });

    checkProperties();
  }

  @override
  Widget build(BuildContext context) {
    final illustration = widget.illustration;
    Widget child = imageCard();

    if (illustration.getThumbnail().isEmpty) {
      child = loadingCard();
    }

    return Hero(
      tag: widget.heroTag,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: child,
        ),
      ),
    );
  }

  Widget imageCard() {
    String imageUrl = widget.illustration.getThumbnail();
    Color defaultColor = Colors.transparent;

    return Card(
      color: widget.selected ? Theme.of(context).primaryColor : defaultColor,
      elevation: _elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: Ink.image(
        image: NetworkImage(imageUrl),
        fit: BoxFit.cover,
        child: InkWell(
          onTap: widget.onTap,
          onLongPress: onLongPressImage,
          onHover: onHoverImage,
          onDoubleTap: onDoubleTap,
          child: Stack(
            children: [
              multiSelectIndicator(),
              if (widget.popupMenuEntries.isNotEmpty)
                Positioned(
                  bottom: 10.0,
                  right: 10.0,
                  child: popupMenuButton(),
                ),
              likeOverlay(),
              likeAnimationOverlay(),
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
    return Opacity(
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
}
