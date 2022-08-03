import 'package:artbooking/components/animations/fade_in_y.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

/// A widget containing two Floating Action Button.
/// A main extended FAB on the left, and a basic FAB on the right to scroll
/// to the top of the page.
class DoubleActionFAB extends StatelessWidget {
  const DoubleActionFAB({
    Key? key,
    required this.labelValue,
    required this.pageScrollController,
    required this.showMainFab,
    this.isMainActionAvailable = false,
    this.showFabToTop = false,
    this.onMainActionPressed,
    this.icon,
  }) : super(key: key);

  /// Show create book FAB if true.
  final bool isMainActionAvailable;

  /// Doisplay the Floating Action Button if true.
  final bool showMainFab;

  /// Show the scroll to top FAB if true.
  final bool showFabToTop;

  /// Callback fired when them main FAB is pressed.
  final void Function()? onMainActionPressed;

  /// Page scroll controller to scroll to top.
  final ScrollController pageScrollController;

  /// Text value to display in the main Floating Action Button's content.
  final String labelValue;

  /// A widget which will be displayed in front of the label.
  /// Rypically an `Icon` widget.
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (isMainActionAvailable && showMainFab)
          FadeInY(
            beginY: 25.0,
            delay: Duration(milliseconds: 25),
            duration: Duration(milliseconds: 250),
            child: FloatingActionButton.extended(
              onPressed: onMainActionPressed,
              backgroundColor: Colors.grey.shade900,
              label: Text(
                "license_create".tr(),
                style: Utilities.fonts.body(
                  fontWeight: FontWeight.w600,
                ),
              ),
              icon: icon,
            ),
          ),
        if (showMainFab && showFabToTop)
          FadeInY(
            beginY: 25.0,
            duration: Duration(milliseconds: 250),
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: FloatingActionButton(
                onPressed: () {
                  pageScrollController.animateTo(
                    0.0,
                    duration: Duration(milliseconds: 250),
                    curve: Curves.decelerate,
                  );
                },
                heroTag: null,
                backgroundColor: Colors.grey.shade900,
                child: Icon(UniconsLine.arrow_up),
              ),
            ),
          ),
      ],
    );
  }
}
