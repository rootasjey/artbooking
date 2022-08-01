import 'package:artbooking/components/animations/fade_in_y.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/screens/atelier/illustrations/visibility_tile.dart';
import 'package:artbooking/types/enums/enum_content_visibility.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class BookVisibilitySheet extends StatelessWidget {
  const BookVisibilitySheet({
    Key? key,
    required this.showVisibilityChooser,
    required this.visibilityString,
    this.multiSelectedItemLength = 0,
    this.onTapVisibilityTile,
    this.onToggleVisibilityChoice,
  }) : super(key: key);

  /// If true, display a list of visibility item.
  final bool showVisibilityChooser;

  /// Callback fired after tapping on this tile.
  final void Function(EnumContentVisibility visibility)? onTapVisibilityTile;

  /// Callback fired when we tap on visibility button.
  final void Function()? onToggleVisibilityChoice;

  /// Number of selected item.
  final int multiSelectedItemLength;

  /// Current visibility value as string.
  final String visibilityString;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 0.0),
              child: Text(
                "book_visibility_change".plural(
                  multiSelectedItemLength,
                ),
                style: Utilities.fonts.body(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (multiSelectedItemLength > 0)
              Opacity(
                opacity: 0.6,
                child: Text(
                  "multi_items_selected".plural(
                    multiSelectedItemLength,
                  ),
                  style: Utilities.fonts.body(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            Opacity(
              opacity: 0.6,
              child: Text(
                "illustration_visibility_choose".plural(
                  multiSelectedItemLength,
                ),
                style: Utilities.fonts.body(
                  fontSize: 16.0,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 12.0,
                bottom: 32.0,
              ),
              child: Material(
                color: Colors.black87,
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.0),
                ),
                child: InkWell(
                  onTap: onToggleVisibilityChoice,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: 200.0,
                      minHeight: 48.0,
                    ),
                    child: Center(
                      child: Text(
                        visibilityString,
                        style: Utilities.fonts.body(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            visibilityChooser(),
          ],
        ),
      ),
    );
  }

  Widget visibilityChooser() {
    if (!showVisibilityChooser) {
      return Container();
    }

    int delay = 0;

    return Column(
      children: [
        VisibilityTile(
          visibility: EnumContentVisibility.private,
          titleValue: "visibility_private".tr(),
          subtitleValue: "visibility_private_description".tr(),
          onTap: onTapVisibilityTile,
        ),
        VisibilityTile(
          visibility: EnumContentVisibility.public,
          titleValue: "visibility_public".tr(),
          subtitleValue: "visibility_public_description".tr(),
          onTap: onTapVisibilityTile,
        ),
        VisibilityTile(
          visibility: EnumContentVisibility.archived,
          titleValue: "visibility_archived".tr(),
          subtitleValue: "visibility_archived_description".tr(),
          onTap: onTapVisibilityTile,
        ),
      ].map((VisibilityTile child) {
        delay += 50;

        return FadeInY(
          beginY: 6.0,
          delay: Duration(milliseconds: delay),
          child: child,
        );
      }).toList(),
    );
  }
}
