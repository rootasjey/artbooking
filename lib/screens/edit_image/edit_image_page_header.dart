import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:beamer/beamer.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class EditImagePageHeader extends StatelessWidget {
  const EditImagePageHeader({
    Key? key,
    required this.isProcessing,
    this.goToEditIllustrationMetada,
    this.isMobileSize = false,
  }) : super(key: key);

  /// If true, this widget adapt its layout to small screens.
  final bool isMobileSize;

  final bool isProcessing;
  final void Function()? goToEditIllustrationMetada;

  @override
  Widget build(BuildContext context) {
    final EdgeInsets padding =
        isMobileSize ? const EdgeInsets.all(12.0) : const EdgeInsets.all(60.0);

    return Padding(
      padding: padding,
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isMobileSize)
                Padding(
                  padding: const EdgeInsets.only(right: 24.0),
                  child: Opacity(
                    opacity: 0.8,
                    child: IconButton(
                      tooltip: "back".tr(),
                      onPressed: Beamer.of(context).popRoute,
                      icon: Icon(UniconsLine.arrow_left),
                    ),
                  ),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Opacity(
                        opacity: 0.8,
                        child: Text(
                          isProcessing
                              ? "${'changes_applying'.tr()}..."
                              : "edit_image".tr(),
                          style: Utilities.fonts.body(
                            fontSize: 24.0,
                            fontWeight: FontWeight.w700,
                            color: isProcessing
                                ? Theme.of(context).secondaryHeaderColor
                                : null,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
                      child: Opacity(
                        opacity: 0.4,
                        child: Text(
                          "edit_image_description".tr(),
                          style: Utilities.fonts.body(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: goToEditIllustrationMetada,
                      child: Text(
                        "edit_image_suggestion".tr(),
                        style: Utilities.fonts.body(
                          fontWeight: FontWeight.w600,
                          backgroundColor:
                              Constants.colors.tertiary.withOpacity(0.3),
                        ),
                      ),
                      style: TextButton.styleFrom(
                        primary: Theme.of(context)
                            .textTheme
                            .bodyText2
                            ?.color
                            ?.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
