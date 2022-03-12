import 'package:artbooking/components/buttons/text_rectangle_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class SectionPageActions extends StatelessWidget {
  const SectionPageActions({
    Key? key,
    this.onDeleteSection,
    this.onEditSection,
  }) : super(key: key);

  /// onDelete callback function (after selecting 'delete' item menu)
  final Function()? onDeleteSection;

  /// onEdit callback function (after selecting 'edit' item menu)
  final Function()? onEditSection;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 48.0),
      child: Wrap(
        spacing: 20.0,
        children: [
          TextRectangleButton(
            onPressed: onEditSection,
            icon: Icon(UniconsLine.edit),
            label: Text("edit".tr()),
            primary: Colors.black38,
          ),
          TextRectangleButton(
            onPressed: onDeleteSection,
            icon: Icon(UniconsLine.trash),
            label: Text("delete".tr()),
            primary: Colors.black38,
          ),
        ],
      ),
    );
  }
}
