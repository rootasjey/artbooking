import 'package:artbooking/components/avatar/better_avatar.dart';
import 'package:artbooking/components/buttons/dark_elevated_button.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class SettingsPageBodyLeft extends StatelessWidget {
  const SettingsPageBodyLeft({
    Key? key,
    required this.profilePictureUrl,
    this.onEditPicture,
    this.onUploadPicture,
  }) : super(key: key);

  final String profilePictureUrl;
  final void Function()? onEditPicture;
  final void Function()? onUploadPicture;

  @override
  Widget build(BuildContext context) {
    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyText2?.color?.withOpacity(0.6);

    return SizedBox(
      width: 400.0,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: BetterAvatar(
              image: NetworkImage(
                profilePictureUrl,
              ),
            ),
          ),
          DarkElevatedButton.icon(
            iconData: UniconsLine.edit,
            labelValue: "picture_edit".tr(),
            foreground: foregroundColor,
            onPressed: onEditPicture,
          ),
          Padding(padding: const EdgeInsets.only(top: 16.0)),
          DarkElevatedButton.icon(
            iconData: UniconsLine.upload,
            labelValue: "picture_upload".tr(),
            foreground: foregroundColor,
            onPressed: onUploadPicture,
          ),
        ],
      ),
    );
  }
}
