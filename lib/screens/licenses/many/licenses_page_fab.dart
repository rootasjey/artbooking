import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class LicensesPageFab extends StatelessWidget {
  const LicensesPageFab({
    Key? key,
    required this.show,
    this.onPressed,
    this.tooltip,
  }) : super(key: key);

  final bool show;
  final void Function()? onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    if (!show) {
      return Container();
    }

    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: tooltip,
      child: Icon(UniconsLine.plus),
      backgroundColor: Theme.of(context).secondaryHeaderColor,
    );
  }
}
