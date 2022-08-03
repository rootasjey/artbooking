import 'package:artbooking/components/popup_menu/popup_menu_item_icon.dart';
import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/book/book.dart';
import 'package:artbooking/types/book/popup_entry_book.dart';
import 'package:artbooking/types/enums/enum_book_item_action.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jiffy/jiffy.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:supercharged/supercharged.dart';
import 'package:unicons/unicons.dart';

class BookWideCover extends StatefulWidget {
  const BookWideCover({
    Key? key,
    required this.book,
    required this.index,
    required this.bookHeroTag,
    this.authenticated = false,
    this.liked = false,
    this.useBottomSheet = false,
    this.onDoubleTap,
    this.onLike,
    this.onPopupMenuItemSelected,
    this.onShowDatesDialog,
    this.popupMenuEntries = const [],
  }) : super(key: key);

  /// Main widget data. A book containing illustrations.
  final Book book;

  /// True if the current user is authenticated.
  final bool authenticated;

  /// If true, a bottom sheet will be displayed on long press event.
  /// Setting this property to true will deactivate popup menu and
  /// hide like button.
  final bool useBottomSheet;

  /// Callback fired when one of the popup menu item entries is selected.
  final void Function(EnumBookItemAction, int, Book)? onPopupMenuItemSelected;

  /// Index position in a list, if available.
  final int index;

  /// Menu item list displayed after tapping on the corresponding popup button.
  final List<PopupEntryBook> popupMenuEntries;

  /// Hero tag to make a smooth page transition.
  final String bookHeroTag;

  /// Callback fired when we want to show book's creation & last updated dates.
  final void Function()? onShowDatesDialog;

  /// Callback fired when the book is liked.
  final void Function()? onLike;

  final void Function()? onDoubleTap;

  /// True if the book is liked by the current authenticated user.
  final bool liked;

  @override
  State<BookWideCover> createState() => _BookWideCoverState();
}

class _BookWideCoverState extends State<BookWideCover> with AnimationMixin {
  late Animation<double> _scaleAnimation;
  late AnimationController _scaleController;

  /// Show popup menu button if true.
  bool _showPopupMenu = false;

  /// If true, the cover is at its maximum height.
  /// Otherwise, it is at its minimum height.
  bool _coverExpanded = false;

  /// Start a heart animation when true.
  bool _showLikeAnimation = false;

  /// Minimized cover's height.
  double _startCoverHeight = 200.0;

  /// Expanded cover height.
  double _endCoverHeight = 300.0;

  /// Current cover's height.
  double _coverHeight = 200.0;

  @override
  void initState() {
    super.initState();

    _scaleController = createController()..duration = 250.milliseconds;
    _scaleAnimation =
        0.6.tweenTo(1.0).animatedBy(_scaleController).curve(Curves.elasticOut);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Stack(
          children: [
            Hero(
              tag: widget.bookHeroTag,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 250),
                height: _coverHeight,
                child: Card(
                  margin: EdgeInsets.zero,
                  elevation: 2.0,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(),
                  child: Ink.image(
                    image: NetworkImage(widget.book.getCoverLink()),
                    height: 260.0,
                    fit: BoxFit.cover,
                    child: InkWell(
                      onDoubleTap:
                          widget.onDoubleTap != null ? onDoubleTap : null,
                      onHover: (bool isHover) {
                        setState(() => _showPopupMenu = isHover);
                      },
                      onTap: () {
                        setState(() {
                          _coverHeight = _coverExpanded
                              ? _startCoverHeight
                              : _endCoverHeight;
                          _coverExpanded = !_coverExpanded;
                        });
                      },
                      onLongPress: widget.useBottomSheet ? onLongPress : null,
                      child: Stack(
                        children: [
                          popupMenuButton(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0.0,
              left: 0.0,
              child: likeButton(context),
            ),
            Positioned(
              bottom: 0.0,
              child: textWidget(context),
            ),
            likeAnimationOverlay(),
          ],
        ),
        bookMetadataWidget(),
      ],
    );
  }

  Widget bookMetadataWidget() {
    String updatedAtStr = "";

    if (DateTime.now().difference(widget.book.updatedAt).inDays > 60) {
      updatedAtStr = "date_updated_on".tr(
        args: [
          Jiffy(widget.book.updatedAt).yMMMMEEEEd,
        ],
      );
    } else {
      updatedAtStr = "date_updated_ago".tr(
        args: [Jiffy(widget.book.updatedAt).fromNow()],
      );
    }

    final Color color = widget.book.illustrations.isEmpty
        ? Theme.of(context).secondaryHeaderColor
        : Theme.of(context).primaryColor;

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          InkWell(
            onTap: widget.onShowDatesDialog,
            child: Opacity(
              opacity: 0.6,
              child: Text(
                updatedAtStr.toLowerCase(),
                style: Utilities.fonts.body(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Opacity(
            opacity: 0.3,
            child: Text(
              " • ",
              style: Utilities.fonts.body(
                color: Theme.of(context).secondaryHeaderColor,
                fontSize: 16.0,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Opacity(
            opacity: 0.8,
            child: Text(
              "illustrations_count".plural(widget.book.illustrations.length),
              style: Utilities.fonts.body(
                color: color,
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget likeAnimationOverlay() {
    if (!_showLikeAnimation) {
      return Container();
    }

    return Positioned(
      height: _coverHeight,
      left: 0.0,
      right: 0.0,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Material(
          color: Colors.black.withOpacity(0.3),
          child: Center(
            child: Icon(
              widget.liked ? UniconsLine.heart : UniconsLine.heart_break,
              size: 42.0,
              color: Theme.of(context).secondaryHeaderColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget likeButton(BuildContext context) {
    if (!widget.authenticated) {
      return Container();
    }

    if (widget.liked) {
      return IconButton(
        tooltip: "unlike".tr(),
        icon: CircleAvatar(
          radius: 15.0,
          backgroundColor: Constants.colors.clairPink,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Icon(
              FontAwesomeIcons.solidHeart,
              size: 14,
              color: Theme.of(context).secondaryHeaderColor,
            ),
          ),
        ),
        color: Theme.of(context).secondaryHeaderColor,
        onPressed: widget.onLike,
      );
    }

    return IconButton(
      tooltip: "like".tr(),
      icon: CircleAvatar(
        radius: 15.0,
        backgroundColor: Constants.colors.clairPink,
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Icon(
            UniconsLine.heart,
            size: 16,
            color: Colors.black,
          ),
        ),
      ),
      onPressed: widget.onLike,
    );
  }

  Widget textWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 0.0, bottom: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.book.name.isNotEmpty)
                  Opacity(
                    opacity: 0.8,
                    child: Text(
                      " ${widget.book.name} ",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Utilities.fonts.body(
                        backgroundColor: Colors.black87,
                        color: Colors.white,
                        fontSize: 24.0,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                if (widget.book.description.isNotEmpty)
                  Opacity(
                    opacity: 0.6,
                    child: Text(
                      " ${widget.book.description} ",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Utilities.fonts.body(
                        backgroundColor: Colors.black87,
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
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
  }
}
