import 'package:artbooking/globals/utilities.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class ProfilePageFAB extends StatelessWidget {
  const ProfilePageFAB({
    Key? key,
    required this.isOwner,
    required this.onToggleEditMode,
    required this.scrollController,
    required this.editMode,
    required this.showFabToTop,
  }) : super(key: key);

  final bool isOwner;
  final bool editMode;
  final bool showFabToTop;
  final ScrollController scrollController;
  final void Function()? onToggleEditMode;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (isOwner)
          FloatingActionButton.extended(
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
        if (showFabToTop)
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: FloatingActionButton(
              onPressed: () {
                scrollController.animateTo(
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
      ],
    );
  }
}
