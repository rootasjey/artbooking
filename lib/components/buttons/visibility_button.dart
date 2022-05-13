import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/enums/enum_content_visibility.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class VisibilityButton extends StatelessWidget {
  const VisibilityButton(
      {Key? key,
      required this.visibility,
      this.onChangedVisibility,
      this.padding = EdgeInsets.zero,
      this.maxWidth = 200.0,
      this.group = false})
      : super(key: key);

  /// True if there are multiple items selected.
  final bool group;
  final double maxWidth;
  final EdgeInsets padding;
  final EnumContentVisibility visibility;
  final void Function(EnumContentVisibility)? onChangedVisibility;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: PopupMenuButton(
        tooltip: "illustration_visibility_choose".plural(group ? 2 : 1),
        child: Material(
          color: Colors.black87,
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6.0),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxWidth,
              minHeight: 48.0,
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
        onSelected: onChangedVisibility,
        itemBuilder: (context) {
          return [
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
          ];
        },
      ),
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
          style: Utilities.fonts.body(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitleValue,
          style: Utilities.fonts.body(
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
