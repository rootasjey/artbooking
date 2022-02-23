import 'package:artbooking/components/application_bar/application_bar_search_button.dart';
import 'package:artbooking/components/avatar/avatar_menu.dart';
import 'package:artbooking/components/application_bar/application_bar_upload_button.dart';
import 'package:artbooking/components/application_bar/application_bar_lang_button.dart';
import 'package:flutter/material.dart';

class ApplicationBarAuthUser extends StatelessWidget {
  const ApplicationBarAuthUser({
    Key? key,
    required this.onSignOut,
    this.compact = false,
    this.trailing = const [],
    this.avatarInitials = '',
    this.avatarURL = '',
    this.showSearch = false,
  }) : super(key: key);

  final bool showSearch;
  final bool compact;
  final List<Widget> trailing;

  /// If set, this will take priority over [avatarInitials] property.
  final String avatarURL;

  /// Show initials letters if [avatarURL] is empty.
  final String avatarInitials;

  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0, right: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (showSearch) ApplicationBarSearchButton(),
          ApplicationBarUploadButton(),
          if (!compact) ApplicationBarLangButton(),
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
