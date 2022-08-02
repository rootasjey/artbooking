import 'package:artbooking/components/animations/fade_in_y.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class LicensesPageFab extends StatelessWidget {
  const LicensesPageFab({
    Key? key,
    required this.label,
    required this.pageScrollController,
    required this.showFabCreate,
    this.onPressed,
    this.tooltip,
    this.isMobileSize = false,
    this.showFabToTop = false,
    this.isOwner = false,
  }) : super(key: key);

  /// If true, this widget adapt its layout to small screens.
  final bool isMobileSize;

  /// Show create book FAB if true.
  final bool isOwner;

  /// Doisplay the Floating Action Button if true.
  final bool showFabCreate;

  /// Show the scroll to top FAB if true.
  final bool showFabToTop;

  /// Callback when this FAB is pressed.
  final void Function()? onPressed;

  /// Message to display while hovering FAB.
  final String? tooltip;

  /// Page scroll controller to scroll to top.
  final ScrollController pageScrollController;

  /// Label to display as the main FAB content. Typically a `Text` widget.
  final Widget label;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (isOwner && showFabCreate)
          FadeInY(
            beginY: 25.0,
            delay: Duration(milliseconds: 25),
            duration: Duration(milliseconds: 250),
            child: FloatingActionButton.extended(
              onPressed: onPressed,
              backgroundColor: Colors.grey.shade900,
              label: Text(
                "license_create".tr(),
                style: Utilities.fonts.body(
                  fontWeight: FontWeight.w600,
                ),
              ),
              icon: Icon(UniconsLine.plus),
            ),
          ),
        if (showFabCreate && showFabToTop)
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
