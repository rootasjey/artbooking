import 'package:artbooking/components/buttons/dot_close_button.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';

/// A component displaying a title and subtitle with a close button.
class TitleDialog extends StatelessWidget {
  const TitleDialog({
    Key? key,
    required this.titleValue,
    required this.subtitleValue,
    required this.onCancel,
  }) : super(key: key);

  /// Text title.
  final String titleValue;

  /// Text subtitle.
  final String subtitleValue;

  /// Close button callback.
  final void Function()? onCancel;

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
                  if (titleValue.isNotEmpty)
                    Opacity(
                      opacity: 0.8,
                      child: Text(
                        titleValue,
                        style: Utilities.fonts.body(
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  if (subtitleValue.isNotEmpty)
                    Opacity(
                      opacity: 0.4,
                      child: Text(
                        subtitleValue,
                        textAlign: TextAlign.center,
                        style: Utilities.fonts.body(
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
