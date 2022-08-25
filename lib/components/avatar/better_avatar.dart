import 'package:artbooking/components/popup_menu/popup_menu_icon.dart';
import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/drag_data.dart';
import 'package:artbooking/types/enums/enum_artist_item_action.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:supercharged/supercharged.dart';
import 'package:unicons/unicons.dart';

class BetterAvatar extends StatefulWidget {
  BetterAvatar({
    required this.image,
    this.elevation = 4.0,
    this.onTap,
    this.size = 220.0,
    this.colorFilter,
    this.useAsPlaceholder = false,
    this.index = -1,
    this.canDrag = false,
    this.popupMenuEntries = const [],
    this.onDrop,
    this.onPopupMenuItemSelected,
    this.id = "",
    this.title = "",
    this.margin = EdgeInsets.zero,
    this.dragGroupName = "",
    this.showTitleOnHover = false,
  });

  /// This widget is draggable if this is true.
  final bool canDrag;

  /// By default hide the title and only display it on cursor hover if true.
  final bool showTitleOnHover;

  /// Will display an empty circle with a dotted border if true.
  final bool useAsPlaceholder;

  /// Not used if onTap is null.
  final ColorFilter? colorFilter;

  /// Avatar's size.
  final double size;

  /// Avatar's elevation.
  final double elevation;

  /// Spacing around this widget.
  final EdgeInsets margin;

  /// Callback when drag and dropping items on this illustration card.
  final void Function(int dropTargetIndex, List<int> dragIndexes)? onDrop;

  /// Callback function when popup menu item entries are tapped.
  final void Function(
    EnumArtistItemAction itemAction,
    int index,
    String artistId,
  )? onPopupMenuItemSelected;

  /// Callback fired when this widget is tapped.
  final void Function()? onTap;

  /// Image for this avatar.
  final ImageProvider<Object> image;

  /// Index of this widget if it's in a list.
  final int index;

  /// Popup menu item entries.
  final List<PopupMenuEntry<EnumArtistItemAction>> popupMenuEntries;

  /// Useful to filter wich widget can be dropped on a certain drag target.
  final String dragGroupName;

  /// This widget unique identifier.
  final String id;

  /// Text title to show belon the image.
  final String title;

  @override
  _BetterAvatarState createState() => _BetterAvatarState();
}

class _BetterAvatarState extends State<BetterAvatar>
    with TickerProviderStateMixin {
  late Animation<double> _scaleAnimation;
  late AnimationController _scaleAnimationController;
  late AnimationController _rotateAnimationController;

  bool _isHover = false;

  late double _elevation;

  @override
  void initState() {
    super.initState();

    _scaleAnimationController = AnimationController(
      lowerBound: 0.8,
      upperBound: 1.0,
      duration: 250.milliseconds,
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _scaleAnimationController,
      curve: Curves.elasticOut,
    );

    _rotateAnimationController = AnimationController(
      vsync: this,
      duration: 1000.milliseconds,
    );

    setState(() {
      _elevation = widget.elevation;
    });
  }

  @override
  dispose() {
    _scaleAnimationController.dispose();
    _rotateAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.useAsPlaceholder) {
      return placeholder();
    }

    if (!widget.canDrag) {
      return avatarWidget();
    }

    return DragTarget<DragData>(
      builder: (context, candidateItems, rejectedItems) {
        return avatarWidget(
          usingAsDroptarget: candidateItems.isNotEmpty,
        );
      },
      onAccept: (DragData dragData) {
        widget.onDrop?.call(widget.index, [dragData.index]);
      },
      onWillAccept: (DragData? dragData) {
        if (dragData == null) {
          return false;
        }

        if (dragData.type != BetterAvatar) {
          return false;
        }

        if (dragData.groupName != widget.dragGroupName) {
          return false;
        }

        return true;
      },
    );
  }

  Widget avatarWidget({bool usingAsDroptarget = false}) {
    return Padding(
      padding: widget.margin,
      child: Column(
        children: [
          imageContainerWidget(
            usingAsDroptarget: usingAsDroptarget,
          ),
          titleWidget(),
          if (widget.popupMenuEntries.isNotEmpty) popupMenuButton()
        ],
      ),
    );
  }

  Widget imageContainerWidget({bool usingAsDroptarget = false}) {
    Widget avatarImage = ScaleTransition(
      scale: _scaleAnimation,
      child: imageWidget(
        usingAsDroptarget: usingAsDroptarget,
      ),
    );

    if (widget.canDrag) {
      avatarImage = LongPressDraggable<DragData>(
        data: DragData(
          groupName: widget.dragGroupName,
          index: widget.index,
          type: BetterAvatar,
        ),
        child: avatarImage,
        childWhenDragging: childWhenDragging(),
        feedback: imageWidget(
          dragging: true,
        ),
      );
    }

    return avatarImage;
  }

  Widget imageWidget({
    bool usingAsDroptarget = false,
    bool dragging = false,
  }) {
    final double size = dragging ? widget.size / 2 : widget.size;

    final Color borderColor = usingAsDroptarget
        ? Constants.colors.tertiary
        : Theme.of(context).primaryColor;

    return RotationTransition(
      turns: Tween(begin: 0.0, end: -0.1)
          .curved(Curves.elasticOut)
          .animate(_rotateAnimationController),
      child: Material(
        elevation: _elevation,
        color: Theme.of(context).backgroundColor,
        clipBehavior: Clip.antiAlias,
        shape: CircleBorder(
          side: BorderSide(
            color: borderColor,
            width: 3.0,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Material(
            clipBehavior: Clip.antiAlias,
            shape: CircleBorder(),
            child: SizedBox(
              width: size,
              height: size,
              child: Ink.image(
                image: widget.image,
                width: size,
                height: size,
                fit: BoxFit.cover,
                colorFilter: widget.colorFilter,
                child: InkWell(
                  onTap: widget.onTap,
                  onHover: (isHover) {
                    if (isHover) {
                      _elevation = (widget.elevation + 1.0) * 2;
                      _scaleAnimationController.forward();
                      _rotateAnimationController.forward();
                      setState(() => _isHover = true);
                      return;
                    }

                    _elevation = widget.elevation;
                    _scaleAnimationController.reverse();
                    _rotateAnimationController.reverse();
                    setState(() => _isHover = false);
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget childWhenDragging() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Material(
        color: Theme.of(context).backgroundColor,
        clipBehavior: Clip.antiAlias,
        shape: CircleBorder(
          side: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 3.0,
          ),
        ),
        child: Container(
          width: widget.size,
          height: widget.size,
          padding: const EdgeInsets.all(8.0),
          child: DottedBorder(
            strokeWidth: 3.0,
            borderType: BorderType.Circle,
            radius: Radius.circular(16),
            color: Theme.of(context).primaryColor.withOpacity(0.6),
            dashPattern: [8, 4],
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
          ),
        ),
      ),
    );
  }

  Widget placeholder() {
    final size = widget.size;

    return Padding(
      padding: widget.margin,
      child: Material(
        elevation: _elevation,
        color: Constants.colors.clairPink,
        clipBehavior: Clip.antiAlias,
        shape: CircleBorder(
          side: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 3.0,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Material(
            clipBehavior: Clip.antiAlias,
            color: Constants.colors.clairPink,
            shape: CircleBorder(),
            child: Tooltip(
              message: "artist_add_new".tr(),
              child: InkWell(
                onTap: widget.onTap,
                child: SizedBox(
                  width: size,
                  height: size,
                  child: Icon(UniconsLine.plus),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget popupMenuButton() {
    return PopupMenuButton<EnumArtistItemAction>(
      icon: PopupMenuIcon(
        UniconsLine.ellipsis_h,
        color: Theme.of(context).secondaryHeaderColor,
      ),
      onSelected: (EnumArtistItemAction action) {
        widget.onPopupMenuItemSelected?.call(
          action,
          widget.index,
          widget.id,
        );
      },
      itemBuilder: (_) => widget.popupMenuEntries,
    );
  }

  Widget titleWidget() {
    if (widget.title.isEmpty) {
      return Container();
    }

    if (widget.showTitleOnHover && !_isHover) {
      return Container();
    }

    return Text(
      widget.title,
      style: Utilities.fonts.body(
        fontSize: 16.0,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
