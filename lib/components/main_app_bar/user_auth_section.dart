import 'package:artbooking/components/avatar/avatar_menu.dart';
import 'package:artbooking/components/main_app_bar/add_button.dart';
import 'package:artbooking/components/main_app_bar/brightness_button.dart';
import 'package:artbooking/components/main_app_bar/lang_button.dart';
import 'package:flutter/material.dart';

class UserAuthSection extends StatelessWidget {
  const UserAuthSection({
    Key? key,
    this.compact = false,
    this.trailing = const [],
    this.avatarInitials = '',
    this.avatarURL = '',
    required this.onSignOut,
  }) : super(key: key);

  final bool compact;
  final List<Widget> trailing;

  /// If set, this will take priority over [avatarInitials] property.
  final String avatarURL;

  /// Show initials letters if [avatarURL] is empty.
  final String avatarInitials;

  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        top: 5.0,
        right: 10.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          UploadButton(),
          BrightnessButton(),
          if (!compact) LangButton(),
          ...trailing,
          AvatarMenu(
            compact: compact,
            onSignOut: onSignOut,
            avatarInitials: avatarInitials,
            avatarURL: avatarURL,
            padding: const EdgeInsets.only(
              left: 12.0,
              right: 20.0,
            ),
          ),
        ],
      ),
    );
  }
}
