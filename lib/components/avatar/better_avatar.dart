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
    this.padding = EdgeInsets.zero,
    this.dragGroupName = "",
    this.showTitleOnHover = false,
  });

  final bool useAsPlaceholder;
  final bool showTitleOnHover;

  /// Not used if onTap is null.
  final ColorFilter? colorFilter;
  final double size;
  final double elevation;
  final VoidCallback? onTap;
  final ImageProvider<Object> image;
  final EdgeInsets padding;

  final int index;
  final bool canDrag;

  /// Popup menu item entries.
  final List<PopupMenuEntry<EnumArtistItemAction>> popupMenuEntries;

  /// Callback function when popup menu item entries are tapped.
  final void Function(
    EnumArtistItemAction itemAction,
    int index,
    String artistId,
  )? onPopupMenuItemSelected;

  /// Callback when drag and dropping items on this illustration card.
  final void Function(int dropTargetIndex, List<int> dragIndexes)? onDrop;

  final String id;
  final String title;
  final String dragGroupName;

  @override
  _BetterAvatarState createState() => _BetterAvatarState();
}

class _BetterAvatarState extends State<BetterAvatar>
    with TickerProviderStateMixin {
  late Animation<double> scaleAnimation;
  late AnimationController scaleAnimationController;

  bool _isHover = false;

  late double elevation;

  @override
  void initState() {
    super.initState();

    scaleAnimationController = AnimationController(
      lowerBound: 0.8,
      upperBound: 1.0,
      duration: 250.milliseconds,
      vsync: this,
    );

    scaleAnimation = CurvedAnimation(
      parent: scaleAnimationController,
      curve: Curves.elasticOut,
    );

    setState(() {
      elevation = widget.elevation;
    });
  }

  @override
  dispose() {
    scaleAnimationController.dispose();
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
      padding: widget.padding,
      child: Column(
        children: [
          imageContainerWidget(
            usingAsDroptarget: usingAsDroptarget,
          ),
          avatarTitle(),
          if (widget.popupMenuEntries.isNotEmpty) popupMenuButton()
        ],
      ),
    );
  }

  Widget imageContainerWidget({bool usingAsDroptarget = false}) {
    Widget avatarImage = ScaleTransition(
      scale: scaleAnimation,
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

    return Material(
      elevation: elevation,
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
                    elevation = (widget.elevation + 1.0) * 2;
                    scaleAnimationController.forward();
                    setState(() => _isHover = true);
                    return;
                  }

                  elevation = widget.elevation;
                  scaleAnimationController.reverse();
                  setState(() => _isHover = false);
                },
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
      padding: widget.padding,
      child: Material(
        elevation: elevation,
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
      icon: Icon(
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

  Widget avatarTitle() {
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
