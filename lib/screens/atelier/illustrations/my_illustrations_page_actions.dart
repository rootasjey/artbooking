import 'package:artbooking/components/buttons/square_button.dart';
import 'package:artbooking/components/buttons/text_rectangle_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class MyIllustrationsPageActions extends StatelessWidget {
  const MyIllustrationsPageActions({
    Key? key,
    required this.draggingActive,
    required this.limitThreeInRow,
    required this.multiSelectActive,
    required this.show,
    this.isMobileSize = false,
    this.isOwner = false,
    this.onTriggerMultiSelect,
    this.onUpdateLayout,
    this.onUploadIllustration,
    this.onToggleDrag,
  }) : super(key: key);

  /// (Mobile specific) If true, long pressing a card will start a drag.
  /// Otherwise, long pressing a card will display a context menu.
  final bool draggingActive;

  /// If true, this widget adapt its layout to small screens.
  final bool isMobileSize;

  /// I true, the current authenticated user is the owner of the illustrations.
  final bool isOwner;

  /// If true, multiple illustrations are currently selected.
  final bool multiSelectActive;

  /// This widget will be displayed if true.
  final bool show;

  /// If true, the page layout will be limited to 3 illustrations in a row.
  final bool limitThreeInRow;

  /// Callback fired when multi-select is toggled on/off.
  final void Function()? onTriggerMultiSelect;

  /// Callback fired when activate/deactivate drag status.
  final void Function()? onToggleDrag;

  /// Callback fired to un-/limit number of illustrations to 3 in a row.
  final void Function()? onUpdateLayout;

  /// Callback fired when we want to upload new illustrations.
  final void Function()? onUploadIllustration;

  @override
  Widget build(BuildContext context) {
    if (!show || !isOwner) {
      return Container();
    }

    return Wrap(
      spacing: 12.0,
      runSpacing: 12.0,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (!isMobileSize)
          TextRectangleButton(
            onPressed: onUploadIllustration,
            icon: Icon(UniconsLine.upload),
            label: Text("upload".tr()),
            primary: Colors.black38,
          ),
        multiSelectButton(context),
        SquareButton(
          active: limitThreeInRow,
          message: "illustrations_layout_three_in_a_row".tr(),
          onTap: onUpdateLayout,
          opacity: limitThreeInRow ? 1.0 : 0.4,
          child: Icon(
            UniconsLine.table,
            color: limitThreeInRow ? Colors.white : null,
          ),
        ),
        mobileDragToggleButton(context),
      ],
    );
  }

  Widget multiSelectButton(BuildContext context) {
    if (isMobileSize) {
      return TextRectangleButton(
        backgroundColor:
            multiSelectActive ? Theme.of(context).primaryColor : null,
        compact: true,
        icon: Icon(UniconsLine.layers),
        label: Text("multi_select".tr()),
        onPressed: onTriggerMultiSelect,
        primary: multiSelectActive ? Colors.white : Colors.black38,
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
