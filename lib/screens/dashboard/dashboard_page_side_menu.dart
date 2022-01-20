import 'package:artbooking/components/buttons/text_icon_button.dart';
import 'package:artbooking/types/side_menu_item.dart';
import 'package:artbooking/globals/app_state.dart';
import 'package:artbooking/router/locations/dashboard_location.dart';
import 'package:artbooking/router/locations/home_location.dart';
import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/user/user_firestore.dart';
import 'package:beamer/beamer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supercharged/supercharged.dart';
import 'package:unicons/unicons.dart';

/// User's dashboard side menu.
class DashboardPageSideMenu extends ConsumerStatefulWidget {
  const DashboardPageSideMenu({
    Key? key,
    required this.beamerKey,
  }) : super(key: key);

  final GlobalKey<BeamerState> beamerKey;

  @override
  _DashboardSideMenuState createState() => _DashboardSideMenuState();
}

class _DashboardSideMenuState extends ConsumerState<DashboardPageSideMenu> {
  late BeamerDelegate _beamerDelegate;

  /// True if the side menu is expanded showing icons and labels.
  /// If false, the side menu shows only icon.
  /// Default to true.
  bool _isExpanded = true;

  @override
  void initState() {
    super.initState();

    _isExpanded = Utilities.storage.getDashboardSideMenuExpanded();

    // NOTE: Beamer state isn't ready on 1st frame
    // probably because [SidePanelMenu] appears before the Beamer widget.
    // So we use [addPostFrameCallback] to access the state in the next frame.
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      final BeamerState? currentState = widget.beamerKey.currentState;

      if (currentState != null) {
        _beamerDelegate = currentState.routerDelegate;
        _beamerDelegate.addListener(_setStateListener);
      }
    });
  }

  @override
  void dispose() {
    _beamerDelegate.removeListener(_setStateListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (Utilities.size.isMobileSize(context)) {
      return Container();
    }

    return Material(
      color: Theme.of(context).backgroundColor,
      child: AnimatedContainer(
        duration: 500.milliseconds,
        curve: Curves.easeOutExpo,
        width: _isExpanded ? 300.0 : 70.0,
        child: Stack(
          children: [
            OverflowBox(
              minWidth: 40.0,
              maxWidth: 300.0,
              alignment: Alignment.topLeft,
              child: CustomScrollView(
                slivers: <Widget>[
                  topSidePanel(),
                  bodySidePanel(),
                ],
              ),
            ),
            toggleExpandButton(),
          ],
        ),
      ),
    );
  }

  Widget bodySidePanel() {
    final UserFirestore? userFirestore =
        ref.watch(AppState.userProvider).firestoreUser;

    bool isAdmin = false;

    if (userFirestore != null) {
      isAdmin = userFirestore.rights.isAdmin;
    }

    return SliverPadding(
      padding: EdgeInsets.only(
        left: _isExpanded ? 20.0 : 16.0,
        right: 20.0,
      ),
      sliver: SliverList(
          delegate: SliverChildListDelegate.fixed(
        getItemList(isAdmin: isAdmin).map((sidePanelItem) {
          final Color foregroundColor =
              Theme.of(context).textTheme.bodyText1?.color ?? Colors.white;

          Color color = foregroundColor.withOpacity(0.6);
          Color textColor = foregroundColor.withOpacity(0.4);
          FontWeight fontWeight = FontWeight.w600;

          final bool pathMatch = context
                  .currentBeamLocation.state.routeInformation.location
                  ?.contains(sidePanelItem.routePath) ??
              false;

          if (pathMatch) {
            color = sidePanelItem.hoverColor;
            textColor = foregroundColor.withOpacity(0.6);
            fontWeight = FontWeight.w700;
          }

          return Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.only(
                left: _isExpanded ? 24.0 : 0.0,
                top: 32.0,
              ),
              child: TextButtonIcon(
                compact: !_isExpanded,
                tooltip: sidePanelItem.label,
                leading: Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Icon(
                    sidePanelItem.iconData,
                    color: color,
                  ),
                ),
                child: Text(
                  sidePanelItem.label,
                  style: Utilities.fonts.style(
                    color: textColor,
                    fontSize: 16.0,
                    fontWeight: fontWeight,
                  ),
                ),
                onTap: () {
                  context.beamToNamed(sidePanelItem.routePath);
                  setState(() {});
                },
              ),
            ),
          );
        }).toList(),
      )),
    );
  }

  Widget toggleExpandButton() {
    return Positioned(
      bottom: 24.0,
      left: _isExpanded ? 32.0 : 16.0,
      child: Opacity(
        opacity: 0.6,
        child: IconButton(
          tooltip: _isExpanded ? "collapse".tr() : "expand".tr(),
          icon: _isExpanded
              ? Icon(UniconsLine.left_arrow_from_left)
              : Icon(UniconsLine.arrow_from_right),
          onPressed: _toggleSideMenu,
        ),
      ),
    );
  }

  Widget topSidePanel() {
    return SliverPadding(
      padding: EdgeInsets.only(
        top: 40.0,
        bottom: 50.0,
        left: _isExpanded ? 0.0 : 16.0,
      ),
      sliver: SliverList(
        delegate: SliverChildListDelegate.fixed([
          Column(
            crossAxisAlignment: _isExpanded
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: [
              IconButton(
                tooltip: "home".tr(),
                onPressed: () {
                  Beamer.of(context, root: true)
                      .beamToNamed(HomeLocation.route);
                },
                icon: Opacity(
                  opacity: 0.6,
                  child: Icon(UniconsLine.home),
                ),
              ),
            ],
          ),
        ]),
      ),
    );
  }

  List<SideMenuItem> getItemList({required bool isAdmin}) {
    return [
      ...getBaseItemList(),
      if (isAdmin) ...getAdminItemList(),
    ];
  }

  List<SideMenuItem> getBaseItemList() {
    return [
      SideMenuItem(
        iconData: UniconsLine.chart_pie,
        label: "statistics".tr(),
        hoverColor: Constants.colors.activity,
        routePath: DashboardLocationContent.statisticsRoute,
      ),
      SideMenuItem(
        iconData: UniconsLine.picture,
        label: "illustrations".tr(),
        hoverColor: Constants.colors.illustrations,
        routePath: DashboardLocationContent.illustrationsRoute,
      ),
      SideMenuItem(
        iconData: UniconsLine.book_alt,
        label: "books".tr(),
        hoverColor: Constants.colors.books,
        routePath: DashboardLocationContent.booksRoute,
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
        iconData: UniconsLine.setting,
        label: "settings".tr(),
        hoverColor: Constants.colors.settings,
        routePath: DashboardLocationContent.settingsRoute,
      ),
      SideMenuItem(
        iconData: UniconsLine.document_info,
        label: "licenses".tr(),
        hoverColor: Colors.amber.shade800,
        routePath: DashboardLocationContent.licensesRoute,
      ),
    ];
  }

  List<SideMenuItem> getAdminItemList() {
    return [];
  }

  void _setStateListener() => setState(() {});

  void _toggleSideMenu() {
    setState(() {
      _isExpanded = !_isExpanded;
      Utilities.storage.setDashboardSideMenuExpanded(_isExpanded);
    });
  }
}
