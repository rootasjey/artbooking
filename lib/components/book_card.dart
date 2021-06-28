import 'package:artbooking/actions/books.dart';
import 'package:artbooking/router/app_router.dart';
import 'package:artbooking/state/colors.dart';
import 'package:artbooking/types/book.dart';
import 'package:artbooking/types/one_book_op_resp.dart';
import 'package:artbooking/utils/fonts.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:supercharged/supercharged.dart';
import 'package:unicons/unicons.dart';

class BookCard extends StatefulWidget {
  final bool selected;
  final bool selectionMode;
  final Book book;
  final VoidCallback? onBeforeDelete;
  final Function(OneBookOpResp)? onAfterDelete;
  final Function(bool)? onLongPress;
  final Function? onBeforePressed;

  BookCard({
    required this.book,
    this.selected = false,
    this.selectionMode = false,
    this.onAfterDelete,
    this.onBeforeDelete,
    this.onBeforePressed,
    this.onLongPress,
  });

  @override
  _BookCardState createState() => _BookCardState();
}

class _BookCardState extends State<BookCard> with AnimationMixin {
  late Animation<double> _scaleAnimation;

  late AnimationController _scaleController;

  double _initElevation = 4.0;

  double _elevation = 4.0;

  final _keyboardFocusNode = FocusNode();

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
    return SizedBox(
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
    );
  }

  Widget backCard() {
    return Positioned(
      top: 0.0,
      right: 0.0,
      width: 200.0,
      child: Container(
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
        top: 8.0,
        left: 16.0,
        right: 16.0,
      ),
      child: Row(
        children: [
          Expanded(
            child: Opacity(
              opacity: 0.8,
              child: Text(
                illustration.name!,
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

    if (book.cover!.custom!.url!.isNotEmpty) {
      imageProvider = NetworkImage(book.cover!.custom!.url!);
    } else if (book.cover!.auto!.url!.isNotEmpty) {
      imageProvider = NetworkImage(book.cover!.auto!.url!);
    } else {
      imageProvider = AssetImage('assets/images/gummy-canvas.png');
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
              onTap: onTap,
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
      onSelected: (dynamic value) {
        switch (value) {
          case 'delete':
            confirmDeletion();
            break;

          default:
        }
      },
      itemBuilder: (_) => <PopupMenuEntry<String>>[
        PopupMenuItem(
          child: ListTile(
            leading: Icon(UniconsLine.trash),
            title: Opacity(
              opacity: 0.6,
              child: Text(
                'Delete',
                style: FontsUtils.mainStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          value: 'delete',
        ),
      ],
    );
  }

  void confirmDeletion() async {
    showCustomModalBottomSheet(
      context: context,
      builder: (context) {
        return Material(
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text(
                    'Confirm',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  trailing: Icon(
                    Icons.check,
                    color: Colors.white,
                  ),
                  tileColor: Color(0xfff55c5c),
                  onTap: () {
                    Navigator.of(context).pop();
                    deleteBook();
                  },
                ),
                ListTile(
                  title: Text('Cancel'),
                  trailing: Icon(Icons.close),
                  onTap: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        );
      },
      containerWidget: (context, animation, child) {
        return RawKeyboardListener(
          autofocus: true,
          focusNode: _keyboardFocusNode,
          onKey: (keyEvent) {
            if (keyEvent.isKeyPressed(LogicalKeyboardKey.enter)) {
              Navigator.of(context).pop();
              deleteBook();
            }
          },
          child: SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 500.0,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 40.0,
                  ),
                  child: Material(
                    clipBehavior: Clip.antiAlias,
                    borderRadius: BorderRadius.circular(12.0),
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void deleteBook() async {
    final book = widget.book;

    if (widget.onBeforeDelete != null) {
      widget.onBeforeDelete!();
    }

    final response = await BooksActions.deleteOne(
      bookId: book.id,
    );

    if (widget.onAfterDelete != null) {
      widget.onAfterDelete!(response);
    }
  }

  void onTap() {
    bool? handled = false;
    if (widget.onBeforePressed != null) {
      handled = widget.onBeforePressed!();
    }

    if (handled!) {
      return;
    }

    context.router.push(
      DashBookPage(
        bookId: widget.book.id,
        book: widget.book,
      ),
    );
  }
}
