import 'package:artbooking/components/buttons/square_button.dart';
import 'package:artbooking/types/illustration/illustration.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class MyIllustrationsPageGroupActions extends StatelessWidget {
  const MyIllustrationsPageGroupActions({
    Key? key,
    required this.show,
    this.onConfirmDeleteGroup,
    this.onSelectAll,
    required this.multiSelectedItems,
    this.onClearSelection,
    this.onAddToBook,
    this.onChangeVisibility,
  }) : super(key: key);

  final bool show;
  final Map<String?, Illustration> multiSelectedItems;
  final void Function()? onConfirmDeleteGroup;
  final void Function()? onSelectAll;
  final void Function()? onClearSelection;
  final void Function()? onAddToBook;
  final void Function()? onChangeVisibility;

  @override
  Widget build(BuildContext context) {
    if (!show) {
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
          message: "clear_selection".tr(),
          child: Icon(UniconsLine.ban),
          onTap: onClearSelection,
        ),
        SquareButton(
          message: "delete".tr(),
          child: Icon(UniconsLine.trash),
          onTap: onConfirmDeleteGroup,
        ),
        SquareButton(
          message: "select_all".tr(),
          child: Icon(UniconsLine.object_group),
          onTap: onSelectAll,
        ),
        SquareButton(
          message: "visibility_change".tr(),
          child: Icon(UniconsLine.eye),
          onTap: onChangeVisibility,
        ),
        SquareButton(
          message: "add_to_book".tr(),
          child: Icon(UniconsLine.book_medical),
          onTap: onAddToBook,
        ),
      ],
    );
  }
}
