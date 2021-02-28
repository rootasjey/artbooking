import 'dart:io';

import 'package:artbooking/utils/constants.dart';
import 'package:flash/flash.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:artbooking/screens/home/home_desktop.dart';
import 'package:artbooking/screens/home/home_mobile.dart';
import 'package:mobx/mobx.dart';

class Home extends StatefulWidget {
  final int mobileInitialIndex;

  Home({this.mobileInitialIndex = 0});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isFirstLaunch = false;
  bool isPopupVisible = false;
  FlashController popupController;

  ReactionDisposer reactionDisposer;

  @override
  initState() {
    super.initState();
  }

  @override
  void dispose() {
    reactionDisposer?.reaction?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Overlay(
      initialEntries: [
        OverlayEntry(
          builder: (_) => LayoutBuilder(
            builder: (context, constraints) {
              return homeView(constraints);
            },
          ),
        ),
      ],
    );
  }

  Widget homeView(BoxConstraints constraints) {
    if (constraints.maxWidth < Constants.maxMobileWidth ||
        constraints.maxHeight < Constants.maxMobileHeight) {
      return HomeMobile(
        initialIndex: widget.mobileInitialIndex,
      );
    }

    // Mostly for tablets: iPad, Android tablet
    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      return HomeMobile(
        initialIndex: widget.mobileInitialIndex,
      );
    }

    return HomeDesktop();
  }
}
