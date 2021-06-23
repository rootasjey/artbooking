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
  final double size;

  BookCard({
    required this.book,
    this.selected = false,
    this.selectionMode = false,
    this.onAfterDelete,
    this.onBeforeDelete,
    this.onBeforePressed,
    this.onLongPress,
    this.size = 300.0,
  });

  @override
  _BookCardState createState() => _BookCardState();
}

class _BookCardState extends State<BookCard> with AnimationMixin {
  late Animation<double> scaleAnimation;
  late Animation<Offset> offsetAnimation;
  late Animation<double> opacity;

  late AnimationController captionController;
  late AnimationController scaleController;
  late AnimationController offsetController;

  bool showCaption = false;

  double initElevation = 4.0;
  double size = 300.0;

  double elevation = 4.0;
  double scale = 1.0;

  final keyboardFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    captionController = createController();
    captionController.duration = 300.milliseconds;
    opacity = 0.0.tweenTo(1.0).animatedBy(captionController);

    offsetController = createController()..duration = 250.milliseconds;

    offsetAnimation =
        Offset(0, 0.25).tweenTo(Offset.zero).animatedBy(offsetController);

    scaleController = createController()..duration = 500.milliseconds;

    scaleAnimation = 0.8
        .tweenTo(1.0)
        .animatedBy(scaleController)
        .curve(Curves.fastOutSlowIn);

    setState(() {
      size = widget.size;
      elevation = initElevation;
    });
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;
    ImageProvider imageProvider;

    if (book.cover!.custom!.url!.isNotEmpty) {
      imageProvider = NetworkImage(book.cover!.custom!.url!);
    } else if (book.cover!.auto!.url!.isNotEmpty) {
      imageProvider = NetworkImage(book.cover!.auto!.url!);
    } else {
      imageProvider = AssetImage('assets/images/gummy-canvas.png');
    }

    return SizedBox(
      width: size,
      height: size,
      child: Card(
        color: widget.selected ? Colors.blue : ThemeData().cardTheme.color,
        elevation: elevation,
        child: ScaleTransition(
          scale: scaleAnimation,
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
                  elevation = 8.0;
                  showCaption = true;

                  captionController.forward();
                  offsetController.forward();
                  scaleController.forward();
                } else {
                  elevation = initElevation;
                  showCaption = false;

                  captionController.reverse();
                  offsetController.reverse();
                  scaleController.reverse();
                }

                setState(() {});
              },
              child: Stack(
                children: [
                  caption(),
                  multiSelectButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget caption() {
    final illustration = widget.book;

    return Align(
      alignment: Alignment.bottomCenter,
      child: SlideTransition(
        position: offsetAnimation,
        child: Opacity(
          opacity: opacity.value,
          child: Container(
            color: Colors.black26,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      illustration.name!,
                      style: FontsUtils.mainStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  popupMenuButton(),
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
      child: Icon(
        Icons.more_vert,
        color: Colors.white,
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
          focusNode: keyboardFocusNode,
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
