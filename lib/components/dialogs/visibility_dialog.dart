import 'package:artbooking/components/buttons/visibility_button.dart';
import 'package:artbooking/components/dialogs/themed_dialog.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/enums/enum_content_visibility.dart';
import 'package:beamer/beamer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class VisibilityDialog extends StatelessWidget {
  const VisibilityDialog({
    Key? key,
    required this.textBodyValue,
    required this.titleValue,
    required this.visibility,
    this.count = 1,
    this.onChangedVisibility,
    this.showDivider = false,
  }) : super(key: key);

  /// Show a divider below the header if true.
  final bool showDivider;

  /// Selected visibility.
  final EnumContentVisibility visibility;

  /// Number of items is going to be deleted, if true.
  final int count;

  final void Function(
    BuildContext context,
    EnumContentVisibility visibility,
  )? onChangedVisibility;

  /// Title's string value.
  final String titleValue;

  /// Body's string value.
  final String textBodyValue;

  @override
  Widget build(BuildContext context) {
    final double width = 310.0;

    return ThemedDialog(
      showDivider: showDivider,
      titleValue: titleValue,
      textButtonValidation: "close".tr(),
      onValidate: Beamer.of(context).popRoute,
      onCancel: Beamer.of(context).popRoute,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (count > 1)
                Container(
                  padding: const EdgeInsets.only(left: 18.0),
                  width: 300.0,
                  child: Opacity(
                    opacity: 0.6,
                    child: Text(
                      "multi_items_selected".plural(
                        count,
                      ),
                      style: Utilities.fonts.body(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              Container(
                padding: const EdgeInsets.only(left: 16.0),
                width: width,
                child: Opacity(
                  opacity: 0.6,
                  child: Text(
                    textBodyValue,
                    style: Utilities.fonts.body(
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ),
              VisibilityButton(
                maxWidth: width,
                visibility: visibility,
                onChangedVisibility: (EnumContentVisibility visibility) =>
                    onChangedVisibility?.call(
                  context,
                  visibility,
                ),
                padding: const EdgeInsets.only(
                  left: 16.0,
                  top: 12.0,
                  bottom: 32.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
