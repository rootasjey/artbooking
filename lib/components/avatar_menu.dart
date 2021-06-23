import 'package:artbooking/router/app_router.gr.dart';
import 'package:artbooking/state/colors.dart';
import 'package:artbooking/state/user.dart';
import 'package:artbooking/utils/fonts.dart';
import 'package:auto_route/auto_route.dart';
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
      child: PopupMenuButton<PageRouteInfo>(
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
          if (route.routeName == SignOutRoute.name) {
            stateUser.signOut(context: context);
            return;
          }

          context.router.root.push(route);
        },
        itemBuilder: itemBuilder,
      ),
    );
  }

  List<PopupMenuEntry<PageRouteInfo<dynamic>>> itemBuilder(
      BuildContext context) {
    return [
      if (isSmall) ...[
        PopupMenuItem(
          value: DashboardPageRoute(
            children: [],
          ),
          child: ListTile(
            leading: Icon(UniconsLine.plus),
            title: Text(
              "upload".tr(),
              style: FontsUtils.mainStyle(
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
        PopupMenuItem(
          value: SearchPageRoute(),
          child: ListTile(
            leading: Icon(UniconsLine.search),
            title: Text(
              "search".tr(),
              style: FontsUtils.mainStyle(
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ],
      PopupMenuItem(
        value: DashboardPageRoute(
          children: [MyActivityPageRoute()],
        ),
        child: ListTile(
          leading: Icon(UniconsLine.chart_pie),
          title: Text(
            "activity_my".tr(),
            style: FontsUtils.mainStyle(
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
      PopupMenuItem(
        value: DashboardPageRoute(children: [
          DashIllustrationsRouter(
            children: [
              MyIllustrationsPageRoute(),
            ],
          )
        ]),
        child: ListTile(
          leading: Icon(UniconsLine.picture),
          title: Text(
            "illustrations_my".tr(),
            style: FontsUtils.mainStyle(
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
      PopupMenuItem(
        value: DashboardPageRoute(children: [
          DashBooksRouter(
            children: [
              MyBooksPageRoute(),
            ],
          )
        ]),
        child: ListTile(
          leading: Icon(UniconsLine.book_alt),
          title: Text(
            "books_my".tr(),
            style: FontsUtils.mainStyle(
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
      PopupMenuItem(
        value: DashboardPageRoute(children: [DashProfileRouter()]),
        child: ListTile(
          leading: Icon(UniconsLine.user),
          title: Text(
            "profile_my".tr(),
            style: FontsUtils.mainStyle(
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
      PopupMenuItem(
        value: SignOutRoute(),
        child: ListTile(
          leading: Icon(UniconsLine.sign_left),
          title: Text(
            "signout".tr(),
            style: FontsUtils.mainStyle(
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    ];
  }
}
