import 'package:artbooking/components/buttons/square_button.dart';
import 'package:artbooking/components/buttons/text_rectangle_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class MyIllustrationsPageActions extends StatelessWidget {
  const MyIllustrationsPageActions({
    Key? key,
    required this.multiSelectActive,
    required this.show,
    required this.limitThreeInRow,
    this.onUploadIllustration,
    this.onTriggerMultiSelect,
    this.onUpdateLayout,
    this.isOwner = false,
  }) : super(key: key);

  final bool isOwner;
  final bool multiSelectActive;
  final bool show;
  final bool limitThreeInRow;
  final void Function()? onTriggerMultiSelect;

  /// Limit number of illustrations to 3 in a row.
  final void Function()? onUpdateLayout;
  final void Function()? onUploadIllustration;

  @override
  Widget build(BuildContext context) {
    if (!show || !isOwner) {
      return Container();
    }

    return Wrap(
      spacing: 12.0,
      runSpacing: 12.0,
      children: [
        TextRectangleButton(
          onPressed: onUploadIllustration,
          icon: Icon(UniconsLine.upload),
          label: Text("upload".tr()),
          primary: Colors.black38,
        ),
        SquareButton(
          active: multiSelectActive,
          message: "multi_select".tr(),
          onTap: onTriggerMultiSelect,
          opacity: multiSelectActive ? 1.0 : 0.4,
          child: Icon(
            UniconsLine.layers,
            color: multiSelectActive ? Colors.white : null,
          ),
        ),
        SquareButton(
          active: limitThreeInRow,
          message: "illustrations_layout_three_in_a_row".tr(),
          onTap: onUpdateLayout,
          opacity: limitThreeInRow ? 1.0 : 0.4,
          child: Icon(
            UniconsLine.table,
            color: limitThreeInRow ? Colors.white : null,
          ),
        ),
      ],
    );
  }
}
