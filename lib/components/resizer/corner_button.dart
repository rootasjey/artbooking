import 'package:artbooking/components/resizer/frame.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class CornerButton extends StatelessWidget {
  CornerButton({
    required this.pressed,
    required this.dragDetails,
    required this.onDoubleTap,
    this.onTap,
    this.onResizeEnd,
    this.onResizeCancel,
  });

  final ValueNotifier<bool> pressed;
  final ValueNotifier<Offset?> dragDetails;
  final Function onDoubleTap;
  final Function()? onTap;

  final void Function(DragEndDetails)? onResizeEnd;

  final void Function()? onResizeCancel;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(-kCornerButtonSize / 2, -kCornerButtonSize / 2),
      child: GestureDetector(
        onTap: onTap,
        onDoubleTap: () => onDoubleTap(),
        onHorizontalDragStart: (details) => pressed.value = true,
        onVerticalDragStart: (details) => pressed.value = true,
        onHorizontalDragDown: (details) => pressed.value = true,
        onVerticalDragDown: (details) => pressed.value = true,
        onHorizontalDragCancel: () {
          pressed.value = false;
          onResizeCancel?.call();
        },
        onVerticalDragCancel: () {
          pressed.value = false;
          onResizeCancel?.call();
        },
        onHorizontalDragEnd: (details) {
          pressed.value = false;
          onResizeEnd?.call(details);
        },
        onVerticalDragEnd: (details) {
          pressed.value = false;
          onResizeEnd?.call(details);
        },
        onVerticalDragUpdate: (d) => dragDetails.value = d.globalPosition,
        onHorizontalDragUpdate: (d) => dragDetails.value = d.globalPosition,
        child: Container(
          width: kCornerButtonSize,
          height: kCornerButtonSize,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(kCornerButtonSize),
            color: Theme.of(context)
                .colorScheme
                .onPrimary
                .withOpacity(pressed.value ? .5 : .3),
          ),
          child: Center(
            child: CircleAvatar(
              radius: kCornerButtonSize / 3,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 28.0, right: 28.0),
                child: Icon(UniconsLine.plus, size: 18.0),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
