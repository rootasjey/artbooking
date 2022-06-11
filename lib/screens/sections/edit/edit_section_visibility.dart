import 'package:artbooking/components/popup_menu/popup_menu_icon.dart';
import 'package:artbooking/components/popup_menu/popup_menu_item_icon.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/enums/enum_section_visibility.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class EditSectionVisibility extends StatelessWidget {
  const EditSectionVisibility({
    Key? key,
    required this.visibility,
    this.onValueChanged,
    this.padding = EdgeInsets.zero,
  }) : super(key: key);

  final EdgeInsets padding;
  final EnumSectionVisibility visibility;
  final void Function(EnumSectionVisibility visibility)? onValueChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Opacity(
            opacity: 0.6,
            child: Text(
              "visibility".tr(),
              style: Utilities.fonts.body(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          PopupMenuButton(
            tooltip: "illustration_visibility_choose".plural(1),
            child: Material(
              color: Colors.black87,
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6.0),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 200.0,
                  minHeight: 45.0,
                ),
                child: Center(
                  child: Text(
                    "visibility_${visibility.name}".tr().toUpperCase(),
                    style: Utilities.fonts.body(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            onSelected: onValueChanged,
            itemBuilder: (context) => <PopupMenuEntry<EnumSectionVisibility>>[
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
