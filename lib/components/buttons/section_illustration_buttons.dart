import 'package:artbooking/components/buttons/circle_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class SectionIllustrationButtons extends StatelessWidget {
  const SectionIllustrationButtons({
    Key? key,
    this.onRemoveIllustration,
    this.onPickIllustration,
  }) : super(key: key);

  final void Function()? onRemoveIllustration;
  final void Function()? onPickIllustration;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12.0,
      runSpacing: 12.0,
      children: [
        CircleButton(
          elevation: 2.0,
          shape: CircleBorder(
            side: BorderSide(color: Colors.white38, width: 2.0),
          ),
          onTap: onRemoveIllustration,
          tooltip: "illustration_remove".tr(),
          icon: Icon(UniconsLine.minus),
        ),
        CircleButton(
          elevation: 2.0,
          shape: CircleBorder(
            side: BorderSide(color: Colors.white38, width: 2.0),
          ),
          onTap: onPickIllustration,
          tooltip: "illustration_change".tr(),
          icon: Icon(UniconsLine.exchange),
        ),
      ],
    );
  }
}
