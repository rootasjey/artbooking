import 'package:artbooking/components/popup_menu/popup_menu_item_icon.dart';
import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/license/license.dart';
import 'package:artbooking/types/enums/enum_license_item_action.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:unicons/unicons.dart';

class LicenseCardItem extends StatelessWidget {
  const LicenseCardItem({
    Key? key,
    required this.index,
    required this.license,
    this.onDelete,
    this.onEdit,
    this.onTap,
    this.useBottomSheet = false,
    this.popupMenuEntries = const [],
    this.onPopupMenuItemSelected,
  }) : super(key: key);

  /// If true, a bottom sheet will be displayed on long press event.
  /// Setting this property to true will deactivate popup menu and
  /// hide like button.
  final bool useBottomSheet;

  /// Item's position in the list.
  final int index;

  /// License instance to populate this card.
  final License license;

  /// Callback fired after selecting a popup menu item.
  final void Function(
    EnumLicenseItemAction action,
    int index,
    License license,
  )? onPopupMenuItemSelected;

  /// onTap callback function
  final void Function(License)? onTap;

  /// onDelete callback function (after selecting 'delete' item menu)
  final void Function(License, int)? onDelete;

  /// onEdit callback function (after selecting 'edit' item menu)
  final void Function(License, int)? onEdit;

  /// Owner popup menu entries.
  final List<PopupMenuItemIcon<EnumLicenseItemAction>> popupMenuEntries;
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.0,
      color: Theme.of(context).backgroundColor,
      child: InkWell(
        onLongPress: useBottomSheet ? () => onLongPress(context) : null,
        onTap: onTap != null ? () => onTap?.call(license) : null,
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Hero(
                      tag: license.name,
                      child: Opacity(
                        opacity: 0.8,
                        child: Text(
                          license.name,
                          style: Utilities.fonts.body(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Opacity(
                        opacity: 0.6,
                        child: Text(
                          license.description,
                          style: Utilities.fonts.body(
                            fontSize: 14.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            popupMenuButton(),
          ],
        ),
      ),
    );
  }

  Widget popupMenuButton() {
    if (popupMenuEntries.isEmpty || useBottomSheet) {
      return Container();
    }

    return PopupMenuButton(
      child: CircleAvatar(
        radius: 15.0,
        backgroundColor: Constants.colors.clairPink,
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Icon(UniconsLine.ellipsis_h, size: 20),
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6.0),
      ),
      onSelected: (EnumLicenseItemAction action) {
        onPopupMenuItemSelected?.call(
          action,
          index,
          license,
        );
      },
      itemBuilder: (_) => popupMenuEntries,
    );
  }

  void onLongPress(BuildContext context) {
    showCupertinoModalBottomSheet(
      context: context,
      expand: false,
      backgroundColor: Colors.white70,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Material(
            borderRadius: BorderRadius.circular(8.0),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: popupMenuEntries.map(
                  (PopupMenuItemIcon<EnumLicenseItemAction> popupMenuEntry) {
                    return ListTile(
                      title: Opacity(
                        opacity: 0.8,
                        child: Text(
                          popupMenuEntry.textLabel,
                          style: Utilities.fonts.body(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      trailing: popupMenuEntry.icon,
                      onTap: () {
                        Navigator.of(context).pop();
                        final EnumLicenseItemAction? action =
                            popupMenuEntry.value;

                        if (action == null) {
                          return;
                        }

                        onPopupMenuItemSelected?.call(
                          action,
                          index,
                          license,
                        );
                      },
                    );
                  },
                ).toList(),
              ),
            ),
          ),
        );
      },
    );
  }
}
