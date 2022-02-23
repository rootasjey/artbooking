import 'package:artbooking/components/custom_scroll_behavior.dart';
import 'package:artbooking/components/footer/footer.dart';
import 'package:artbooking/components/application_bar/application_bar.dart';
import 'package:artbooking/screens/home/home_page_contact.dart';
import 'package:artbooking/screens/home/home_page_curated.dart';
import 'package:artbooking/screens/home/home_page_hero.dart';
import 'package:artbooking/screens/home/home_page_quote.dart';
import 'package:artbooking/screens/home/home_page_roadmap.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_improved_scrolling/flutter_improved_scrolling.dart';
import 'package:supercharged/supercharged.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scrollController = ScrollController();
  bool _showFab = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: floattingActionButton(),
      body: Overlay(
        initialEntries: [
          OverlayEntry(builder: (context) {
            return ImprovedScrolling(
              scrollController: _scrollController,
              enableKeyboardScrolling: true,
              onScroll: onScroll,
              child: ScrollConfiguration(
                behavior: CustomScrollBehavior(),
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    ApplicationBar(),
                    SliverList(
                      delegate: SliverChildListDelegate.fixed([
                        HomePageHero(),
                        HomePageCurated(),
                        HomePageQuote(),
                        HomePageRoadmap(),
                        HomePageContact(),
                        Footer(pageScrollController: _scrollController),
                      ]),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget floattingActionButton() {
    if (!_showFab) {
      return Container();
    }

    return FloatingActionButton.extended(
      onPressed: () {
        _scrollController.animateTo(
          0.0,
          duration: 500.milliseconds,
          curve: Curves.decelerate,
        );
      },
      backgroundColor: Theme.of(context).secondaryHeaderColor,
      label: Text("scroll_to_top".tr()),
    );
  }

  void onScroll(double scrollOffset) {
    if (scrollOffset < 50 && _showFab) {
      setState(() => _showFab = false);
      return;
    }

    if (scrollOffset > 50 && !_showFab) {
      setState(() => _showFab = true);
    }
  }
}
