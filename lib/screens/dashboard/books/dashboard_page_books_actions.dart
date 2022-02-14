import 'package:artbooking/components/buttons/square_button.dart';
import 'package:artbooking/components/buttons/text_rectangle_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class DashboardPageBooksActions extends StatelessWidget {
  const DashboardPageBooksActions({
    Key? key,
    required this.multiSelectActive,
    required this.show,
    this.onShowCreateBookDialog,
    this.onTriggerMultiSelect,
  }) : super(key: key);

  final bool multiSelectActive;
  final bool show;
  final void Function()? onShowCreateBookDialog;
  final void Function()? onTriggerMultiSelect;

  @override
  Widget build(BuildContext context) {
    if (!show) {
      return Container();
    }

    return Wrap(
      spacing: 12.0,
      runSpacing: 12.0,
      children: [
        TextRectangleButton(
          onPressed: onShowCreateBookDialog,
          icon: Icon(UniconsLine.plus),
          label: Text('create'.tr()),
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
      ],
    );
  }
}