import 'package:artbooking/components/buttons/square_button.dart';
import 'package:artbooking/types/illustration_map.dart';
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
    this.isMobileSize = false,
  }) : super(key: key);

  /// If true, this widget adapt its layout to small screens.
  final bool isMobileSize;

  final bool visible;

  /// Currently selected illustrations.
  final IllustrationMap multiSelectedItems;

  final void Function()? onAddToBook;
  final void Function()? onMultiSelectAll;
  final void Function()? onClearMultiSelect;
  final void Function()? onConfirmRemoveGroup;

  @override
  Widget build(BuildContext context) {
    if (!visible) {
      return Container();
    }

    final Widget selectedText = Opacity(
      opacity: 0.6,
      child: Text(
        "multi_items_selected".tr(
          args: [multiSelectedItems.length.toString()],
        ),
        style: TextStyle(
          fontSize: isMobileSize ? 24.0 : 30.0,
          fontWeight: isMobileSize ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    );

    if (isMobileSize) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          selectedText,
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Wrap(
              spacing: 12.0,
              runSpacing: 12.0,
              children: buttonsWidget(),
            ),
          ),
        ],
      );
    }

    return Wrap(
      spacing: 12.0,
      runSpacing: 12.0,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        selectedText,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Container(
            height: 25.0,
            width: 2.0,
            color: Colors.black12,
          ),
        ),
        ...buttonsWidget(),
      ],
    );
  }

  List<Widget> buttonsWidget() {
    return [
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
    ];
  }
}
