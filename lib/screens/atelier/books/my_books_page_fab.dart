import 'package:artbooking/components/animations/fade_in_y.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class MyBooksPageFab extends StatelessWidget {
  const MyBooksPageFab({
    Key? key,
    required this.pageScrollController,
    required this.showFabCreate,
    this.isOwner = false,
    this.onShowCreateBookDialog,
    this.showFabToTop = false,
  }) : super(key: key);

  /// Show create book FAB if true.
  final bool isOwner;

  /// Show the scroll to top FAB if true.
  final bool showFabCreate;

  /// Show the scroll to top FAB if true.
  final bool showFabToTop;

  /// Callback fired when we tap on the create floating action button.
  /// This should show a popup/bottom sheet to create a new book.
  final void Function()? onShowCreateBookDialog;

  /// Page scroll controller to scroll to top.
  final ScrollController pageScrollController;

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
              onPressed: onShowCreateBookDialog,
              backgroundColor: Colors.grey.shade900,
              label: Text(
                "create".tr(),
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
