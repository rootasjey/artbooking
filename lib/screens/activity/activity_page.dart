import 'package:artbooking/components/application_bar/application_bar.dart';
import 'package:artbooking/router/locations/dashboard_location.dart';
import 'package:artbooking/screens/activity/activity_page_member_since.dart';
import 'package:artbooking/screens/activity/activity_page_header.dart';
import 'package:artbooking/screens/activity/activity_page_categories.dart';
import 'package:artbooking/screens/activity/activity_page_used_storage.dart';
import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/globals/app_state.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/firestore/doc_snapshot_stream_subscription.dart';
import 'package:artbooking/types/square_stats_data.dart';
import 'package:artbooking/types/user/user_book_stats.dart';
import 'package:artbooking/types/user/user_challenges_stats.dart';
import 'package:artbooking/types/user/user_contest_stats.dart';
import 'package:artbooking/types/user/user_illustration_stats.dart';
import 'package:artbooking/types/user/user.dart';
import 'package:artbooking/types/user/user_firestore.dart';
import 'package:artbooking/types/user/user_storage_stats.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicons/unicons.dart';

class ActivityPage extends ConsumerStatefulWidget {
  const ActivityPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends ConsumerState<ActivityPage> {
  DocSnapshotStreamSubscription? _illustrationSub;
  DocSnapshotStreamSubscription? _bookSub;
  DocSnapshotStreamSubscription? _challengeSub;
  DocSnapshotStreamSubscription? _contestSub;
  DocSnapshotStreamSubscription? _storageSub;

  var _userIllustrationStats = UserIllustrationStats.empty();
  var _userBookStats = UserBookStats.empty();
  var _userChallengeStats = UserChallengeStats.empty();
  var _userContestStats = UserContestStats.empty();
  var _userStorageStats = UserStorageStats.empty();

  @override
  void initState() {
    super.initState();
    fetchStats();
  }

  @override
  void dispose() {
    _bookSub?.cancel();
    _illustrationSub?.cancel();
    _challengeSub?.cancel();
    _contestSub?.cancel();
    _storageSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final User userState = ref.watch(AppState.userProvider);

    final UserFirestore userFirestore =
        userState.firestoreUser ?? UserFirestore.empty();

    final DateTime? createdAt = userFirestore.createdAt;

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          ApplicationBar(),
          ActivityPageHeader(),
          SliverList(
            delegate: SliverChildListDelegate.fixed([
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ActivityPageCategories(
                    dataList: getStatsCategories(),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 50.0,
                      right: 50.0,
                      top: 60.0,
                      bottom: 200.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ActivityPageUsedStorage(
                          usedSpace: Utilities.getStringWithUnit(
                            _userStorageStats.illustrations.used,
                          ),
                        ),
                        ActivityPageMemberSince(createdAt: createdAt),
                      ],
                    ),
                  ),
                ],
              ),
            ]),
          ),
        ],
      ),
    );
  }

  List<SquareStatsData> getStatsCategories() {
    return [
      SquareStatsData(
        borderColor: Constants.colors.illustrations,
        count: _userIllustrationStats.owned,
        icon: Icon(
          UniconsLine.picture,
          size: 48.0,
        ),
        routePath: DashboardLocationContent.illustrationsRoute,
        titleValue: "illustrations".tr(),
      ),
      SquareStatsData(
        borderColor: Constants.colors.books,
        count: _userBookStats.owned,
        icon: Icon(
          UniconsLine.book_alt,
          size: 48.0,
        ),
        routePath: DashboardLocationContent.booksRoute,
        titleValue: "books".tr(),
      ),
      // SquareStatsData(
      //   borderColor: Constants.colors.galleries,
      //   count: stats.galleries.owned,
      //   titleValue: "galleries".tr(),
      //   icon: Icon(UniconsLine.abacus),
      //   routePath: '',
      // ),
      SquareStatsData(
        borderColor: Constants.colors.challenges,
        count: _userChallengeStats.owned,
        titleValue: "challenges".tr(),
        icon: Icon(UniconsLine.abacus),
        routePath: '',
      ),
      SquareStatsData(
        borderColor: Constants.colors.contests,
        count: _userContestStats.owned,
        titleValue: "contests".tr(),
        icon: Icon(UniconsLine.abacus),
        routePath: '',
      ),
    ];
  }

  void fetchStats() async {
    try {
      final String? userId = ref.read(AppState.userProvider).firestoreUser?.id;

      fetchBookStats(userId);
      fetchChallengeStats(userId);
      fetchContestStats(userId);
      fetchIllustrationStats(userId);
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    }
  }

  void fetchBookStats(String? userId) async {
    final bookQuery = FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("user_statistics")
        .doc("books");

    bookQuery.snapshots().listen((snapshot) {
      setState(() {
        _userBookStats = UserBookStats.fromMap(snapshot.data());
      });
    }, onError: (error) {
      Utilities.logger.e(error);
    }, onDone: () {
      _bookSub?.cancel();
    });
  }

  void fetchChallengeStats(String? userId) async {
    final challengeQuery = FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("user_statistics")
        .doc("challenges");

    challengeQuery.snapshots().listen((snapshot) {
      setState(() {
        _userChallengeStats = UserChallengeStats.fromMap(snapshot.data());
      });
    }, onError: (error) {
      Utilities.logger.e(error);
    }, onDone: () {
      _challengeSub?.cancel();
    });
  }

  void fetchContestStats(String? userId) async {
    final contestQuery = FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("user_statistics")
        .doc("contests");

    contestQuery.snapshots().listen((snapshot) {
      setState(() {
        _userContestStats = UserContestStats.fromMap(
          snapshot.data(),
        );
      });
    }, onError: (error) {
      Utilities.logger.e(error);
    }, onDone: () {
      _contestSub?.cancel();
    });
  }

  void fetchIllustrationStats(String? userId) async {
    final illustrationQuery = FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("user_statistics")
        .doc("illustrations");

    illustrationQuery.snapshots().listen((snapshot) {
      setState(() {
        _userIllustrationStats = UserIllustrationStats.fromMap(
          snapshot.data(),
        );
      });
    }, onError: (error) {
      Utilities.logger.e(error);
    }, onDone: () {
      _illustrationSub?.cancel();
    });
  }
}
