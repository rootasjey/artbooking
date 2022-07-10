import 'package:artbooking/components/animations/fade_in_y.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class ProfilePageFAB extends StatelessWidget {
  const ProfilePageFAB({
    Key? key,
    required this.isOwner,
    required this.onToggleEditMode,
    required this.pageScrollController,
    required this.editMode,
    required this.showFab,
    required this.showNavToTopFab,
  }) : super(key: key);

  /// True if the current authenticated user- if any - is the owner of this page.
  final bool isOwner;

  /// True if the page can be edited.
  final bool editMode;

  /// If true, a Floating Action Button to scroll to top will be displayed.
  final bool showFab;

  /// If true, a Floating Action Button to scroll to top will be displayed.
  final bool showNavToTopFab;

  /// Page scroll controller which controlls the page offset.
  final ScrollController pageScrollController;

  /// Callback event fired when we want to activate/deactivate edit mode.
  final void Function()? onToggleEditMode;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (isOwner && showFab)
          FadeInY(
            beginY: 25.0,
            delay: Duration(milliseconds: 25),
            duration: Duration(milliseconds: 250),
            child: FloatingActionButton.extended(
              onPressed: onToggleEditMode,
              backgroundColor: Colors.amber.shade600,
              label: Text(
                editMode ? "edit_mode".tr() : "view_mode".tr(),
                style: Utilities.fonts.body(
                  fontWeight: FontWeight.w600,
                ),
              ),
              icon: Icon(
                editMode ? UniconsLine.pen : UniconsLine.eye,
              ),
            ),
          ),
        if (showFab && showNavToTopFab)
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
