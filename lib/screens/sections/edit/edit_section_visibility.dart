import 'package:artbooking/components/popup_menu/popup_menu_icon.dart';
import 'package:artbooking/components/popup_menu/popup_menu_item_icon.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/enums/enum_section_visibility.dart';
import 'package:artbooking/types/popup_entry_section.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class EditSectionVisibility extends StatelessWidget {
  const EditSectionVisibility({
    Key? key,
    required this.visibility,
    this.onValueChanged,
    this.margin = EdgeInsets.zero,
  }) : super(key: key);

  /// External padding (blank space around this widget).
  final EdgeInsets margin;

  /// Section's visibility.
  final EnumSectionVisibility visibility;

  /// Callback event fired when this section's visibility is updated.
  final void Function(EnumSectionVisibility visibility)? onValueChanged;

  @override
  Widget build(BuildContext context) {
    final Color color =
        Theme.of(context).textTheme.bodyText2?.color ?? Colors.black;

    return Padding(
      padding: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Opacity(
              opacity: 0.6,
              child: Text(
                "visibility".tr().toUpperCase(),
                // style: Utilities.fonts.body(
                //   fontSize: 18.0,
                //   fontWeight: FontWeight.w700,
                // ),
                style: Utilities.fonts.body3(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          PopupMenuButton(
            tooltip: "illustration_visibility_choose".plural(1),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  width: 2.0,
                  color: color.withOpacity(0.3),
                ),
                borderRadius: BorderRadius.circular(4.0),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 38.0,
                vertical: 8.0,
              ),
              child: Opacity(
                opacity: 0.6,
                child: Text(
                  "visibility_${visibility.name}".tr().toUpperCase(),
                  style: Utilities.fonts.body(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            onSelected: onValueChanged,
            itemBuilder: (context) => <PopupEntrySection>[
              PopupMenuItemIcon(
                icon: PopupMenuIcon(UniconsLine.user_arrows),
                value: EnumSectionVisibility.public,
                textLabel: "visibility_public".tr(),
              ),
              PopupMenuItemIcon(
                icon: PopupMenuIcon(UniconsLine.lock),
                value: EnumSectionVisibility.staff,
                textLabel: "visibility_staff".tr(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
