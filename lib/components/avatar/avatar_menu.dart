import 'package:artbooking/components/avatar/adaptive_user_avatar.dart';
import 'package:artbooking/components/popup_menu/popup_menu_icon.dart';
import 'package:artbooking/components/popup_menu/popup_menu_item_icon.dart';
import 'package:artbooking/router/locations/atelier_location.dart';
import 'package:artbooking/router/locations/home_location.dart';
import 'package:beamer/beamer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class AvatarMenu extends StatelessWidget {
  const AvatarMenu({
    Key? key,
    this.padding = EdgeInsets.zero,
    this.isMobileSize = false,
    this.avatarURL = '',
    this.avatarInitials = '',
    required this.onSignOut,
  }) : super(key: key);

  /// If true, this widget should adapt to small screen size.
  final bool isMobileSize;

  /// This widget's margin.
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6.0),
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
    final bool pathIsDashboard = currentPathLocation == AtelierLocation.route;
    final bool pathIsHome = currentPathLocation == HomeLocation.route;

    return [
      if (!pathIsHome)
        PopupMenuItemIcon(
          delay: Duration(milliseconds: 0),
          icon: PopupMenuIcon(UniconsLine.home, color: iconColor),
          textLabel: "home".tr(),
          value: HomeLocation.route,
        ),
      if (!pathIsDashboard)
        PopupMenuItemIcon(
          delay: Duration(milliseconds: 25),
          icon: PopupMenuIcon(UniconsLine.ruler_combined, color: iconColor),
          textLabel: "atelier".tr(),
          value: AtelierLocationContent.route,
        ),
      PopupMenuItemIcon(
        delay: Duration(milliseconds: 50),
        icon: PopupMenuIcon(UniconsLine.setting, color: iconColor),
        textLabel: "settings".tr(),
        value: AtelierLocationContent.settingsRoute,
      ),
      PopupMenuItemIcon(
        delay: Duration(milliseconds: 75),
        icon: PopupMenuIcon(UniconsLine.sign_left, color: iconColor),
        textLabel: "signout".tr(),
        value: "signout",
      ),
    ];
  }
}
