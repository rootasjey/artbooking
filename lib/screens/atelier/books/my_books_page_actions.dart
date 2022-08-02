import 'package:artbooking/components/buttons/square_button.dart';
import 'package:artbooking/components/buttons/text_rectangle_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class MyBooksPageActions extends StatelessWidget {
  const MyBooksPageActions({
    Key? key,
    required this.draggingActive,
    required this.multiSelectActive,
    required this.show,
    this.onShowCreateBookDialog,
    this.onToggleDrag,
    this.onTriggerMultiSelect,
    this.isOwner = false,
    this.isMobileSize = false,
  }) : super(key: key);

  /// (Mobile specific) If true, long pressing a card will start a drag.
  /// Otherwise, long pressing a card will display a context menu.
  final bool draggingActive;

  /// Show create book FAB if true.
  final bool isOwner;

  /// If true, this widget adapt its layout to small screens.
  final bool isMobileSize;

  /// If true, the UI is in multi-select mode.
  final bool multiSelectActive;

  /// Show the scroll to top FAB if true.
  final bool show;

  /// Callback displaying create book dialog.
  final void Function()? onShowCreateBookDialog;

  /// Callback fired when activate/deactivate drag status.
  final void Function()? onToggleDrag;

  /// Callback to turn multi-select ON.
  final void Function()? onTriggerMultiSelect;

  @override
  Widget build(BuildContext context) {
    if (!show || !isOwner) {
      return Container();
    }

    return Wrap(
      spacing: 12.0,
      runSpacing: 12.0,
      children: [
        if (!isMobileSize)
          TextRectangleButton(
            onPressed: onShowCreateBookDialog,
            icon: Icon(UniconsLine.plus),
            label: Text("create".tr()),
            primary: Colors.black38,
          ),
        multiSelectButton(context),
        mobileDragToggleButton(context),
      ],
    );
  }

  Widget multiSelectButton(BuildContext context) {
    if (isMobileSize) {
      return TextRectangleButton(
        onPressed: onTriggerMultiSelect,
        icon: Icon(UniconsLine.layers),
        label: Text("multi_select".tr()),
        primary: multiSelectActive ? Colors.white : Colors.black38,
        backgroundColor:
            multiSelectActive ? Theme.of(context).primaryColor : null,
      );
    }

    return SquareButton(
      active: multiSelectActive,
      message: "multi_select".tr(),
      onTap: onTriggerMultiSelect,
      opacity: multiSelectActive ? 1.0 : 0.4,
      child: Icon(
        UniconsLine.layers,
        color: multiSelectActive ? Colors.white : null,
      ),
    );
  }

  Widget mobileDragToggleButton(BuildContext context) {
    if (!isMobileSize) {
      return Container();
    }

    final String status = draggingActive ? "deactivate" : "activate";

    return SquareButton(
      active: draggingActive,
      message: "dragging_mode.$status".tr(),
      onTap: onToggleDrag,
      opacity: draggingActive ? 1.0 : 0.4,
      child: Icon(
        UniconsLine.minus_path,
        color: draggingActive ? Colors.white : null,
      ),
    );
  }
}
