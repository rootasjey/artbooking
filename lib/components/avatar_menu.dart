import 'package:artbooking/components/popup_menu_item_icon.dart';
import 'package:artbooking/router/locations/dashboard_location.dart';
import 'package:artbooking/router/locations/search_location.dart';
import 'package:artbooking/state/colors.dart';
import 'package:artbooking/state/user.dart';
import 'package:beamer/beamer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class AvatarMenu extends StatelessWidget {
  final bool isSmall;
  final EdgeInsets padding;

  const AvatarMenu({
    Key? key,
    this.isSmall = false,
    this.padding = EdgeInsets.zero,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final arrStr = stateUser.username!.split(' ');
    String initials = '';

    if (arrStr.length > 0) {
      initials = arrStr.length > 1
          ? arrStr.reduce((value, element) => value + element.substring(1))
          : arrStr.first;

      if (initials.isNotEmpty) {
        initials = initials.substring(0, 1);
      }
    }

    return Padding(
      padding: padding,
      child: PopupMenuButton<String>(
        icon: Material(
          elevation: 4.0,
          shape: CircleBorder(),
          child: CircleAvatar(
            backgroundColor: stateColors.lightBackground,
            radius: 20.0,
            backgroundImage: NetworkImage(stateUser.userFirestore.getPP()),
          ),
        ),
        onSelected: (route) {
          // if (route.routeName == SignOutRoute.name) {
          //   stateUser.signOut(context: context);
          //   return;
          // }

          context.beamToNamed(route);
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
      if (isSmall) ...[
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
        value: DashboardContentLocation.route,
      ),
      PopupMenuItemIcon(
        icon: Icon(UniconsLine.chart_pie, color: iconColor),
        textLabel: "statistics_my".tr(),
        value: DashboardContentLocation.statisticsRoute,
      ),
      PopupMenuItemIcon(
        icon: Icon(UniconsLine.picture, color: iconColor),
        textLabel: "illustrations_my".tr(),
        value: DashboardContentLocation.illustrationsRoute,
      ),
      PopupMenuItemIcon(
        icon: Icon(UniconsLine.book_alt, color: iconColor),
        textLabel: "books_my".tr(),
        value: DashboardContentLocation.booksRoute,
      ),
      PopupMenuItemIcon(
        icon: Icon(UniconsLine.user, color: iconColor),
        textLabel: "profile_my".tr(),
        value: '/dashboard/profile',
      ),
      PopupMenuItemIcon(
        icon: Icon(UniconsLine.sign_left, color: iconColor),
        textLabel: "signout".tr(),
        value: '/dashboard',
      ),
    ];
  }
}
