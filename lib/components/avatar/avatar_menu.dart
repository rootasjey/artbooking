import 'package:artbooking/components/avatar/adaptive_user_avatar.dart';
import 'package:artbooking/components/popup_menu_item_icon.dart';
import 'package:artbooking/router/locations/dashboard_location.dart';
import 'package:artbooking/router/locations/search_location.dart';
import 'package:beamer/beamer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class AvatarMenu extends StatelessWidget {
  const AvatarMenu({
    Key? key,
    this.padding = EdgeInsets.zero,
    this.compact = false,
    this.avatarURL = '',
    this.avatarInitials = '',
    required this.onSignOut,
  }) : super(key: key);

  final bool compact;
  final EdgeInsets padding;

  /// If set, this will take priority over [avatarInitials] property.
  final String avatarURL;

  /// Show initials letters if [avatarURL] is empty.
  final String avatarInitials;

  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: PopupMenuButton<String>(
        icon: Material(
          elevation: 4.0,
          shape: CircleBorder(),
          child: AdaptiveUserAvatar(
            avatarURL: avatarURL,
            initials: avatarInitials,
          ),
        ),
        onSelected: (uri) async {
          if (uri == 'signout') {
            onSignOut();
            return;
          }

          Beamer.of(context).beamToNamed(uri);
        },
        itemBuilder: itemBuilder,
      ),
    );
  }

  List<PopupMenuEntry<String>> itemBuilder(
    BuildContext context,
  ) {
    final Color iconColor = Colors.black87;

    return [
      if (compact) ...[
        PopupMenuItemIcon(
          icon: Icon(UniconsLine.plus, color: iconColor),
          textLabel: "upload".tr(),
          value: '/dashboard',
        ),
        PopupMenuItemIcon(
          icon: Icon(UniconsLine.search, color: iconColor),
          textLabel: "search".tr(),
          value: SearchLocation.route,
        ),
      ],
      PopupMenuItemIcon(
        icon: Icon(UniconsLine.window_section, color: iconColor),
        textLabel: "dashboard".tr(),
        value: DashboardLocationContent.route,
      ),
      PopupMenuItemIcon(
        icon: Icon(UniconsLine.chart_pie, color: iconColor),
        textLabel: "statistics_my".tr(),
        value: DashboardLocationContent.statisticsRoute,
      ),
      PopupMenuItemIcon(
        icon: Icon(UniconsLine.picture, color: iconColor),
        textLabel: "illustrations_my".tr(),
        value: DashboardLocationContent.illustrationsRoute,
      ),
      PopupMenuItemIcon(
        icon: Icon(UniconsLine.book_alt, color: iconColor),
        textLabel: "books_my".tr(),
        value: DashboardLocationContent.booksRoute,
      ),
      PopupMenuItemIcon(
        icon: Icon(UniconsLine.user, color: iconColor),
        textLabel: "profile_my".tr(),
        value: '/dashboard/profile',
      ),
      PopupMenuItemIcon(
        icon: Icon(UniconsLine.sign_left, color: iconColor),
        textLabel: "signout".tr(),
        value: 'signout',
      ),
    ];
  }
}
