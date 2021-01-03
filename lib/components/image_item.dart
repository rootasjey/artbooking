import 'package:artbooking/actions/images.dart';
import 'package:artbooking/state/colors.dart';
import 'package:artbooking/types/create_image_doc_resp.dart';
import 'package:artbooking/types/illustration/illustration.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:supercharged/supercharged.dart';

class ImageItem extends StatefulWidget {
  final bool selected;
  final bool selectionMode;
  final Illustration illustration;
  final VoidCallback onBeforeDelete;
  final Function(CreateImageDocResp) onAfterDelete;
  final Function(bool) onLongPress;
  final Function onBeforePressed;

  ImageItem({
    @required this.illustration,
    this.selected = false,
    this.selectionMode = false,
    this.onAfterDelete,
    this.onBeforeDelete,
    this.onBeforePressed,
    this.onLongPress,
  });

  @override
  _ImageItemState createState() => _ImageItemState();
}

class _ImageItemState extends State<ImageItem> with TickerProviderStateMixin {
  Animation<double> scaleAnimation;
  AnimationController scaleAnimationController;

  Animation<Offset> offsetAnimation;
  AnimationController offsetAnimationController;

  bool showCaption = false;

  double initElevation = 4.0;
  double size = 300.0;

  double elevation = 4.0;
  double scale = 1.0;

  final keyboardFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    scaleAnimationController = AnimationController(
      lowerBound: 0.8,
      upperBound: 1.0,
      duration: 500.milliseconds,
      vsync: this,
    );

    scaleAnimation = CurvedAnimation(
      parent: scaleAnimationController,
      curve: Curves.fastOutSlowIn,
    );

    offsetAnimationController = AnimationController(
      duration: 500.milliseconds,
      vsync: this,
    );

    offsetAnimation = Tween<Offset>(
      begin: Offset(0, 20.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: offsetAnimationController,
        curve: Curves.ease,
      ),
    );

    setState(() {
      size = size;
      elevation = initElevation;
    });
  }

  @override
  dispose() {
    scaleAnimationController.dispose();
    offsetAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final illustration = widget.illustration;

    return SizedBox(
      width: size,
      height: size,
      child: Card(
        color: widget.selected ? Colors.blue : ThemeData().cardTheme.color,
        elevation: elevation,
        child: ScaleTransition(
          scale: scaleAnimation,
          child: Ink.image(
            image: NetworkImage(
              illustration.getThumbnail(),
            ),
            fit: BoxFit.cover,
            child: InkWell(
              onTap: () {
                bool handled = false;
                if (widget.onBeforePressed != null) {
                  handled = widget.onBeforePressed();
                }

                if (handled) {
                  return;
                }
              },
              // onLongPress: widget.onLongPress,
              onLongPress: () {
                if (widget.onLongPress != null) {
                  widget.onLongPress(widget.selected);
                }
              },
              onHover: (isHover) {
                if (isHover) {
                  elevation = 8.0;
                  showCaption = true;
                  scaleAnimationController.forward();
                  offsetAnimationController.forward();
                } else {
                  elevation = initElevation;
                  showCaption = false;
                  scaleAnimationController.reverse();
                  offsetAnimationController.reverse();
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
    final illustration = widget.illustration;

    return Align(
      alignment: Alignment.bottomCenter,
      child: SlideTransition(
        position: offsetAnimation,
        child: Container(
          color: Colors.black26,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    illustration.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                PopupMenuButton(
                  child: Icon(
                    Icons.more_vert,
                    color: Colors.white,
                  ),
                  onSelected: (value) {
                    switch (value) {
                      case "delete":
                        confirmDeletion();
                        break;
                      default:
                    }
                  },
                  itemBuilder: (_) => <PopupMenuEntry<String>>[
                    PopupMenuItem(
                      child: ListTile(
                        leading: Icon(Icons.delete_outline),
                        title: Text('Delete'),
                      ),
                      value: "delete",
                    ),
                  ],
                ),
              ],
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

  void confirmDeletion() async {
    showCustomModalBottomSheet(
      context: context,
      builder: (context, controller) {
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
                    deleteImageItem();
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
              deleteImageItem();
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

  void deleteImageItem() async {
    final illu = widget.illustration;

    if (widget.onBeforeDelete != null) {
      widget.onBeforeDelete();
    }

    final response = await deleteImageDocument(imageId: illu.id);

    if (widget.onAfterDelete != null) {
      widget.onAfterDelete(response);
    }
  }
}
