import 'package:artbooking/globals/utilities.dart';
import 'package:flutter/material.dart';

class ElevatedListTile extends StatefulWidget {
  const ElevatedListTile({
    Key? key,
    required this.titleValue,
    this.leading,
    this.onTap,
  }) : super(key: key);

  final String titleValue;
  final Widget? leading;
  final void Function()? onTap;

  @override
  _ElevatedListTileState createState() => _ElevatedListTileState();
}

class _ElevatedListTileState extends State<ElevatedListTile> {
  double _elevation = 0.0;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: _elevation,
      child: InkWell(
        onHover: (isHover) {
          setState(() {
            _elevation = isHover ? 2.0 : 0.0;
          });
        },
        onTap: () {},
        child: ListTile(
          onTap: widget.onTap,
          trailing: widget.leading,
          tileColor: Theme.of(context).backgroundColor,
          title: Text(
            widget.titleValue,
            style: Utilities.fonts.body(
              fontWeight: FontWeight.w600,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 28.0,
            vertical: 12.0,
          ),
        ),
      ),
    );
  }
}
