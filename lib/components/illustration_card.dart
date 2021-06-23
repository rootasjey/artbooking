import 'package:artbooking/actions/illustrations.dart';
import 'package:artbooking/components/user_books.dart';
import 'package:artbooking/state/colors.dart';
import 'package:artbooking/types/one_illus_op_resp.dart';
import 'package:artbooking/types/illustration/illustration.dart';
import 'package:artbooking/utils/constants.dart';
import 'package:artbooking/utils/fonts.dart';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:supercharged/supercharged.dart';
import 'package:unicons/unicons.dart';

/// Determines which actions will be displayed on the card.
enum IllustrationCardType {
  /// When the illustration is viewed inside a book.
  book,

  /// When the illustration is displayed on an illustrations page.
  illustration,
}

/// A component representing an illustration with its main content (an image).
class IllustrationCard extends StatefulWidget {
  final bool selected;
  final bool selectionMode;
  final Illustration illustration;
  final VoidCallback? onBeforeDelete;
  final Function(OneIllusOpResp)? onAfterDelete;
  final Function(bool)? onLongPress;
  final Function(Illustration)? onRemove;
  final double size;
  final IllustrationCardType type;
  final VoidCallback? onTap;

  IllustrationCard({
    required this.illustration,
    this.selected = false,
    this.selectionMode = false,
    this.onAfterDelete,
    this.onBeforeDelete,
    this.onLongPress,
    this.onRemove,
    this.size = 300.0,
    this.type = IllustrationCardType.illustration,
    this.onTap,
  });

  @override
  _IllustrationCardState createState() => _IllustrationCardState();
}

class _IllustrationCardState extends State<IllustrationCard>
    with AnimationMixin {
  late Animation<double> _scaleAnimation;
  late AnimationController _scaleController;

  bool _showPopupMenu = false;

  double _startElevation = 3.0;
  double _endElevation = 6.0;
  double _elevation = 4.0;

  final _keyboardFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    _scaleController = createController()..duration = 250.milliseconds;
    _scaleAnimation =
        0.6.tweenTo(1.0).animatedBy(_scaleController).curve(Curves.elasticOut);

    setState(() {
      _elevation = _startElevation;
    });
  }

  @override
  Widget build(BuildContext context) {
    final illustration = widget.illustration;

    return Hero(
      tag: illustration.id,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Card(
            color: widget.selected ? Colors.blue : ThemeData().cardTheme.color,
            elevation: _elevation,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            clipBehavior: Clip.antiAlias,
            child: Ink.image(
              image: NetworkImage(
                illustration.getThumbnail()!,
              ),
              fit: BoxFit.cover,
              child: InkWell(
                onTap: widget.onTap,
                onLongPress: () {
                  if (widget.onLongPress != null) {
                    widget.onLongPress!(widget.selected);
                  }
                },
                onHover: (isHover) {
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
                },
                child: Stack(
                  children: [
                    multiSelectButton(),
                    if (_showPopupMenu)
                      Positioned(
                        bottom: 10.0,
                        right: 10.0,
                        child: popupMenuButton(),
                      ),
                  ],
                ),
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
    final entries = <PopupMenuEntry<String>>[
      PopupMenuItem(
        child: ListTile(
          leading: Icon(UniconsLine.book_medical),
          title: Opacity(
            opacity: 0.6,
            child: Text(
              'Add to book',
              style: FontsUtils.mainStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        value: 'add_to_book',
      ),
    ];

    if (widget.type == IllustrationCardType.illustration) {
      entries.addAll([
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
      ]);
    }

    if (widget.type == IllustrationCardType.book) {
      entries.addAll([
        PopupMenuItem(
          child: ListTile(
            leading: Icon(UniconsLine.image_minus),
            title: Opacity(
              opacity: 0.6,
              child: Text(
                'Remove',
                style: FontsUtils.mainStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          value: 'remove_from_book',
        ),
      ]);
    }

    return PopupMenuButton(
      icon: MirrorAnimation<Color?>(
        tween: stateColors.primary.tweenTo(stateColors.secondary),
        duration: 2.seconds,
        curve: Curves.decelerate,
        builder: (context, child, value) {
          return Icon(
            UniconsLine.ellipsis_h,
            color: value,
          );
        },
      ),
      onSelected: (dynamic value) {
        switch (value) {
          case 'delete':
            confirmDeletion();
            break;
          case 'add_to_book':
            showAddToBook();
            break;
          case 'remove_from_book':
            removeFromBook();
            break;
          default:
        }
      },
      itemBuilder: (_) => entries,
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
                    "delete".tr(),
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  trailing: Icon(
                    UniconsLine.check,
                    color: Colors.white,
                  ),
                  tileColor: Color(0xfff55c5c),
                  onTap: () {
                    context.router.pop();
                    deleteIllustration();
                  },
                ),
                ListTile(
                  title: Text("cancel".tr()),
                  trailing: Icon(UniconsLine.times),
                  onTap: context.router.pop,
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
              deleteIllustration();
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

  void deleteIllustration() async {
    final illus = widget.illustration;

    if (widget.onBeforeDelete != null) {
      widget.onBeforeDelete!();
    }

    final response = await IllustrationsActions.deleteOne(
      illustrationId: illus.id,
    );

    if (widget.onAfterDelete != null) {
      widget.onAfterDelete!(response);
    }
  }

  void showAddToBook() {
    int flex =
        MediaQuery.of(context).size.width < Constants.maxMobileWidth ? 5 : 3;

    showCustomModalBottomSheet(
      context: context,
      builder: (context) => UserBooks(
        scrollController: ModalScrollController.of(context),
        illustration: widget.illustration,
      ),
      containerWidget: (context, animation, child) {
        return SafeArea(
          child: Row(
            children: [
              Spacer(),
              Expanded(
                flex: flex,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Material(
                    clipBehavior: Clip.antiAlias,
                    borderRadius: BorderRadius.circular(12.0),
                    child: child,
                  ),
                ),
              ),
              Spacer(),
            ],
          ),
        );
      },
    );
  }

  void removeFromBook() {
    if (widget.onRemove != null) {
      widget.onRemove!(widget.illustration);
    }
  }
}
