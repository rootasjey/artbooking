import 'package:artbooking/components/app_icon.dart';
import 'package:artbooking/state/upload_manager.dart';
import 'package:artbooking/router/app_router.gr.dart';
import 'package:artbooking/state/colors.dart';
import 'package:artbooking/state/user.dart';
import 'package:artbooking/types/enums.dart';
import 'package:artbooking/utils/app_storage.dart';
import 'package:artbooking/utils/brightness.dart';
import 'package:artbooking/utils/language.dart';
import 'package:artbooking/utils/navigation_helper.dart';
import 'package:artbooking/utils/snack.dart';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:unicons/unicons.dart';
import 'package:url_launcher/url_launcher.dart';

class DesktopAppBar extends StatefulWidget {
  final bool automaticallyImplyLeading;
  final bool showUserMenu;
  final bool showCloseButton;
  final bool pinned;

  /// Show appication icon if true. Hide it if false. Default tot true.
  final bool showAppIcon;

  /// Control left padding of the first dropdown. Default to 32.0;
  final double leftPaddingFirstDropdown;

  final EdgeInsets padding;

  final Function onTapIconHeader;

  final String title;

  DesktopAppBar({
    this.automaticallyImplyLeading = true,
    this.onTapIconHeader,
    this.padding = EdgeInsets.zero,
    this.pinned = true,
    this.showAppIcon = true,
    this.showCloseButton = false,
    this.showUserMenu = true,
    this.title = '',
    this.leftPaddingFirstDropdown = 32.0,
  });

  @override
  _DesktopAppBarState createState() => _DesktopAppBarState();
}

class _DesktopAppBarState extends State<DesktopAppBar> {
  /// If true, use icon instead of text for PopupMenuButton.
  bool useIconButton = false;
  bool useGroupedDropdown = false;

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constrains) {
        final isNarrow = constrains.crossAxisExtent < 600.0;
        useIconButton = constrains.crossAxisExtent < 1000.0;
        useGroupedDropdown = constrains.crossAxisExtent < 800.0;

        bool showUserMenu = !isNarrow;

        if (widget.showUserMenu != null) {
          showUserMenu = widget.showUserMenu;
        }

        return Observer(
          builder: (_) {
            final userSectionWidgets = <Widget>[];

            if (stateUser.isUserConnected) {
              userSectionWidgets.addAll(getAuthButtons(isNarrow));
            } else {
              userSectionWidgets.addAll(getGuestButtons(isNarrow));
            }

            final mustShowNavBack = widget.automaticallyImplyLeading &&
                context.router.root.stack.length > 1;

            if (mustShowNavBack && constrains.crossAxisExtent < 1100.0) {
              useIconButton = true;
            }

            return SliverAppBar(
              floating: true,
              snap: true,
              pinned: widget.pinned,
              toolbarHeight: 80.0,
              backgroundColor: stateColors.appBackground.withOpacity(1.0),
              automaticallyImplyLeading: false,
              actions: showUserMenu ? userSectionWidgets : [],
              title: Padding(
                padding: widget.padding,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    if (mustShowNavBack)
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 10.0,
                          right: 16.0,
                        ),
                        child: IconButton(
                          color: stateColors.foreground,
                          onPressed: () => context.router.pop(),
                          icon: Icon(UniconsLine.arrow_left),
                        ),
                      ),
                    if (widget.showAppIcon)
                      AppIcon(
                        size: 30.0,
                        padding: const EdgeInsets.only(left: 10.0),
                        onTap: widget.onTapIconHeader,
                      ),
                    Padding(
                      padding: EdgeInsets.only(
                        left: widget.leftPaddingFirstDropdown,
                      ),
                      child: discoverDropdown(),
                    ),
                    if (useGroupedDropdown)
                      groupedDropdown()
                    else
                      ...separateDropdowns(),
                    if (widget.showCloseButton) closeButton(),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Switch from dark to light and vice-versa.
  Widget brightnessButton() {
    IconData iconBrightness = Icons.brightness_auto;
    final autoBrightness = appStorage.getAutoBrightness();

    if (!autoBrightness) {
      final currentBrightness = appStorage.getBrightness();

      iconBrightness = currentBrightness == Brightness.dark
          ? Icons.brightness_2
          : Icons.brightness_low;
    }

    return Padding(
      padding: const EdgeInsets.only(right: 20.0),
      child: PopupMenuButton<String>(
        icon: Icon(
          iconBrightness,
          color: stateColors.foreground.withOpacity(0.6),
        ),
        tooltip: "brightness".tr(),
        onSelected: (value) {
          if (value == 'auto') {
            BrightnessUtils.setAutoBrightness(context);
            return;
          }

          final brightness =
              value == 'dark' ? Brightness.dark : Brightness.light;

          BrightnessUtils.setBrightness(context, brightness);
        },
        itemBuilder: (context) {
          final autoBrightness = appStorage.getAutoBrightness();
          final brightness = autoBrightness ? null : appStorage.getBrightness();

          final primary = stateColors.primary;
          final basic = stateColors.foreground;

          return [
            PopupMenuItem(
              value: 'auto',
              child: ListTile(
                leading: Icon(Icons.brightness_auto),
                title: Text(
                  "auto".tr(),
                  style: TextStyle(
                    color: autoBrightness ? primary : basic,
                  ),
                ),
                trailing: autoBrightness
                    ? Icon(
                        UniconsLine.check,
                        color: primary,
                      )
                    : null,
              ),
            ),
            PopupMenuItem(
              value: 'dark',
              child: ListTile(
                leading: Icon(Icons.brightness_2),
                title: Text(
                  "dark".tr(),
                  style: TextStyle(
                    color: brightness == Brightness.dark ? primary : basic,
                  ),
                ),
                trailing: brightness == Brightness.dark
                    ? Icon(
                        UniconsLine.check,
                        color: primary,
                      )
                    : null,
              ),
            ),
            PopupMenuItem(
              value: 'light',
              child: ListTile(
                leading: Icon(Icons.brightness_5),
                title: Text(
                  "light".tr(),
                  style: TextStyle(
                    color: brightness == Brightness.light ? primary : basic,
                  ),
                ),
                trailing: brightness == Brightness.light
                    ? Icon(
                        UniconsLine.check,
                        color: primary,
                      )
                    : null,
              ),
            ),
          ];
        },
      ),
    );
  }

  Widget closeButton() {
    return IconButton(
      onPressed: context.router.pop,
      color: Theme.of(context).iconTheme.color,
      icon: Icon(UniconsLine.times),
    );
  }

  Widget developersDropdown() {
    return PopupMenuButton(
      tooltip: "developers".tr(),
      child: Opacity(
        opacity: 0.6,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8.0,
            vertical: 5.0,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              useIconButton
                  ? Icon(UniconsLine.processor, color: stateColors.foreground)
                  : Text(
                      "developers".tr(),
                      style: TextStyle(
                        color: stateColors.foreground,
                        fontSize: 16.0,
                      ),
                    ),
              Icon(
                UniconsLine.angle_down,
                color: stateColors.foreground,
              ),
            ],
          ),
        ),
      ),
      itemBuilder: (_) => <PopupMenuEntry<AppBarDevelopers>>[
        developerEntry(
          value: AppBarDevelopers.github,
          icon: Icon(
            UniconsLine.github,
            color: stateColors.foreground.withOpacity(0.6),
          ),
          textData: 'GitHub',
        ),
      ],
      onSelected: (value) {
        switch (value) {
          case AppBarDevelopers.github:
            launch('https://github.com/rootasjey/fig.style');
            break;
          default:
        }
      },
    );
  }

  Widget developerEntry({
    @required Widget icon,
    @required AppBarDevelopers value,
    @required String textData,
  }) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          icon,
          Padding(padding: const EdgeInsets.only(left: 12.0)),
          Text(textData),
        ],
      ),
    );
  }

  Widget discoverDropdown() {
    return PopupMenuButton(
      tooltip: "discover".tr(),
      child: Opacity(
        opacity: 0.6,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8.0,
            vertical: 5.0,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              useIconButton
                  ? Icon(
                      UniconsLine.telescope,
                      color: stateColors.foreground,
                    )
                  : Text(
                      "discover".tr(),
                      style: TextStyle(
                        color: stateColors.foreground,
                        fontSize: 16.0,
                      ),
                    ),
              Icon(
                UniconsLine.angle_down,
                color: stateColors.foreground,
              ),
            ],
          ),
        ),
      ),
      itemBuilder: (_) => <PopupMenuEntry<PageRouteInfo>>[
        discoverEntry(
          value: HomeRoute(),
          icon: Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: Icon(
              UniconsLine.clock,
              color: stateColors.foreground.withOpacity(0.6),
            ),
          ),
          textData: 'recent',
        ),
      ],
      onSelected: (value) {
        context.router.root.push(value);
      },
    );
  }

  Widget discoverEntry({
    @required Widget icon,
    @required PageRouteInfo value,
    @required String textData,
  }) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          icon,
          Padding(padding: const EdgeInsets.only(left: 12.0)),
          Text(textData),
        ],
      ),
    );
  }

  List<Widget> getAuthButtons(bool isNarrow) {
    if (isNarrow) {
      return [userAvatar(isNarrow: isNarrow)];
    }

    return [
      // langButton(),
      brightnessButton(),
      searchButton(),
      newQuoteButton(),
      userAvatar(),
    ];
  }

  Iterable<Widget> getGuestButtons(bool isNarrow) {
    if (isNarrow) {
      return [userSigninMenu()];
    }

    return [
      Padding(
        padding: const EdgeInsets.only(right: 16.0),
        child: Center(
          child: ElevatedButton(
            onPressed: () => context.router.root.push(SigninRoute()),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Text(
                    "signin",
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: Icon(UniconsLine.signout),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      searchButton(),
      brightnessButton(),
      settingsButton(),
    ];
  }

  Widget groupedSectionEntry({
    @required Widget icon,
    @required PageRouteInfo value,
    @required String textData,
  }) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          icon,
          Padding(padding: const EdgeInsets.only(left: 12.0)),
          Text(textData),
        ],
      ),
    );
  }

  Widget groupedDropdown() {
    return PopupMenuButton(
      tooltip: "more".tr(),
      child: Opacity(
        opacity: 0.6,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.more_horiz, color: stateColors.foreground),
              Icon(UniconsLine.angle_down, color: stateColors.foreground),
            ],
          ),
        ),
      ),
      itemBuilder: (_) => <PopupMenuEntry<PageRouteInfo>>[
        groupedSectionEntry(
          value: HomeRoute(),
          icon: Icon(
            UniconsLine.home,
            color: stateColors.foreground.withOpacity(0.6),
          ),
          textData: "home".tr(),
        ),
        PopupMenuDivider(),
        groupedSectionEntry(
          value: GitHubRoute(),
          icon: Icon(
            UniconsLine.github,
            color: stateColors.foreground.withOpacity(0.6),
          ),
          textData: 'GitHub',
        ),
        PopupMenuDivider(),
        groupedSectionEntry(
          value: AboutRoute(),
          icon: Icon(
            UniconsLine.question,
            color: stateColors.foreground.withOpacity(0.6),
          ),
          textData: "about".tr(),
        ),
        groupedSectionEntry(
          value: ContactRoute(),
          icon: Icon(
            UniconsLine.envelope,
            color: stateColors.foreground.withOpacity(0.6),
          ),
          textData: "contact".tr(),
        ),
        groupedSectionEntry(
          value: TosRoute(),
          icon: Icon(
            UniconsLine.keyhole_square,
            color: stateColors.foreground.withOpacity(0.6),
          ),
          textData: "privacy".tr(),
        ),
      ],
      onSelected: (PageRouteInfo pageRouteInfo) {
        if (pageRouteInfo.routeName == 'GitHubRoute') {
          launch('https://github.com/rootasjey/fig.style');
          return;
        }

        context.router.root.push(pageRouteInfo);
      },
    );
  }

  Widget langButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 20.0),
      child: PopupMenuButton<String>(
        tooltip: "language_change".tr(),
        icon: Icon(
          UniconsLine.language,
          color: stateColors.foreground.withOpacity(0.6),
        ),
        onSelected: (newValue) {
          Language.setLang(newValue);

          Snack.s(
            context: context,
            message: "language_changed_success"
                .tr(args: [Language.frontend(newValue)]),
          );
        },
        itemBuilder: (context) => Language.available().map((value) {
          final isSelected = stateUser.lang == value;

          return PopupMenuItem(
            value: value,
            child: ListTile(
              trailing: isSelected ? Icon(UniconsLine.check) : null,
              title: Text(
                Language.frontend(value),
                style: TextStyle(
                  color:
                      isSelected ? stateColors.primary : stateColors.foreground,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget newQuoteButton() {
    return IconButton(
      tooltip: "Upload",
      onPressed: () {
        appUploadManager.pickImage(context);
      },
      color: stateColors.foreground,
      icon: Icon(UniconsLine.upload),
    );
  }

  Widget resourcesDropdown() {
    return PopupMenuButton<PageRouteInfo>(
      tooltip: 'Resources',
      child: Opacity(
        opacity: 0.6,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              useIconButton
                  ? Icon(UniconsLine.books, color: stateColors.foreground)
                  : Text(
                      'resources'.tr(),
                      style: TextStyle(
                        color: stateColors.foreground,
                        fontSize: 16.0,
                      ),
                    ),
              Icon(
                UniconsLine.angle_down,
                color: stateColors.foreground,
              ),
            ],
          ),
        ),
      ),
      itemBuilder: (_) => <PopupMenuEntry<PageRouteInfo>>[
        resourcesEntry(
          value: AboutRoute(),
          icon: Icon(
            UniconsLine.question,
            color: stateColors.foreground.withOpacity(0.6),
          ),
          textData: "about".tr(),
        ),
        resourcesEntry(
          value: ContactRoute(),
          icon: Icon(
            UniconsLine.envelope,
            color: stateColors.foreground.withOpacity(0.6),
          ),
          textData: "contact".tr(),
        ),
        resourcesEntry(
          value: TosRoute(),
          icon: Icon(
            UniconsLine.keyhole_square,
            color: stateColors.foreground.withOpacity(0.6),
          ),
          textData: "privacy".tr(),
        ),
        // PopupMenuDivider(),
        // resourcesEntry(
        //   value: AndroidAppRoute(),
        //   icon: FaIcon(
        //     FontAwesomeIcons.googlePlay,
        //     color: Colors.green,
        //   ),
        //   textData: 'Android app',
        // ),
        // resourcesEntry(
        //   value: IosAppRoute(),
        //   icon: FaIcon(
        //     FontAwesomeIcons.appStoreIos,
        //     color: Colors.blue,
        //   ),
        //   textData: 'iOS app',
        // ),
      ],
      onSelected: (value) {
        // if (value.routeName == AndroidAppRoute.name) {
        //   launch("https://play.google.com/store/apps/"
        //       "details?id=com.outofcontext.app");
        //   return;
        // }
        // if (value.routeName == IosAppRoute.name) {
        //   launch("https://apps.apple.com/us/app/"
        //       "out-of-context/id1516117110?ls=1");
        //   return;
        // }

        context.router.root.push(value);
      },
    );
  }

  Widget resourcesEntry({
    @required Widget icon,
    @required PageRouteInfo value,
    @required String textData,
  }) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          icon,
          Padding(padding: const EdgeInsets.only(left: 12.0)),
          Text(textData),
        ],
      ),
    );
  }

  Widget searchButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: IconButton(
        tooltip: "search".tr(),
        onPressed: () {
          // context.router.root.push(SearchRoute());
        },
        color: stateColors.foreground,
        icon: Icon(
          UniconsLine.search,
          color: stateColors.foreground.withOpacity(0.6),
        ),
      ),
    );
  }

  List<Widget> separateDropdowns() {
    return [
      Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: developersDropdown(),
      ),
      Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: resourcesDropdown(),
      ),
    ];
  }

  Widget settingsButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 60.0),
      child: PopupMenuButton(
        tooltip: "settings".tr(),
        icon: Icon(
          UniconsLine.setting,
          color: stateColors.foreground,
        ),
        itemBuilder: (_) => <PopupMenuEntry<AppBarSettings>>[
          PopupMenuItem(
            value: AppBarSettings.allSettings,
            child: Text("settings_all".tr()),
          ),
          PopupMenuDivider(),
          PopupMenuItem(
            value: AppBarSettings.selectLang,
            enabled: false,
            child: Row(
              children: [
                Icon(
                  UniconsLine.language,
                  color: stateColors.foreground,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                ),
                Text("language".tr()),
              ],
            ),
          ),
          PopupMenuItem(
            value: AppBarSettings.en,
            child: Text('English'),
          ),
          PopupMenuItem(
            value: AppBarSettings.fr,
            child: Text('Français'),
          ),
        ],
        onSelected: (value) {
          switch (value) {
            case AppBarSettings.allSettings:
              context.router.root.push(SettingsRoute());
              break;
            case AppBarSettings.en:
              Language.setLang('en');

              Snack.s(
                context: context,
                message: "language_changed_success"
                    .tr(args: [Language.frontend('en')]),
              );

              break;
            case AppBarSettings.fr:
              Language.setLang('fr');

              Snack.s(
                context: context,
                message: "language_changed_success"
                    .tr(args: [Language.frontend('fr')]),
              );

              break;
            default:
          }
        },
      ),
    );
  }

  Widget signinButton() {
    return ElevatedButton(
      onPressed: () => context.router.root.push(SigninRoute()),
      style: ElevatedButton.styleFrom(
        primary: stateColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(7.0),
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "signin".tr().toUpperCase(),
              style: TextStyle(
                color: Colors.white,
                // fontSize: 13.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget signupButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: TextButton(
        onPressed: () => context.router.root.push(SignupRoute()),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 8.0,
          ),
          child: Text(
            "signup".tr().toUpperCase(),
          ),
        ),
      ),
    );
  }

  Widget userAvatar({bool isNarrow = true}) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 20.0,
        right: 60.0,
      ),
      child: PopupMenuButton<PageRouteInfo>(
        icon: Icon(
          UniconsLine.user_circle,
          color: stateColors.primary,
        ),
        tooltip: "user_menu_show".tr(),
        onSelected: (pageRouteInfo) {
          if (pageRouteInfo.routeName == SignOutRoute.name) {
            stateUser.signOut(
              context: context,
              redirectOnComplete: true,
            );
            return;
          }

          context.router.root.push(pageRouteInfo);
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<PageRouteInfo>>[
          if (isNarrow)
            PopupMenuItem(
              value: DashboardPageRoute(children: [AddIllustrationRoute()]),
              child: ListTile(
                leading: Icon(UniconsLine.upload),
                title: Text(
                  "upload".tr(),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          // const PopupMenuItem(
          //   value: SearchRoute(),
          //   child: ListTile(
          //     leading: Icon(UniconsLine.search),
          //     title: Text(
          //       'Search',
          //       style: TextStyle(fontWeight: FontWeight.bold),
          //     ),
          //   ),
          // ),
          PopupMenuItem(
            value: DashboardPageRoute(children: [MyActivityRoute()]),
            child: ListTile(
              leading: Icon(UniconsLine.chart_pie),
              title: Text(
                "my_activity".tr(),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          PopupMenuItem(
            value: DashboardPageRoute(
              children: [MyIllustrationsRoute()],
            ),
            child: ListTile(
              leading: Icon(UniconsLine.picture),
              title: Text(
                "my_illustrations".tr(),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          PopupMenuItem(
            value: DashboardPageRoute(children: [MyBooksDeepRoute()]),
            child: ListTile(
              leading: Icon(UniconsLine.books),
              title: Text(
                "my_books".tr(),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          PopupMenuItem(
            value: NavigationHelper.getSettingsRoute(),
            child: ListTile(
              leading: Icon(UniconsLine.setting),
              title: Text(
                "settings".tr(),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          PopupMenuItem(
            value: SignOutRoute(),
            child: ListTile(
              leading: Icon(UniconsLine.ship),
              title: Text(
                "signout".tr(),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget userSigninMenu() {
    return PopupMenuButton(
      icon: Icon(Icons.more_vert),
      itemBuilder: (context) => <PopupMenuEntry<PageRouteInfo>>[
        PopupMenuItem(
          value: SigninRoute(),
          child: ListTile(
            leading: Icon(UniconsLine.signout),
            title: Text("signin".tr()),
          ),
        ),
        PopupMenuItem(
          value: SignupRoute(),
          child: ListTile(
            leading: Icon(UniconsLine.user_plus),
            title: Text("signup".tr()),
          ),
        ),
        // PopupMenuItem(
        //   value: SearchRoute(),
        //   child: ListTile(
        //     leading: Icon(UniconsLine.search),
        //     title: Text('Search'),
        //   ),
        // ),
      ],
      onSelected: (pageRouteInfo) {
        context.router.root.navigate(pageRouteInfo);
      },
    );
  }
}
