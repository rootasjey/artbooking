import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/screens/atelier/atelier_page_welcome.dart';
import 'package:artbooking/screens/atelier/profile/modular_page_presenter.dart';
import 'package:artbooking/screens/search_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:unicons/unicons.dart';

class HomeMobilePage extends StatefulWidget {
  const HomeMobilePage({
    Key? key,
    this.initialTabIndex = 0,
  }) : super(key: key);

  /// Initial tab index.
  final int initialTabIndex;

  @override
  State<HomeMobilePage> createState() => _HomeMobilePageState();
}

class _HomeMobilePageState extends State<HomeMobilePage> {
  /// Bottom bar's current index.
  int _tabIndex = 0;

  final List<Widget> _bodies = [
    ModularPagePresenter(pageId: "home"),
    SearchPage(),
    AtelierPageWelcome(),
  ];

  @override
  void initState() {
    super.initState();
    _tabIndex = widget.initialTabIndex;

    if (_tabIndex < 0 || _tabIndex > (_bodies.length - 1)) {
      _tabIndex = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _bodies[_tabIndex],
      bottomNavigationBar: Material(
        elevation: 6,
        child: SalomonBottomBar(
          margin: EdgeInsets.all(24.0),
          currentIndex: _tabIndex,
          onTap: (int index) => setState(() => _tabIndex = index),
          items: [
            SalomonBottomBarItem(
              icon: Icon(UniconsLine.estate),
              title: Text("home".tr()),
              selectedColor: Theme.of(context).primaryColor,
            ),
            SalomonBottomBarItem(
              icon: Icon(UniconsLine.search),
              title: Text("search".tr()),
              selectedColor: Theme.of(context).secondaryHeaderColor,
            ),
            SalomonBottomBarItem(
              icon: Icon(UniconsLine.ruler_combined),
              title: Text("atelier".tr()),
              selectedColor: Constants.colors.tertiary,
            ),
          ],
        ),
      ),
    );
  }
}
