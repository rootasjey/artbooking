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
    this.profilePictureHeroTag = '',
    this.isMobileSize = false,
  }) : super(key: key);

  /// If true, this widget adapt its layout to small screens.
  final bool isMobileSize;

  final UserFirestore userFirestore;
  final void Function()? onEditPicture;
  final void Function()? onUploadPicture;

  final void Function()? onGoToDeleteAccount;
  final void Function()? onGoToUpdatePasssword;
  final void Function()? onGoToUpdateUsername;
  final void Function()? onGoToUpdateEmail;
  final void Function()? onEditLocation;
  final void Function()? onEditBio;
  final void Function(UserSocialLinks)? onLinkChanged;
  final String profilePictureHeroTag;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.only(
          top: 18.0,
          left: isMobileSize ? 24.0 : 100.0,
          right: isMobileSize ? 24.0 : 100.0,
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
