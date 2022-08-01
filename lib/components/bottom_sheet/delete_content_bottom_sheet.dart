import 'package:artbooking/components/buttons/dark_elevated_button.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:beamer/beamer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// A component to show delete confirmation.
/// Suitable for bottom sheet.
class DeleteContentBottomSheet extends StatelessWidget {
  const DeleteContentBottomSheet({
    Key? key,
    required this.subtitleValue,
    required this.titleValue,
    this.confirmButtonValue,
    this.onConfirm,
    this.count = 1,
    this.showDivider = false,
  }) : super(key: key);

  /// Show a divider below the header if true,
  final bool showDivider;

  /// Callback fired when we confirm this action.
  final void Function()? onConfirm;

  /// Number of items to delete.
  final int count;

  /// Subitle text value.
  final String subtitleValue;

  /// Title text value.
  final String titleValue;

  /// String value for button confirmation.
  final String? confirmButtonValue;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              header(
                margin: const EdgeInsets.only(bottom: 24.0),
              ),
              if (showDivider)
                Divider(
                  thickness: 2.0,
                  color: Theme.of(context).secondaryHeaderColor,
                ),
              DarkElevatedButton.large(
                child: Text(
                  confirmButtonValue ?? "delete".tr(),
                  style: Utilities.fonts.body(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                margin: const EdgeInsets.only(top: 12.0, bottom: 16.0),
                onPressed: () {
                  onConfirm?.call();
                  Beamer.of(context).popRoute();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget header({
    EdgeInsets margin = EdgeInsets.zero,
  }) {
    return Padding(
      padding: margin,
      child: Column(
        children: [
          Opacity(
            opacity: 0.8,
            child: Text(
              titleValue,
              style: Utilities.fonts.body(
                color: Colors.black,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Opacity(
              opacity: 0.4,
              child: Text(
                subtitleValue,
                textAlign: TextAlign.center,
                style: Utilities.fonts.body(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
