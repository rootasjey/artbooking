import 'package:artbooking/components/animations/fade_in_x.dart';
import 'package:artbooking/screens/settings/settings_page_avatar.dart';
import 'package:artbooking/screens/settings/settings_page_delete_account_button.dart';
import 'package:artbooking/screens/settings/settings_page_email_button.dart';
import 'package:artbooking/screens/settings/settings_page_update_password_button.dart';
import 'package:artbooking/screens/settings/settings_page_update_username_button.dart';
import 'package:flutter/material.dart';
import 'package:supercharged_dart/supercharged_dart.dart';

class SettingsPageAccount extends StatelessWidget {
  const SettingsPageAccount({
    Key? key,
    this.isAuthenticated = false,
    required this.email,
    required this.username,
    required this.onGoToUpdateEmail,
    required this.profilePicture,
    required this.onUploadProfilePicture,
    required this.onTapProfilePicture,
    required this.onGoToUpdatePassword,
    required this.onGoToUpdateUsername,
    required this.onGoToDeleteAccount,
  }) : super(key: key);

  final bool isAuthenticated;
  final String email;
  final String username;
  final String profilePicture;
  final VoidCallback onGoToUpdateEmail;
  final VoidCallback onUploadProfilePicture;
  final VoidCallback onTapProfilePicture;
  final VoidCallback onGoToUpdatePassword;
  final VoidCallback onGoToUpdateUsername;
  final VoidCallback onGoToDeleteAccount;

  @override
  Widget build(BuildContext context) {
    if (isAuthenticated) {
      return Column(
        children: [
          SettingsPageAvatar(
            profilePicture: profilePicture,
            onUploadProfilePicture: onUploadProfilePicture,
            onTapProfilePicture: onTapProfilePicture,
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 80.0),
            child: Wrap(
              spacing: 15.0,
              children: <Widget>[
                FadeInX(
                  delay: 0.milliseconds,
                  beginX: 50.0,
                  child: SettingsPageUpdatePasswordButton(
                    onTap: onGoToUpdatePassword,
                  ),
                ),
                FadeInX(
                  delay: 100.milliseconds,
                  beginX: 50.0,
                  child: SettingsPageDeleteAccountButton(
                    onTap: onGoToDeleteAccount,
                  ),
                )
              ],
            ),
          ),
          SettingsPageUpdateUsernameButton(
            username: username,
            onPressed: onGoToUpdateUsername,
          ),
          Padding(padding: const EdgeInsets.only(bottom: 24.0)),
          SettingsPageEmailButton(
            email: email,
            onPressed: onGoToUpdateEmail,
          ),
        ],
      );
    }

    return Container();
  }
}
