import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class LicensesPageFab extends StatelessWidget {
  const LicensesPageFab({
    Key? key,
    required this.show,
    this.onPressed,
    this.tooltip,
  }) : super(key: key);

  /// Doisplay the Floating Action Button if true.
  final bool show;

  /// Callback when this FAB is pressed.
  final void Function()? onPressed;

  /// Message to display while hovering FAB.
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    if (!show) {
      return Container();
    }

    return FloatingActionButton.extended(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(UniconsLine.plus),
      label: Text("license_create".tr()),
      backgroundColor: Theme.of(context).secondaryHeaderColor,
    );
  }
}
