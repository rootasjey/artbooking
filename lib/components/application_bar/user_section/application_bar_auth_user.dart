import 'package:artbooking/components/application_bar/application_bar_search_button.dart';
import 'package:artbooking/components/avatar/avatar_menu.dart';
import 'package:artbooking/components/application_bar/application_bar_upload_button.dart';
import 'package:artbooking/components/application_bar/application_bar_lang_button.dart';
import 'package:flutter/material.dart';

class ApplicationBarAuthUser extends StatelessWidget {
  const ApplicationBarAuthUser({
    Key? key,
    required this.onSignOut,
    this.isMobileSize = false,
    this.trailing = const [],
    this.avatarInitials = "",
    this.avatarURL = "",
    this.hideSearch = false,
    this.margin = const EdgeInsets.only(top: 5.0, right: 30.0),
  }) : super(key: key);

  /// If true, will show search icon button.
  final bool hideSearch;

  /// Will hide some elements if true.
  final bool isMobileSize;

  /// Spacing around this widget.
  final EdgeInsets margin;

  /// List of widgets to display at the end of the row.
  final List<Widget> trailing;

  /// If set, this will take priority over [avatarInitials] property.
  final String avatarURL;

  /// Show initials letters if [avatarURL] is empty.
  final String avatarInitials;

  /// Callback fired to disconnect the current authenticated user.
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (!hideSearch) ApplicationBarSearchButton(),
          ApplicationBarUploadButton(),
          if (!isMobileSize) ApplicationBarLangButton(),
          ...trailing,
          AvatarMenu(
            isMobileSize: isMobileSize,
            onSignOut: onSignOut,
            avatarInitials: avatarInitials,
            avatarURL: avatarURL,
            padding: const EdgeInsets.only(
              left: 12.0,
            ),
          ),
        ],
      ),
    );
  }
}
