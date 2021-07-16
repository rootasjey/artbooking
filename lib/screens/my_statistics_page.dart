import 'package:artbooking/components/full_page_loading.dart';
import 'package:artbooking/components/main_app_bar.dart';
import 'package:artbooking/components/sliver_edge_padding.dart';
import 'package:artbooking/components/square_stats.dart';
import 'package:artbooking/router/locations/dashboard_location.dart';
import 'package:artbooking/screens/signin_page.dart';
import 'package:artbooking/state/colors.dart';
import 'package:artbooking/state/user.dart';
import 'package:artbooking/utils/fonts.dart';
import 'package:beamer/beamer.dart';
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
  final _scrollController = ScrollController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetch();
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
    if (isLoading) {
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

  Widget loadingView() {
    return SliverList(
        delegate: SliverChildListDelegate([
      Center(
        child: FullPageLoading(),
      ),
      Padding(padding: const EdgeInsets.only(bottom: 200.0)),
    ]));
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
    setState(() {
      isLoading = true;
    });

    try {
      final userAuth = FirebaseAuth.instance.currentUser;

      if (userAuth == null) {
        WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => SigninPage()),
          );
        });

        return;
      }

      setState(() {
        isLoading = false;
      });
    } catch (err) {
      debugPrint(err.toString());

      setState(() {
        isLoading = false;
      });
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
