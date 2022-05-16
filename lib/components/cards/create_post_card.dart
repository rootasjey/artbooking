import 'package:artbooking/globals/utilities.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class CreatePostCard extends StatefulWidget {
  const CreatePostCard({
    Key? key,
    this.onTap,
    this.borderColor = Colors.transparent,
  }) : super(key: key);

  final Color borderColor;
  final void Function()? onTap;

  @override
  State<CreatePostCard> createState() => _CreatePostCardState();
}

class _CreatePostCardState extends State<CreatePostCard> {
  Color _borderColor = Colors.pink;
  double _elevation = 2.0;
  double _borderWidth = 2.0;

  @override
  void initState() {
    super.initState();
    _borderColor = widget.borderColor;
  }

  @override
  Widget build(BuildContext context) {
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
          onTap: () => widget.onTap?.call(),
          onHover: (isHover) {
            setState(() {
              _elevation = isHover ? 4.0 : 2.0;
              _borderColor = isHover
                  ? widget.borderColor
                  : widget.borderColor.withOpacity(0.6);
              _borderWidth = isHover ? 3.0 : 2.0;
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
                      UniconsLine.plus,
                      size: 32.0,
                    ),
                  ),
                ),
                Opacity(
                  opacity: 0.6,
                  child: Text(
                    "Create new post",
                    style: Utilities.fonts.body3(
                      fontSize: 24.0,
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
