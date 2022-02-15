import 'package:artbooking/components/avatar/adaptive_user_avatar.dart';
import 'package:artbooking/components/popup_menu/popup_menu_item_icon.dart';
import 'package:artbooking/router/locations/dashboard_location.dart';
import 'package:artbooking/router/locations/home_location.dart';
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
        onSelected: (String path) async {
          if (path == 'signout') {
            onSignOut();
            return;
          }

          Beamer.of(context, root: true).beamToNamed(path);
        },
        itemBuilder: itemBuilder,
      ),
    );
  }

  List<PopupMenuEntry<String>> itemBuilder(
    BuildContext context,
  ) {
    final Color iconColor = Colors.black87;

    final lastHistory = Beamer.of(context).beamingHistory.last;
    final currentPathLocation = lastHistory.state.routeInformation.location;
    final bool pathIsDashboard = currentPathLocation == DashboardLocation.route;
    final bool pathIsHome = currentPathLocation == HomeLocation.route;

    return [
      if (compact) ...[
        PopupMenuItemIcon(
          icon: Icon(UniconsLine.search, color: iconColor),
          textLabel: "search".tr(),
          value: SearchLocation.route,
        ),
      ],
      if (!pathIsHome)
        PopupMenuItemIcon(
          icon: Icon(UniconsLine.home, color: iconColor),
          textLabel: "home".tr(),
          value: HomeLocation.route,
        ),
      if (!pathIsDashboard)
        PopupMenuItemIcon(
          icon: Icon(UniconsLine.window_maximize, color: iconColor),
          textLabel: "dashboard".tr(),
          value: DashboardLocationContent.route,
        ),
      PopupMenuItemIcon(
        icon: Icon(UniconsLine.setting, color: iconColor),
        textLabel: "settings".tr(),
        value: DashboardLocationContent.settingsRoute,
      ),
      PopupMenuItemIcon(
        icon: Icon(UniconsLine.sign_left, color: iconColor),
        textLabel: "signout".tr(),
        value: "signout",
      ),
    ];
  }
}
