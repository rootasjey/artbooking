import 'package:artbooking/components/buttons/square_button.dart';
import 'package:artbooking/screens/book/book_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class BookPageGroupActions extends StatelessWidget {
  const BookPageGroupActions({
    Key? key,
    required this.multiSelectedItems,
    this.onAddToBook,
    this.onMultiSelectAll,
    this.onClearMultiSelect,
    this.onConfirmRemoveGroup,
    this.visible = false,
  }) : super(key: key);

  final bool visible;

  /// Currently selected illustrations.
  final MapStringIllustration multiSelectedItems;

  final void Function()? onAddToBook;
  final void Function()? onMultiSelectAll;
  final void Function()? onClearMultiSelect;
  final void Function()? onConfirmRemoveGroup;

  @override
  Widget build(BuildContext context) {
    if (!visible) {
      return Container();
    }

    return Wrap(
      spacing: 12.0,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Opacity(
          opacity: 0.6,
          child: Text(
            "multi_items_selected".tr(
              args: [multiSelectedItems.length.toString()],
            ),
            style: TextStyle(
              fontSize: 30.0,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Container(
            height: 25.0,
            width: 2.0,
            color: Colors.black12,
          ),
        ),
        SquareButton(
          child: Icon(UniconsLine.ban),
          message: "clear_selection".tr(),
          onTap: onClearMultiSelect,
        ),
        SquareButton(
          child: Icon(UniconsLine.layers),
          message: "select_all".tr(),
          onTap: onMultiSelectAll,
        ),
        SquareButton(
          child: Icon(UniconsLine.minus_circle),
          message: "remove".tr(),
          onTap: onConfirmRemoveGroup,
        ),
        SquareButton(
          child: Icon(UniconsLine.book_medical),
          message: "add_to_book".tr(),
          onTap: onAddToBook,
        ),
      ],
    );
  }
}
