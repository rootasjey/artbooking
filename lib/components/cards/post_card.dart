import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/enums/enum_post_item_action.dart';
import 'package:artbooking/types/post.dart';
import 'package:flutter/material.dart';

class PostCard extends StatefulWidget {
  const PostCard({
    Key? key,
    required this.post,
    required this.index,
    this.onTap,
    this.onDelete,
    this.onEdit,
    this.heroTag = "",
    this.popupMenuEntries = const [],
    this.onPopupMenuItemSelected,
  }) : super(key: key);

  final int index;
  final void Function(Post post, String heroTag)? onTap;

  /// onDelete callback function (after selecting 'delete' item menu)
  final Function(Post, int)? onDelete;

  /// onEdit callback function (after selecting 'edit' item menu)
  final Function(Post, int)? onEdit;

  final Post post;
  final String heroTag;

  /// Popup menu item entries.
  final List<PopupMenuEntry<EnumPostItemAction>> popupMenuEntries;

  /// Callback function when popup menu item entries are tapped.
  final void Function(
    EnumPostItemAction action,
    int index,
    Post post,
  )? onPopupMenuItemSelected;

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  Color _borderColor = Colors.pink;
  Color _textBgColor = Colors.transparent;
  double _elevation = 2.0;
  double _borderWidth = 2.0;

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    if (_borderColor == Colors.pink) {
      _borderColor = Theme.of(context).primaryColor.withOpacity(0.6);
    }

    return SizedBox(
      width: 260.0,
      height: 300.0,
      child: Card(
        elevation: _elevation,
        color: Theme.of(context).backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6.0),
          side: BorderSide(
            color: _borderColor,
            width: _borderWidth,
          ),
        ),
        child: InkWell(
          onTap: () => widget.onTap?.call(post, widget.heroTag),
          onHover: (isHover) {
            setState(() {
              _elevation = isHover ? 4.0 : 2.0;
              _borderColor = isHover
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).primaryColor.withOpacity(0.6);
              _borderWidth = isHover ? 3.0 : 2.0;
              _textBgColor = isHover ? Colors.amber : Colors.transparent;
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Opacity(
                    opacity: 0.6,
                    child: Icon(
                      Utilities.ui.getPostIcon(post.id),
                      size: 32.0,
                    ),
                  ),
                ),
                Hero(
                  tag: post.id,
                  child: Opacity(
                    opacity: 0.8,
                    child: Text(
                      post.name,
                      maxLines: 2,
                      style: Utilities.fonts.body(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w800,
                        backgroundColor: _textBgColor,
                      ),
                    ),
                  ),
                ),
                Opacity(
                  opacity: 0.4,
                  child: Text(
                    post.description,
                    maxLines: 5,
                    textAlign: TextAlign.center,
                    style: Utilities.fonts.body(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
