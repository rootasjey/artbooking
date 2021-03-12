import 'package:artbooking/components/desktop_app_bar.dart';
import 'package:artbooking/components/side_menu_item.dart';
import 'package:artbooking/state/upload_manager.dart';
import 'package:artbooking/router/app_router.gr.dart';
import 'package:artbooking/state/colors.dart';
import 'package:artbooking/utils/constants.dart';
import 'package:artbooking/utils/fonts.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _sideMenuItems = <SideMenuItem>[
    SideMenuItem(
      destination: MyActivityRoute(),
      iconData: UniconsLine.chart_pie,
      label: 'Activity',
      hoverColor: Colors.red,
    ),
    SideMenuItem(
      destination: MyIllustrationsRoute(),
      iconData: UniconsLine.picture,
      label: 'Illustrations',
      hoverColor: Colors.red,
    ),
    SideMenuItem(
      destination: MyBooksDeepRoute(),
      iconData: UniconsLine.book_alt,
      label: 'Books',
      hoverColor: Colors.blue.shade700,
    ),
    // SideMenuItem(
    //   destination: MyGalleriesDeepRoute(),
    //   iconData: UniconsLine.images,
    //   label: 'Galleries',
    //   hoverColor: Colors.pink.shade200,
    // ),
    // SideMenuItem(
    //   destination: MyChallengesDeepRoute(),
    //   iconData: UniconsLine.dumbbell,
    //   label: 'Challenges',
    //   hoverColor: Colors.green,
    // ),
    // SideMenuItem(
    //   destination: MyContestsDeepRoute(),
    //   iconData: UniconsLine.trophy,
    //   label: 'Contests',
    //   hoverColor: Colors.yellow.shade800,
    // ),
    SideMenuItem(
      destination: DashboardSettingsDeepRoute(
        children: [DashboardSettingsRoute()],
      ),
      iconData: UniconsLine.setting,
      label: 'Settings',
      hoverColor: Colors.blueGrey,
    ),
  ];

  @override
  void initState() {
    super.initState();
    // tryAddAdminPage();
  }

  @override
  Widget build(context) {
    return AutoRouter(
      builder: (context, child) {
        return Material(
          child: Row(
            children: [
              buildSideMenu(context),
              Expanded(child: child),
            ],
          ),
        );
      },
    );
  }

  Widget buildSideMenu(BuildContext context) {
    final router = context.router;

    if (MediaQuery.of(context).size.width < Constants.maxMobileWidth) {
      return Container();
    }

    return Container(
      foregroundDecoration: BoxDecoration(
        color: Color.fromRGBO(0, 0, 0, 0.05),
      ),
      width: 300.0,
      child: Stack(
        children: <Widget>[
          CustomScrollView(
            slivers: <Widget>[
              SliverPadding(
                padding: const EdgeInsets.only(
                  top: 20.0,
                  bottom: 50.0,
                ),
                sliver: DesktopAppBar(
                  showAppIcon: false,
                  automaticallyImplyLeading: false,
                  leftPaddingFirstDropdown: 0,
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                ),
                sliver: SliverList(
                    delegate: SliverChildListDelegate.fixed(
                  _sideMenuItems.map((item) {
                    Color color = stateColors.foreground.withOpacity(0.6);
                    Color textColor = stateColors.foreground.withOpacity(0.6);
                    FontWeight fontWeight = FontWeight.w400;

                    if (item.destination.fullPath ==
                        router.current?.route?.fullPath) {
                      color = item.hoverColor;
                      textColor = stateColors.foreground;
                      fontWeight = FontWeight.w600;
                    }

                    return ListTile(
                      leading: Icon(
                        item.iconData,
                        color: color,
                      ),
                      title: Text(
                        item.label,
                        style: FontsUtils.mainStyle(
                          color: textColor,
                          fontWeight: fontWeight,
                        ),
                      ),
                      onTap: () {
                        if (item.destination.routeName == 'AdminDeepRoute') {
                          item.destination.show(context);
                          return;
                        }

                        router.navigate(item.destination);
                      },
                    );
                  }).toList(),
                )),
              ),
            ],
          ),
          Positioned(
            left: 40.0,
            bottom: 20.0,
            child: ElevatedButton(
              onPressed: () {
                appUploadManager.pickImage(context);
              },
              style: ElevatedButton.styleFrom(
                primary: stateColors.accent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(30.0),
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12.0,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: 160.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(UniconsLine.upload, color: Colors.white),
                      Padding(padding: const EdgeInsets.only(left: 10.0)),
                      Text(
                        'Upload',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void tryAddAdminPage() async {
    // if (!stateUser.canManageQuotes) {
    //   return;
    // }

    // _sideMenuItems.addAll([
    //   SideMenuItem(
    //     destination: AdminDeepRoute(
    //       children: [
    //         AdminTempDeepRoute(
    //           children: [
    //             AdminTempQuotesRoute(),
    //           ],
    //         )
    //       ],
    //     ),
    //     iconData: UniconsLine.clock_two,
    //     label: 'Admin Temp Quotes',
    //     hoverColor: Colors.red,
    //   ),
    //   SideMenuItem(
    //     destination: AdminDeepRoute(children: [QuotidiansRoute()]),
    //     iconData: UniconsLine.sunset,
    //     label: 'Quotidians',
    //     hoverColor: Colors.red,
    //   ),
    // ]);
  }
}
