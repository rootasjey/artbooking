import 'package:artbooking/components/popup_menu/popup_menu_item_icon.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/license/license.dart';
import 'package:artbooking/types/enums/enum_license_item_action.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class LicenseCardItem extends StatelessWidget {
  const LicenseCardItem({
    Key? key,
    required this.index,
    required this.license,
    this.onTap,
    this.onDelete,
    this.onEdit,
  }) : super(key: key);

  /// Item's position in the list.
  final int index;

  /// License instance to populate this card.
  final License license;

  /// onTap callback function
  final Function(License)? onTap;

  /// onDelete callback function (after selecting 'delete' item menu)
  final Function(License, int)? onDelete;

  /// onEdit callback function (after selecting 'edit' item menu)
  final Function(License, int)? onEdit;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.0,
      color: Theme.of(context).backgroundColor,
      child: InkWell(
        onTap: onTap != null
            ? () {
                onTap?.call(license);
              }
            : null,
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Opacity(
                      opacity: 0.8,
                      child: Text(
                        license.name,
                        style: Utilities.fonts.style(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Opacity(
                        opacity: 0.6,
                        child: Text(
                          license.description,
                          style: Utilities.fonts.style(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            popupMenuButton(license, index),
          ],
        ),
      ),
    );
  }

  Widget popupMenuButton(License license, int index) {
    return PopupMenuButton(
      icon: Icon(UniconsLine.ellipsis_v),
      onSelected: (value) {
        switch (value) {
          case EnumLicenseItemAction.delete:
            onDelete?.call(license, index);
            break;
          case EnumLicenseItemAction.edit:
            onEdit?.call(license, index);
            break;
          default:
        }
      },
      itemBuilder: itemBuilder,
    );
  }

  List<PopupMenuEntry<EnumLicenseItemAction>> itemBuilder(
    BuildContext context,
  ) {
    return [
      PopupMenuItemIcon(
        icon: Icon(UniconsLine.edit),
        textLabel: "edit".tr(),
        value: EnumLicenseItemAction.edit,
      ),
      PopupMenuItemIcon(
        icon: Icon(UniconsLine.trash),
        textLabel: "delete".tr(),
        value: EnumLicenseItemAction.delete,
      ),
    ];
  }
}
