import 'package:artbooking/components/side_menu_item.dart';
import 'package:artbooking/components/underlined_button.dart';
import 'package:artbooking/components/upload_window.dart';
import 'package:artbooking/state/upload_manager.dart';
import 'package:artbooking/router/app_router.gr.dart';
import 'package:artbooking/state/colors.dart';
import 'package:artbooking/utils/constants.dart';
import 'package:artbooking/utils/fonts.dart';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _sideMenuItems = <SideMenuItem>[
    SideMenuItem(
      index: 0,
      iconData: UniconsLine.chart_pie,
      label: 'Activity',
      hoverColor: Colors.red,
    ),
    SideMenuItem(
      index: 1,
      iconData: UniconsLine.picture,
      label: 'Illustrations',
      hoverColor: Colors.red,
    ),
    SideMenuItem(
      index: 2,
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
      index: 3,
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
    return AutoTabsScaffold(
      routes: const [
        MyActivityPageRoute(),
        DashIllustrationsRouter(),
        DashBooksRouter(),
        DashSettingsRouter(),
      ],
      builder: (context, child, animation) {
        return Material(
          child: Stack(
            children: [
              Row(
                children: [
                  buildSidePanel(context, context.tabsRouter),
                  Expanded(
                    child: Material(
                      elevation: 6.0,
                      child: child,
                    ),
                  ),
                ],
              ),
              Positioned(
                left: 16.0,
                bottom: 16.0,
                child: UploadWindow(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildSidePanel(BuildContext context, TabsRouter tabsRouter) {
    if (MediaQuery.of(context).size.width < Constants.maxMobileWidth) {
      return Container();
    }

    return Container(
      color: stateColors.lightBackground,
      width: 300.0,
      child: Stack(
        children: <Widget>[
          CustomScrollView(
            slivers: <Widget>[
              topSidePanel(),
              bodySidePanel(tabsRouter),
            ],
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

  Widget bodySidePanel(TabsRouter tabsRouter) {
    return SliverPadding(
      padding: const EdgeInsets.only(
        left: 20.0,
        right: 20.0,
      ),
      sliver: SliverList(
          delegate: SliverChildListDelegate.fixed(
        _sideMenuItems.map((item) {
          Color color = stateColors.foreground.withOpacity(0.6);
          Color textColor = stateColors.foreground.withOpacity(0.4);
          FontWeight fontWeight = FontWeight.w600;

          if (tabsRouter.activeIndex == item.index) {
            color = item.hoverColor;
            textColor = stateColors.foreground.withOpacity(0.6);
            fontWeight = FontWeight.w700;
          }

          return Padding(
            padding: const EdgeInsets.only(
              left: 24.0,
              top: 32.0,
            ),
            child: UnderlinedButton(
              leading: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Icon(
                  item.iconData,
                  color: color,
                ),
              ),
              child: Text(
                item.label,
                style: FontsUtils.mainStyle(
                  color: textColor,
                  fontSize: 16.0,
                  fontWeight: fontWeight,
                ),
              ),
              onTap: () {
                tabsRouter.setActiveIndex(item.index);
              },
            ),
          );
        }).toList(),
      )),
    );
  }

  Widget topSidePanel() {
    return SliverPadding(
      padding: const EdgeInsets.only(
        top: 40.0,
        bottom: 50.0,
      ),
      sliver: SliverList(
        delegate: SliverChildListDelegate.fixed([
          IconButton(
            tooltip: "home".tr(),
            onPressed: () => context.router.navigate(HomePageRoute()),
            icon: Opacity(
              opacity: 0.6,
              child: Icon(UniconsLine.home),
            ),
          ),
        ]),
      ),
    );
  }

  Widget fabSidePanel() {
    return Positioned(
      left: 40.0,
      bottom: 20.0,
      child: ElevatedButton(
        onPressed: () {
          appUploadManager.pickImage(context);
        },
        style: ElevatedButton.styleFrom(
          primary: stateColors.primary,
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
    );
  }
}
