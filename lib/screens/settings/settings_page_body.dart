import 'package:artbooking/screens/settings/settings_page_body_left.dart';
import 'package:artbooking/screens/settings/settings_page_body_right.dart';
import 'package:artbooking/types/user/user_firestore.dart';
import 'package:artbooking/types/user/user_urls.dart';
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
    this.onEditSummary,
    this.onUrlChanged,
  }) : super(key: key);

  final UserFirestore userFirestore;
  final void Function()? onEditPicture;
  final void Function()? onUploadPicture;

  final void Function()? onGoToDeleteAccount;
  final void Function()? onGoToUpdatePasssword;
  final void Function()? onGoToUpdateUsername;
  final void Function()? onGoToUpdateEmail;
  final void Function()? onEditLocation;
  final void Function()? onEditSummary;
  final void Function(UserUrls)? onUrlChanged;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 42.0,
          vertical: 100.0,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SettingsPageBodyLeft(
              profilePictureUrl: userFirestore.getProfilePicture(),
              onEditPicture: onEditPicture,
              onUploadPicture: onUploadPicture,
              urls: userFirestore.urls,
              onUrlChanged: onUrlChanged,
            ),
            SettingsPageBodyRight(
              userFirestore: userFirestore,
              onEditLocation: onEditLocation,
              onEditSummary: onEditSummary,
              onGoToDeleteAccount: onGoToDeleteAccount,
              onGoToUpdateEmail: onGoToUpdateEmail,
              onGoToUpdatePasssword: onGoToUpdatePasssword,
              onGoToUpdateUsername: onGoToUpdateUsername,
            ),
          ],
        ),
      ),
    );
  }
}