import 'package:artbooking/components/dialogs/themed_dialog.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:beamer/beamer.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';

class DeleteDialog extends StatelessWidget {
  const DeleteDialog({
    Key? key,
    this.focusNode,
    required this.titleValue,
    required this.descriptionValue,
    this.onValidate,
  }) : super(key: key);

  final FocusNode? focusNode;
  final String titleValue;
  final String descriptionValue;
  final void Function()? onValidate;

  @override
  Widget build(BuildContext context) {
    return ThemedDialog(
      focusNode: focusNode,
      title: Column(
        children: [
          Opacity(
            opacity: 0.8,
            child: Text(
              titleValue,
              style: Utilities.fonts.style(
                color: Colors.black,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(
            width: 300.0,
            padding: const EdgeInsets.only(top: 8.0),
            child: Opacity(
              opacity: 0.4,
              child: Text(
                descriptionValue,
                textAlign: TextAlign.center,
                style: Utilities.fonts.style(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(),
      textButtonValidation: "delete".tr(),
      onCancel: Beamer.of(context).popRoute,
      onValidate: () {
        onValidate?.call();
        Beamer.of(context).popRoute();
      },
    );
  }
}
