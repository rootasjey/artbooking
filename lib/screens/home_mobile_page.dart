import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/screens/atelier/atelier_page_welcome.dart';
import 'package:artbooking/screens/atelier/profile/modular_page_presenter.dart';
import 'package:artbooking/screens/search_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:unicons/unicons.dart';

class HomeMobilePage extends StatefulWidget {
  const HomeMobilePage({Key? key}) : super(key: key);

  @override
  State<HomeMobilePage> createState() => _HomeMobilePageState();
}

class _HomeMobilePageState extends State<HomeMobilePage> {
  /// Bottom bar's current index.
  int _barCurrentIndex = 0;

  final List<Widget> _bodies = [
    ModularPagePresenter(pageId: "home"),
    SearchPage(),
    AtelierPageWelcome(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _bodies[_barCurrentIndex],
      bottomNavigationBar: Material(
        elevation: 6,
        child: SalomonBottomBar(
          margin: EdgeInsets.all(24.0),
          currentIndex: _barCurrentIndex,
          onTap: (int index) => setState(() => _barCurrentIndex = index),
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
