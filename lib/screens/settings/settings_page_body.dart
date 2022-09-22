import 'package:artbooking/screens/settings/settings_page_body_left.dart';
import 'package:artbooking/screens/settings/settings_page_body_right.dart';
import 'package:artbooking/types/user/user_firestore.dart';
import 'package:artbooking/types/user/user_social_links.dart';
import 'package:flutter/material.dart';

class SettingsPageBody extends StatelessWidget {
  const SettingsPageBody({
    Key? key,
    required this.userFirestore,
    this.onEditPicture,
    this.onUploadPicture,
    this.onGoToDeleteAccount,
    this.onGoToUpdatePasssword,
    this.onGoToUpdateUsername,
    this.onGoToUpdateEmail,
    this.onEditLocation,
    this.onEditBio,
    this.onLinkChanged,
    this.profilePictureHeroTag = "",
    this.isMobileSize = false,
    this.windowWidth = 0.0,
  }) : super(key: key);

  /// If true, this widget adapt its layout to small screens.
  final bool isMobileSize;

  /// App window's width.
  final double windowWidth;

  /// Callback fired to edit our biography.
  final void Function()? onEditBio;

  /// Callback fired to edit our location.
  final void Function()? onEditLocation;

  /// Callback fired when we tap on the profile picture.
  final void Function()? onEditPicture;

  /// Callback fired to navigate to account deletion.
  final void Function()? onGoToDeleteAccount;

  /// Callback fired to navigate to password update page.
  final void Function()? onGoToUpdatePasssword;

  /// Callback fired to navigate to username update page.
  final void Function()? onGoToUpdateUsername;

  /// Callback fired to navigate to email update page.
  final void Function()? onGoToUpdateEmail;

  /// Callback fired when a social link has changed.
  final void Function(UserSocialLinks userSocialLinks)? onLinkChanged;

  /// Callback fired when we upload a new picture.
  final void Function()? onUploadPicture;

  /// Hero tag to animate profile picutre on navigation.
  final String profilePictureHeroTag;

  /// Current authenticated user.
  final UserFirestore userFirestore;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.only(
          top: 18.0,
          left: isMobileSize ? 12.0 : 100.0,
          right: isMobileSize ? 12.0 : 100.0,
          bottom: 300.0,
        ),
        child: isMobileSize ? columnChild() : rowChild(),
      ),
    );
  }

  Widget columnChild() {
    return Column(
      children: [
        SettingsPageBodyLeft(
          isMobileSize: isMobileSize,
          profilePictureHeroTag: profilePictureHeroTag,
          profilePictureUrl: userFirestore.getProfilePicture(),
          onEditPicture: onEditPicture,
          onUploadPicture: onUploadPicture,
          socialLinks: userFirestore.socialLinks,
          onLinkChanged: onLinkChanged,
        ),
        SettingsPageBodyRight(
          isMobileSize: isMobileSize,
          userFirestore: userFirestore,
          onEditLocation: onEditLocation,
          onEditBio: onEditBio,
          onGoToDeleteAccount: onGoToDeleteAccount,
          onGoToUpdateEmail: onGoToUpdateEmail,
          onGoToUpdatePasssword: onGoToUpdatePasssword,
          onGoToUpdateUsername: onGoToUpdateUsername,
          windowWidth: windowWidth,
        ),
      ],
    );
  }

  Widget rowChild() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsPageBodyLeft(
          profilePictureHeroTag: profilePictureHeroTag,
          profilePictureUrl: userFirestore.getProfilePicture(),
          onEditPicture: onEditPicture,
          onUploadPicture: onUploadPicture,
          socialLinks: userFirestore.socialLinks,
          onLinkChanged: onLinkChanged,
        ),
        SettingsPageBodyRight(
          userFirestore: userFirestore,
          onEditLocation: onEditLocation,
          onEditBio: onEditBio,
          onGoToDeleteAccount: onGoToDeleteAccount,
          onGoToUpdateEmail: onGoToUpdateEmail,
          onGoToUpdatePasssword: onGoToUpdatePasssword,
          onGoToUpdateUsername: onGoToUpdateUsername,
        ),
      ],
    );
  }
}
