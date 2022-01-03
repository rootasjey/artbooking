import 'package:artbooking/components/dot_close_button.dart';
import 'package:artbooking/utils/fonts.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';

class TitleDialog extends StatelessWidget {
  const TitleDialog({
    Key? key,
    required this.titleValue,
    required this.subtitleValue,
    required this.onCancel,
  }) : super(key: key);

  final String titleValue;
  final String subtitleValue;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 12.0,
          left: 12.0,
          child: DotCloseButton(
            tooltip: "cancel".tr(),
            onTap: onCancel,
          ),
        ),
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 24.0,
                left: 24.0,
                right: 24.0,
              ),
              child: Column(
                children: [
                  Opacity(
                    opacity: 0.8,
                    child: Text(
                      titleValue,
                      style: FontsUtils.mainStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Opacity(
                    opacity: 0.4,
                    child: Text(
                      subtitleValue,
                      style: FontsUtils.mainStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Divider(
                thickness: 1.5,
                color: Theme.of(context).secondaryHeaderColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
