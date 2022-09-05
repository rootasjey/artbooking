import 'package:artbooking/components/buttons/text_icon_button.dart';
import 'package:artbooking/router/locations/home_location.dart';
import 'package:artbooking/types/side_menu_item.dart';
import 'package:artbooking/globals/app_state.dart';
import 'package:artbooking/router/locations/atelier_location.dart';
import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/user/user_firestore.dart';
import 'package:artbooking/types/user/user_rights.dart';
import 'package:beamer/beamer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicons/unicons.dart';

/// User's atelier side menu.
class AtelierPageSideMenu extends ConsumerStatefulWidget {
  const AtelierPageSideMenu({
    Key? key,
    required this.beamerKey,
  }) : super(key: key);

  final GlobalKey<BeamerState> beamerKey;

  @override
  _DashboardSideMenuState createState() => _DashboardSideMenuState();
}

class _DashboardSideMenuState extends ConsumerState<AtelierPageSideMenu> {
  late BeamerDelegate _beamerDelegate;

  /// True if the side menu is expanded showing icons and labels.
  /// If false, the side menu shows only icon.
  /// Default to true.
  bool _isExpanded = true;

  /// Show a button to scroll down the side panel if true.
  bool _showScrollDownButton = true;

  /// Show a button to scroll up the side panel if true.
  bool _showScrollUpButton = false;

  final double _expandedWidth = 300.0;
  final double _collapsedWidth = 70.0;

  final ScrollController _sidePanelScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _isExpanded = Utilities.storage.getDashboardSideMenuExpanded();

    _sidePanelScrollController.addListener(onScrollPanel);

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
    _sidePanelScrollController.removeListener(onScrollPanel);
    _sidePanelScrollController.dispose();
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
        duration: Duration(milliseconds: 500),
        curve: Curves.easeOutExpo,
        width: _isExpanded ? _expandedWidth : _collapsedWidth,
        child: Stack(
          children: [
            OverflowBox(
              minWidth: 40.0,
              maxWidth: 300.0,
              alignment: Alignment.topLeft,
              child: CustomScrollView(
                controller: _sidePanelScrollController,
                slivers: <Widget>[
                  topSidePanel(),
                  bodySidePanel(),
                  space(),
                ],
              ),
            ),
            scrollUpButton(),
            scrollDownButton(),
            toggleExpandButton(),
          ],
        ),
      ),
    );
  }

  Widget bodySidePanel() {
    final UserFirestore? userFirestore =
        ref.watch(AppState.userProvider).firestoreUser;

    return SliverPadding(
      padding: EdgeInsets.only(
        left: _isExpanded ? 20.0 : 16.0,
        right: 20.0,
        bottom: 100.0,
      ),
      sliver: SliverList(
          delegate: SliverChildListDelegate.fixed(
        getItemList(userFirestore: userFirestore).map(
          (final SideMenuItem sidePanelItem) {
            final Color foregroundColor =
                Theme.of(context).textTheme.bodyText1?.color ?? Colors.white;

            Color color = foregroundColor.withOpacity(0.6);
            Color textColor = foregroundColor.withOpacity(0.4);
            FontWeight fontWeight = FontWeight.w700;

            bool pathMatch = context
                    .currentBeamLocation.state.routeInformation.location
                    ?.contains(sidePanelItem.routePath) ??
                false;

            if (sidePanelItem.routePath == HomeLocation.route) {
              pathMatch = false;
            }

            if (pathMatch) {
              color = sidePanelItem.hoverColor;
              textColor = foregroundColor.withOpacity(0.6);
              fontWeight = FontWeight.w800;
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
                    style: Utilities.fonts.body(
                      color: textColor,
                      fontSize: 16.0,
                      fontWeight: fontWeight,
                    ),
                  ),
                  onTap: () {
                    if (sidePanelItem.routePath ==
                        AtelierLocationContent.profileRoute) {
                      context.beamToNamed(
                        sidePanelItem.routePath,
                        routeState: {
                          "userId": userFirestore?.id ?? "",
                        },
                      );
                    } else if (sidePanelItem.routePath == HomeLocation.route) {
                      Beamer.of(context, root: true).beamToNamed(
                        HomeLocation.route,
                      );
                    } else {
                      context.beamToNamed(sidePanelItem.routePath);
                    }

                    setState(() {});
                  },
                ),
              ),
            );
          },
        ).toList(),
      )),
    );
  }

  Widget scrollDownButton() {
    if (!_showScrollDownButton) {
      return Container();
    }

    final double maxHeight = 76.0;
    final Color color =
        Theme.of(context).textTheme.bodyText2?.color ?? Colors.black;

    return Positioned(
      bottom: 70.0,
      left: 0.0,
      right: 0.0,
      child: Material(
        color: Theme.of(context).backgroundColor,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: _expandedWidth,
            maxHeight: maxHeight,
          ),
          child: OverflowBox(
            maxHeight: maxHeight,
            child: InkWell(
              onTap: () {
                _sidePanelScrollController.animateTo(
                  _sidePanelScrollController.offset + 70.0,
                  duration: Duration(milliseconds: 200),
                  curve: Curves.bounceIn,
                );
              },
              child: Container(
                padding: EdgeInsets.only(
                  top: 24.0,
                  left: 0.0,
                  bottom: 24.0,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: color.withOpacity(0.1),
                      width: 2.0,
                    ),
                  ),
                ),
                child: Tooltip(
                  message: "scroll_down".tr(),
                  child: Icon(UniconsLine.arrow_down),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget scrollUpButton() {
    if (!_showScrollUpButton) {
      return Container();
    }

    final double maxHeight = 76.0;
    final Color color =
        Theme.of(context).textTheme.bodyText2?.color ?? Colors.black;

    if (!_showScrollUpButton) {
      return Container();
    }

    return Positioned(
      top: 0.0,
      left: 0.0,
      right: 0.0,
      child: Material(
        color: Theme.of(context).backgroundColor,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: _expandedWidth,
            maxHeight: maxHeight,
          ),
          child: OverflowBox(
            maxHeight: maxHeight,
            child: InkWell(
              onTap: () {
                _sidePanelScrollController.animateTo(
                  _sidePanelScrollController.offset - 70.0,
                  duration: Duration(milliseconds: 200),
                  curve: Curves.bounceIn,
                );
              },
              child: Container(
                padding: EdgeInsets.only(
                  top: 24.0,
                  left: 0.0,
                  bottom: 24.0,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: color.withOpacity(0.1),
                      width: 2.0,
                    ),
                  ),
                ),
                child: Tooltip(
                  message: "scroll_up".tr(),
                  child: Icon(UniconsLine.arrow_up),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget space() {
    return SliverPadding(
      padding: const EdgeInsets.only(bottom: 70.0),
    );
  }

  Widget toggleExpandButton() {
    final Color color =
        Theme.of(context).textTheme.bodyText2?.color ?? Colors.black;
    final double maxHeight = 76.0;

    return Positioned(
      bottom: 0.0,
      left: 0.0,
      right: 0.0,
      child: Material(
        color: Theme.of(context).backgroundColor,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: _expandedWidth,
            maxHeight: maxHeight,
          ),
          child: OverflowBox(
            maxWidth: _expandedWidth,
            maxHeight: maxHeight,
            child: InkWell(
              onTap: _toggleSideMenu,
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: color.withOpacity(0.025),
                      width: 2.0,
                    ),
                  ),
                ),
                padding: EdgeInsets.only(
                  top: 24.0,
                  left: _isExpanded ? 58.0 : 6.0,
                  bottom: 24.0,
                ),
                child: Row(
                  children: [
                    if (_isExpanded)
                      Tooltip(
                        message: "collapse".tr(),
                        child: Icon(UniconsLine.left_arrow_from_left),
                      )
                    else
                      Expanded(
                        child: Tooltip(
                          message: "expand".tr(),
                          child: Icon(UniconsLine.arrow_from_right),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
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
                tooltip: "hub_subtitle".tr(),
                onPressed: () {
                  Beamer.of(context).beamToNamed(AtelierLocation.route);
                },
                icon: Opacity(
                  opacity: 0.8,
                  child: Icon(UniconsLine.ruler_combined),
                ),
              ),
            ],
          ),
        ]),
      ),
    );
  }

  List<SideMenuItem> getItemList({UserFirestore? userFirestore}) {
    return [
      ...getBaseItemList(),
      ...getAdminItemList(userFirestore: userFirestore),
    ];
  }

  List<SideMenuItem> getBaseItemList() {
    return [
      SideMenuItem(
        iconData: UniconsLine.home,
        label: "home".tr(),
        hoverColor: Constants.colors.home,
        routePath: HomeLocation.route,
      ),
      SideMenuItem(
        iconData: UniconsLine.chart_pie,
        label: "activity".tr(),
        hoverColor: Constants.colors.activity,
        routePath: AtelierLocationContent.activityRoute,
      ),
      SideMenuItem(
        iconData: UniconsLine.picture,
        label: "illustrations".tr(),
        hoverColor: Constants.colors.illustrations,
        routePath: AtelierLocationContent.illustrationsRoute,
      ),
      SideMenuItem(
        iconData: UniconsLine.book_alt,
        label: "books".tr(),
        hoverColor: Constants.colors.books,
        routePath: AtelierLocationContent.booksRoute,
      ),
      SideMenuItem(
        iconData: UniconsLine.user,
        label: "profile_my".tr(),
        hoverColor: Constants.colors.galleries,
        routePath: AtelierLocationContent.profileRoute,
      ),
      SideMenuItem(
        iconData: UniconsLine.setting,
        label: "settings".tr(),
        hoverColor: Constants.colors.settings,
        routePath: AtelierLocationContent.settingsRoute,
      ),
      SideMenuItem(
        iconData: UniconsLine.heart,
        label: "likes".tr(),
        hoverColor: Colors.pink,
        routePath: AtelierLocationContent.likesRoute,
      ),
      SideMenuItem(
        iconData: UniconsLine.document_info,
        label: "licenses".tr(),
        hoverColor: Colors.amber.shade800,
        routePath: AtelierLocationContent.licensesRoute,
      ),
    ];
  }

  List<SideMenuItem> getAdminItemList({UserFirestore? userFirestore}) {
    if (userFirestore == null) {
      return [];
    }

    final UserRights rights = userFirestore.rights;

    return [
      if (rights.canManageReviews)
        SideMenuItem(
          iconData: UniconsLine.image_check,
          label: "review".tr(),
          hoverColor: Constants.colors.review,
          routePath: AtelierLocationContent.reviewRoute,
        ),
      if (rights.canManagePosts)
        SideMenuItem(
            iconData: UniconsLine.file_edit_alt,
            label: "posts".tr(),
            hoverColor: Constants.colors.sections,
            routePath: AtelierLocationContent.postsRoute),
      if (rights.canManageSections)
        SideMenuItem(
          iconData: UniconsLine.web_grid,
          label: "sections".tr(),
          hoverColor: Constants.colors.sections,
          routePath: AtelierLocationContent.sectionsRoute,
        ),
    ];
  }

  /// Callback fired when the side panel menu scrolls.
  /// Update update navigation button variables.
  void onScrollPanel() {
    if (_sidePanelScrollController.position.atEdge &&
        _sidePanelScrollController.offset > 0.0) {
      _showScrollDownButton = false;
    } else {
      _showScrollDownButton = true;
    }

    if (_sidePanelScrollController.position.atEdge &&
        _sidePanelScrollController.offset == 0.0) {
      _showScrollUpButton = false;
    } else {
      _showScrollUpButton = true;
    }

    setState(() {});
  }

  void _setStateListener() => setState(() {});

  void _toggleSideMenu() {
    final bool newIsExpanded = !_isExpanded;

    setState(() {
      _isExpanded = newIsExpanded;
      Utilities.storage.setDashboardSideMenuExpanded(_isExpanded);
    });

    ref
        .read(AppState.dashboardSideMenuOpenProvider.notifier)
        .setVisibility(newIsExpanded);
  }
}
