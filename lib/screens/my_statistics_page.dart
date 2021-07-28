import 'dart:async';

import 'package:artbooking/components/main_app_bar.dart';
import 'package:artbooking/components/shimmer_card.dart';
import 'package:artbooking/components/sliver_edge_padding.dart';
import 'package:artbooking/components/square_stats.dart';
import 'package:artbooking/router/locations/dashboard_location.dart';
import 'package:artbooking/state/colors.dart';
import 'package:artbooking/state/user.dart';
import 'package:artbooking/types/user/user_firestore.dart';
import 'package:artbooking/utils/app_logger.dart';
import 'package:artbooking/utils/fonts.dart';
import 'package:beamer/beamer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:unicons/unicons.dart';

class MyActivityPage extends StatefulWidget {
  @override
  _MyActivityPageState createState() => _MyActivityPageState();
}

class _MyActivityPageState extends State<MyActivityPage> {
  bool _isLoading = false;

  final _scrollController = ScrollController();

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _userSnapListener;

  @override
  void initState() {
    super.initState();
    fetch();
  }

  @override
  dispose() {
    _userSnapListener?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: <Widget>[
          SliverEdgePadding(),
          MainAppBar(),
          header(),
          body(),
        ],
      ),
    );
  }

  Widget body() {
    if (_isLoading) {
      return loadingView();
    }

    return idleView();
  }

  Widget idleView() {
    return SliverList(
      delegate: SliverChildListDelegate.fixed([
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            squareStatsList(),
            textsStatsRow(),
          ],
        ),
      ]),
    );
  }

  Widget header() {
    return SliverPadding(
      padding: const EdgeInsets.only(
        top: 60.0,
        left: 54.0,
        bottom: 24.0,
      ),
      sliver: SliverList(
        delegate: SliverChildListDelegate.fixed([
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Opacity(
              opacity: 0.8,
              child: Text(
                "statistics".tr().toUpperCase(),
                style: FontsUtils.mainStyle(
                  fontSize: 30.0,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget loadingSquareStatsList() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 50.0,
        right: 50.0,
        top: 20.0,
      ),
      child: Wrap(
        spacing: 16.0,
        runSpacing: 16.0,
        alignment: WrapAlignment.start,
        children: <Widget>[
          ShimmerCard(),
          ShimmerCard(),
          ShimmerCard(),
          ShimmerCard(),
        ],
      ),
    );
  }

  Widget loadingTextStatsRow() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 50.0,
        right: 50.0,
        top: 60.0,
        bottom: 100.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerCard(height: 40.0, width: 300.0, elevation: 1.0),
          ShimmerCard(height: 40.0, width: 300.0, elevation: 1.0),
        ],
      ),
    );
  }

  Widget loadingView() {
    return SliverList(
      delegate: SliverChildListDelegate([
        loadingSquareStatsList(),
        loadingTextStatsRow(),
        Padding(
          padding: const EdgeInsets.only(
            bottom: 200.0,
          ),
        ),
      ]),
    );
  }

  Widget squareStatsList() {
    final stats = stateUser.userFirestore.stats!;

    return Padding(
      padding: const EdgeInsets.only(
        left: 50.0,
        right: 50.0,
        top: 20.0,
      ),
      child: Wrap(
        spacing: 16.0,
        runSpacing: 16.0,
        alignment: WrapAlignment.start,
        children: <Widget>[
          SquareStats(
            borderColor: stateColors.illustrations,
            count: stats.illustrations.owned,
            icon: Icon(
              UniconsLine.picture,
              size: 48.0,
            ),
            onTap: () {
              context.beamToNamed(
                DashboardContentLocation.illustrationsRoute,
              );
            },
            textTitle: "illustrations".tr(),
          ),
          SquareStats(
            borderColor: stateColors.books,
            count: stats.books.owned,
            icon: Icon(
              UniconsLine.book_alt,
              size: 48.0,
            ),
            onTap: () {
              context.beamToNamed(DashboardContentLocation.booksRoute);
            },
            textTitle: "books".tr(),
          ),
          SquareStats(
            borderColor: stateColors.galleries,
            count: stats.galleries.owned,
            textTitle: "galleries".tr(),
          ),
          SquareStats(
            borderColor: stateColors.challenges,
            count: stats.challenges.participating,
            textTitle: "challenges".tr(),
          ),
          SquareStats(
            borderColor: stateColors.contests,
            count: stats.constests.participating,
            textTitle: "contests".tr(),
          ),
        ],
      ),
    );
  }

  Widget textsStatsRow() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 50.0,
        right: 50.0,
        top: 60.0,
        bottom: 100.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          iconWithText(
            icon: Icon(
              UniconsLine.database,
              size: 24.0,
            ),
            richText: RichText(
              text: TextSpan(
                style: TextStyle(
                  color: stateColors.foreground.withOpacity(0.6),
                  fontSize: 16.0,
                ),
                children: [
                  TextSpan(text: "space_total_used".tr()),
                  TextSpan(
                    text: " ${getUsedSpace()}",
                    style: FontsUtils.mainStyle(
                      color: stateColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          iconWithText(
            icon: Icon(
              UniconsLine.clock,
              size: 24.0,
            ),
            richText: RichText(
              text: TextSpan(
                style: TextStyle(
                  color: stateColors.foreground.withOpacity(0.6),
                  fontSize: 16.0,
                ),
                children: [
                  TextSpan(text: "member_since".tr()),
                  TextSpan(
                    text:
                        " ${Jiffy(stateUser.userFirestore.createdAt).format('MMMM yyyy')}",
                    style: FontsUtils.mainStyle(
                      color: stateColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget iconWithText({
    required Widget icon,
    required RichText richText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Wrap(
        spacing: 16.0,
        runSpacing: 16.0,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Opacity(
            opacity: 0.6,
            child: icon,
          ),
          richText,
        ],
      ),
    );
  }

  void fetch() async {
    setState(() => _isLoading = true);

    try {
      final userAuth = FirebaseAuth.instance.currentUser;

      if (userAuth == null) {
        setState(() => _isLoading = false);
        return;
      }

      final snapshot =
          FirebaseFirestore.instance.collection('users').doc(userAuth.uid);

      if (_userSnapListener != null) {
        _userSnapListener?.cancel();
      }

      _userSnapListener = snapshot.snapshots().listen((event) {
        final data = event.data();

        if (data == null) {
          return;
        }

        data['id'] = event.id;

        setState(() {
          stateUser.userFirestore = UserFirestore.fromJSON(data);
        });
      }, onError: (error) {
        appLogger.e(error);
      }, onDone: () {
        _userSnapListener?.cancel();
      });
    } catch (error) {
      appLogger.e(error);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String getUsedSpace() {
    String units = 'bytes';
    final int usedBytes =
        stateUser.userFirestore.stats!.storage.illustrations.used;

    if (usedBytes < 1000) {
      return '$usedBytes $units';
    }

    if (usedBytes < 1000000) {
      units = 'KB';
      return '$usedBytes $units';
    }

    if (usedBytes < 1000000000) {
      units = 'MB';
      return '$usedBytes $units';
    }

    if (usedBytes < 1000000000000) {
      units = 'GB';
      return '$usedBytes $units';
    }

    if (usedBytes < 1000000000000000) {
      units = 'TB';
      return '$usedBytes $units';
    }

    units = 'PB';
    return '$usedBytes $units';
  }
}
