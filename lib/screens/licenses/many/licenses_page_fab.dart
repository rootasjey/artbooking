import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class LicensesPageFab extends StatelessWidget {
  const LicensesPageFab({
    Key? key,
    required this.show,
    required this.label,
    this.onPressed,
    this.tooltip,
    this.isMobileSize = false,
  }) : super(key: key);

  /// If true, this widget adapt its layout to small screens.
  final bool isMobileSize;

  /// Doisplay the Floating Action Button if true.
  final bool show;

  /// Callback when this FAB is pressed.
  final void Function()? onPressed;

  /// Message to display while hovering FAB.
  final String? tooltip;

  final Widget label;

  @override
  Widget build(BuildContext context) {
    if (!show) {
      return Container();
    }

    if (isMobileSize) {
      return FloatingActionButton(
        onPressed: onPressed,
        tooltip: tooltip,
        child: Icon(UniconsLine.plus),
        backgroundColor: Colors.black,
      );
    }

    return FloatingActionButton.extended(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(UniconsLine.plus),
      label: label,
      backgroundColor: Colors.black,
    );
  }
}
