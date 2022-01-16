import 'package:flutter/material.dart';

class PopupMenuListTile extends StatelessWidget {
  final Widget? leading;
  final Widget? trailing;
  final Widget title;

  const PopupMenuListTile({
    Key? key,
    this.leading,
    this.trailing,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 32.0),
          child: Row(
            children: [
              if (leading != null) leading!,
              Padding(
                padding: const EdgeInsets.only(left: 24.0),
                child: title,
              ),
            ],
          ),
        ),
        if (trailing != null)
          Positioned(
            right: 8.0,
            child: trailing!,
          )
      ],
    );
  }
}
