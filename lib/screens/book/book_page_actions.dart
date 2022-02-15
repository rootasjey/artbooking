import 'package:artbooking/components/buttons/square_button.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/screens/book/book_page.dart';
import 'package:artbooking/types/enums/enum_content_visibility.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class BookPageActions extends StatelessWidget {
  const BookPageActions({
    Key? key,
    required this.multiSelectedItems,
    required this.visibility,
    this.forceMultiSelect = false,
    this.onToggleMultiSelect,
    this.onConfirmDeleteBook,
    this.onShowRenameBookDialog,
    this.onUploadToThisBook,
    this.visible = true,
    this.onUpdateVisibility,
  }) : super(key: key);

  final bool forceMultiSelect;
  final bool visible;

  final EnumContentVisibility visibility;

  final void Function()? onToggleMultiSelect;
  final void Function()? onConfirmDeleteBook;
  final void Function()? onShowRenameBookDialog;
  final void Function()? onUploadToThisBook;
  final void Function(EnumContentVisibility)? onUpdateVisibility;

  /// Currently selected illustrations.
  final MapStringIllustration multiSelectedItems;

  @override
  Widget build(BuildContext context) {
    if (!visible) {
      return Container();
    }

    return Wrap(
      spacing: 12.0,
      runSpacing: 12.0,
      children: [
        SquareButton(
          message: "book_upload_illustration".tr(),
          onTap: onConfirmDeleteBook,
          child: Icon(UniconsLine.upload),
        ),
        SquareButton(
          message: "book_delete".tr(),
          onTap: onUploadToThisBook,
          child: Icon(UniconsLine.trash),
        ),
        SquareButton(
          message: "book_rename".tr(),
          onTap: onShowRenameBookDialog,
          child: Icon(UniconsLine.edit_alt),
        ),
        SquareButton(
          onTap: onToggleMultiSelect,
          child: Icon(
            UniconsLine.layers,
            color: forceMultiSelect ? Colors.lightGreen : null,
          ),
          message: "multi_select".tr(),
        ),
        PopupMenuButton(
          tooltip: "illustration_visibility_choose".tr(),
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
                  style: Utilities.fonts.style(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          onSelected: onUpdateVisibility,
          itemBuilder: (context) => <PopupMenuEntry<EnumContentVisibility>>[
            visibiltyPopupItem(
              value: EnumContentVisibility.private,
              titleValue: "visibility_private".tr(),
              subtitleValue: "visibility_private_description".tr(),
            ),
            visibiltyPopupItem(
              value: EnumContentVisibility.public,
              titleValue: "visibility_public".tr(),
              subtitleValue: "visibility_public_description".tr(),
            ),
          ],
        ),
      ],
    );
  }

  PopupMenuItem<EnumContentVisibility> visibiltyPopupItem({
    required EnumContentVisibility value,
    required String titleValue,
    required String subtitleValue,
  }) {
    return PopupMenuItem(
      value: value,
      child: ListTile(
        title: Text(
          titleValue,
          style: Utilities.fonts.style(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitleValue,
          style: Utilities.fonts.style(
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
