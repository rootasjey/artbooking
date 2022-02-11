import 'package:artbooking/components/buttons/text_rectangle_button.dart';
import 'package:artbooking/screens/book/book_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class BookPageActions extends StatelessWidget {
  const BookPageActions({
    Key? key,
    required this.multiSelectedItems,
    this.forceMultiSelect = false,
    this.onToggleMultiSelect,
    this.onConfirmDeleteBook,
    this.onShowRenameBookDialog,
    this.onUploadToThisBook,
    this.visible = true,
  }) : super(key: key);

  final bool forceMultiSelect;
  final bool visible;

  /// Currently selected illustrations.
  final MapStringIllustration multiSelectedItems;
  final void Function()? onToggleMultiSelect;
  final void Function()? onConfirmDeleteBook;
  final void Function()? onShowRenameBookDialog;
  final void Function()? onUploadToThisBook;

  @override
  Widget build(BuildContext context) {
    if (!visible) {
      return Container();
    }

    return Wrap(
      spacing: 12.0,
      runSpacing: 12.0,
      children: [
        Tooltip(
          message: "book_upload_illustration".tr(),
          child: InkWell(
            onTap: onUploadToThisBook,
            child: Opacity(
              opacity: 0.4,
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 2.0,
                    color: Colors.black54,
                  ),
                ),
                child: Icon(UniconsLine.upload),
              ),
            ),
          ),
        ),
        Tooltip(
          message: "book_delete".tr(),
          child: InkWell(
            onTap: onConfirmDeleteBook,
            child: Opacity(
              opacity: 0.4,
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 2.0,
                    color: Colors.black54,
                  ),
                ),
                child: Icon(UniconsLine.trash),
              ),
            ),
          ),
        ),
        Tooltip(
          message: "book_rename".tr(),
          child: InkWell(
            onTap: onShowRenameBookDialog,
            child: Opacity(
              opacity: 0.4,
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 2.0,
                    color: Colors.black54,
                  ),
                ),
                child: Icon(UniconsLine.edit_alt),
              ),
            ),
          ),
        ),
        TextRectangleButton(
          onPressed: onToggleMultiSelect,
          icon: Icon(UniconsLine.layers),
          label: Text('multi_select'.tr()),
          primary: forceMultiSelect ? Colors.lightGreen : Colors.black38,
        ),
      ],
    );
  }
}
