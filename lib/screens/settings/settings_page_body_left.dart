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
    required this.socialLinks,
    this.isMobileSize = false,
    this.onEditPicture,
    this.onLinkChanged,
    this.onUploadPicture,
    this.profilePictureHeroTag = "",
  }) : super(key: key);

  /// If true, this widget adapt its layout to small screens.
  final bool isMobileSize;

  /// Callback fired when we tap on the profile picture.
  final void Function()? onEditPicture;

  /// Callback fired when we upload a new picture.
  final void Function()? onUploadPicture;

  /// Callback fired when a social link has changed.
  final void Function(UserSocialLinks userSocialLinks)? onLinkChanged;

  /// Hero tag to animate profile picutre on navigation.
  final String profilePictureHeroTag;

  /// URL to the current authenticated user profile picture.
  final String profilePictureUrl;

  /// User's social links (e.g. instagram, twitter, ...).
  final UserSocialLinks socialLinks;

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
            elevation: 4.0,
            iconData: UniconsLine.edit,
            labelValue: "picture_edit".tr(),
            foreground: foregroundColor,
            onPressed: onEditPicture,
          ),
          DarkElevatedButton.icon(
            elevation: 4.0,
            iconData: UniconsLine.upload,
            labelValue: "picture_upload".tr(),
            foreground: foregroundColor,
            onPressed: onUploadPicture,
            margin: const EdgeInsets.only(top: 16.0),
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
            isMobileSize: isMobileSize,
            socialLinks: socialLinks,
            onLinkChanged: onLinkChanged,
          ),
        ],
      ),
    );
  }
}
