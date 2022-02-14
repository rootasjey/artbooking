import 'package:artbooking/components/buttons/text_rectangle_button.dart';
import 'package:artbooking/types/book/book.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class DashboardPageBooksGroupActions extends StatelessWidget {
  const DashboardPageBooksGroupActions({
    Key? key,
    required this.show,
    this.onShowDeleteManyBooks,
    this.onSelectAll,
    required this.multiSelectedItems,
    this.onClearSelection,
  }) : super(key: key);

  final bool show;
  final Map<String?, Book> multiSelectedItems;
  final void Function()? onShowDeleteManyBooks;
  final void Function()? onSelectAll;
  final void Function()? onClearSelection;

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
        TextRectangleButton(
          icon: Icon(UniconsLine.ban),
          label: Text("clear_selection".tr()),
          primary: Colors.black38,
          onPressed: onClearSelection,
        ),
        TextRectangleButton(
          icon: Icon(UniconsLine.layers),
          label: Text("select_all".tr()),
          primary: Colors.black38,
          onPressed: onSelectAll,
        ),
        TextRectangleButton(
          icon: Icon(UniconsLine.trash),
          label: Text("delete".tr()),
          primary: Colors.black38,
          onPressed: onShowDeleteManyBooks,
        ),
      ],
    );
  }
}