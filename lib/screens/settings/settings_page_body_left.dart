import 'package:artbooking/components/avatar/better_avatar.dart';
import 'package:artbooking/components/buttons/dark_elevated_button.dart';
import 'package:artbooking/components/user_social_links_component.dart';
import 'package:artbooking/types/user/user_social_links.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class SettingsPageBodyLeft extends StatelessWidget {
  const SettingsPageBodyLeft({
    Key? key,
    required this.profilePictureUrl,
    this.onEditPicture,
    this.onUploadPicture,
    required this.socialLinks,
    this.onLinkChanged,
    this.profilePictureHeroTag = '',
  }) : super(key: key);

  final void Function()? onEditPicture;
  final void Function()? onUploadPicture;
  final void Function(UserSocialLinks)? onLinkChanged;
  final String profilePictureUrl;
  final UserSocialLinks socialLinks;
  final String profilePictureHeroTag;

  @override
  Widget build(BuildContext context) {
    final Color? foregroundColor =
        Theme.of(context).textTheme.bodyText2?.color?.withOpacity(0.6);

    return SizedBox(
      width: 400.0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: Hero(
              tag: profilePictureHeroTag,
              child: BetterAvatar(
                image: NetworkImage(
                  profilePictureUrl,
                ),
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
          Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: 100.0, child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    radius: 4.0,
                  ),
                ),
                SizedBox(width: 100.0, child: Divider()),
              ],
            ),
          ),
          UserSocialLinksComponent(
            editMode: true,
            socialLinks: socialLinks,
            onLinkChanged: onLinkChanged,
          ),
        ],
      ),
    );
  }
}
