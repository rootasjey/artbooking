import 'package:artbooking/components/buttons/square_button.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/illustration/illustration.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class MyIllustrationsPageGroupActions extends StatelessWidget {
  const MyIllustrationsPageGroupActions({
    Key? key,
    required this.multiSelectedItems,
    required this.show,
    this.isMobileSize = false,
    this.onConfirmDeleteGroup,
    this.onSelectAll,
    this.onClearSelection,
    this.onAddToBook,
    this.onChangeGroupVisibility,
  }) : super(key: key);

  /// If true, this widget adapt its layout to small screens.
  final bool isMobileSize;

  /// Show this widget if true.
  final bool show;

  /// Callback showing a dialog/bottom sheet to add selected books to other ones.
  /// Fired when we tap on "add to book" icon button.
  final void Function()? onAddToBook;

  /// Callback to change current selected illustrations' visibility.
  /// Fired when we tap on "visibility" icon button.
  final void Function()? onChangeGroupVisibility;

  /// Callback de-seleting all selected illustrations.
  /// Fired when we tap on "de-select all" icon button.
  final void Function()? onClearSelection;

  /// Callback showing a confirmation popup/bottom sheet group deletion.
  /// Fired when we tap on delete icon button.
  final void Function()? onConfirmDeleteGroup;

  /// Callback seleting all displayed illustrations.
  /// Fired when we tap on "select all" icon button.
  final void Function()? onSelectAll;

  /// Currently selected illustrations.
  final Map<String?, Illustration> multiSelectedItems;

  @override
  Widget build(BuildContext context) {
    if (!show) {
      return Container();
    }

    if (isMobileSize) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          countText(),
          Wrap(
            spacing: 6.0,
            runSpacing: 6.0,
            children: actions(),
          ),
        ],
      );
    }

    return Wrap(
      spacing: 12.0,
      runSpacing: 12.0,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        countText(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Container(
            height: 25.0,
            width: 2.0,
            color: Colors.black12,
          ),
        ),
        ...actions(),
      ],
    );
  }

  List<Widget> actions() {
    return [
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
        onTap: onChangeGroupVisibility,
      ),
      SquareButton(
        message: "add_to_book".tr(),
        child: Icon(UniconsLine.book_medical),
        onTap: onAddToBook,
      )
    ];
  }

  Widget countText() {
    return Opacity(
      opacity: 0.6,
      child: Text(
        "multi_items_selected".tr(
          args: [multiSelectedItems.length.toString()],
        ),
        style: Utilities.fonts.body4(
          fontSize: isMobileSize ? 16.0 : 28.0,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
