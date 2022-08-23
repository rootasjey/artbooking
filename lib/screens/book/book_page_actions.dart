import 'package:artbooking/components/bottom_sheet/book_visibility_sheet.dart';
import 'package:artbooking/components/buttons/dark_elevated_button.dart';
import 'package:artbooking/components/buttons/square_button.dart';
import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/enums/enum_content_visibility.dart';
import 'package:artbooking/types/illustration_map.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:unicons/unicons.dart';

class BookPageActions extends StatelessWidget {
  const BookPageActions({
    Key? key,
    required this.multiSelectedItems,
    required this.visibility,
    this.draggingActive = false,
    this.forceMultiSelect = false,
    this.isMobileSize = false,
    this.visible = true,
    this.onConfirmDeleteBook,
    this.onShareBook,
    this.onShowRenameBookDialog,
    this.onToggleMultiSelect,
    this.onUpdateVisibility,
    this.onUploadToThisBook,
    this.onToggleDrag,
  }) : super(key: key);

  /// (Mobile specific) If true, long pressing a card will start a drag.
  /// Otherwise, long pressing a card will display a context menu.
  final bool draggingActive;

  /// Will activate multi-select if true.
  final bool forceMultiSelect;

  /// If true, this widget adapt its layout to small screens.
  final bool isMobileSize;

  /// If true, this widget is visible.
  final bool visible;

  /// This book's visibility.
  final EnumContentVisibility visibility;

  /// Callback event showing a popup to confirm book deletion.
  final void Function()? onConfirmDeleteBook;

  /// Callback event showing a popup to confirm book deletion.
  final void Function()? onShareBook;

  /// Callback event showing a popup to rename this book.
  final void Function()? onShowRenameBookDialog;

  /// Callback fired when activate/deactivate drag status.
  final void Function()? onToggleDrag;

  /// Callback event when multi-select state is toggled on/off.
  final void Function()? onToggleMultiSelect;

  /// Callback event to upload new illustrations to this book.
  final void Function()? onUploadToThisBook;

  /// Callback event to update this book's visibility.
  final void Function(EnumContentVisibility)? onUpdateVisibility;

  /// Currently selected illustrations.
  final IllustrationMap multiSelectedItems;

  @override
  Widget build(BuildContext context) {
    if (!visible) {
      return Container();
    }

    return Column(
      crossAxisAlignment:
          isMobileSize ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Wrap(
          alignment: isMobileSize ? WrapAlignment.center : WrapAlignment.start,
          spacing: 12.0,
          runSpacing: 12.0,
          children: [
            if (!isMobileSize)
              SquareButton(
                message: "book_upload_illustration".tr(),
                onTap: onUploadToThisBook,
                child: Icon(UniconsLine.upload),
              ),
            SquareButton(
              message: "book_delete".plural(1),
              onTap: onConfirmDeleteBook,
              child: Icon(UniconsLine.trash),
            ),
            SquareButton(
              message: "book_rename".tr(),
              onTap: onShowRenameBookDialog,
              child: Icon(UniconsLine.edit_alt),
            ),
            SquareButton(
              onTap: onShareBook,
              child: Icon(UniconsLine.share),
              message: "share".tr(),
            ),
            SquareButton(
              onTap: onToggleMultiSelect,
              child: Icon(
                UniconsLine.layers,
                color: forceMultiSelect ? Constants.colors.secondary : null,
              ),
              message: "multi_select".tr(),
            ),
            mobileDragToggleButton(),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: visibilityButton(context),
        ),
      ],
    );
  }

  Widget mobileDragToggleButton() {
    if (!isMobileSize) {
      return Container();
    }

    final String status = draggingActive ? "deactivate" : "activate";

    return SquareButton(
      active: draggingActive,
      child: Icon(
        UniconsLine.minus_path,
        color: draggingActive ? Colors.white : null,
      ),
      message: "dragging_mode.$status".tr(),
      onTap: onToggleDrag,
      opacity: draggingActive ? 1.0 : 0.4,
    );
  }

  Widget visibilityButton(BuildContext context) {
    if (isMobileSize) {
      return DarkElevatedButton(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 140.0,
            minHeight: 26.0,
          ),
          child: Center(
            child: Text(
              "visibility_${visibility.name}".tr().toUpperCase(),
              style: Utilities.fonts.body(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        onPressed: () => showVisibilityBottomSheet(context),
      );
    }

    return PopupMenuButton(
      tooltip: "illustration_visibility_choose".plural(1),
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
              style: Utilities.fonts.body(
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
        visibiltyPopupItem(
          value: EnumContentVisibility.archived,
          titleValue: "visibility_archived".tr(),
          subtitleValue: "visibility_archived_description".tr(),
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
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titleValue,
              style: Utilities.fonts.body(
                fontWeight: FontWeight.w700,
              ),
            ),
            Opacity(
              opacity: 0.6,
              child: Text(
                subtitleValue,
                style: Utilities.fonts.body(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<EnumContentVisibility?>? showVisibilityBottomSheet(
      BuildContext context) async {
    return await showCupertinoModalBottomSheet<Future<EnumContentVisibility?>?>(
      context: context,
      expand: false,
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (
          BuildContext context,
          void Function(void Function()) childSetState,
        ) {
          return BookVisibilitySheet(
            onTapVisibilityTile: (EnumContentVisibility visibility) {
              Navigator.of(context).pop();
              onUpdateVisibility?.call(visibility);
            },
            showVisibilityChooser: true,
            visibilityString:
                "visibility_${visibility.name}".tr().toUpperCase(),
          );
        });
      },
    );
  }
}
