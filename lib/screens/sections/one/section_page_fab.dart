import 'package:artbooking/globals/utilities.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class SectionPageFab extends StatelessWidget {
  const SectionPageFab({
    Key? key,
    this.onDeleteSection,
    this.onEditSection,
  }) : super(key: key);

  final void Function()? onDeleteSection;
  final void Function()? onEditSection;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton.extended(
          onPressed: onEditSection,
          icon: Icon(UniconsLine.pen, size: 24.0),
          label: Text("section_edit".tr()),
          extendedTextStyle: Utilities.fonts.body(
            fontSize: 18.0,
            fontWeight: FontWeight.w600,
          ),
          backgroundColor: Colors.black,
          extendedPadding: EdgeInsets.symmetric(
            horizontal: 20.0,
            vertical: 20.0,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: FloatingActionButton(
            heroTag: null,
            onPressed: onDeleteSection,
            child: Icon(UniconsLine.trash),
            backgroundColor: Theme.of(context).secondaryHeaderColor,
          ),
        ),
      ],
    );
  }
}
