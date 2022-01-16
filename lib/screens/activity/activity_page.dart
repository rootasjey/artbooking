import 'package:artbooking/components/application_bar/application_bar.dart';
import 'package:artbooking/components/sliver_edge_padding.dart';
import 'package:artbooking/router/locations/dashboard_location.dart';
import 'package:artbooking/screens/activity/activity_page_member_since.dart';
import 'package:artbooking/screens/activity/activity_page_header.dart';
import 'package:artbooking/screens/activity/activity_page_categories.dart';
import 'package:artbooking/screens/activity/activity_page_used_storage.dart';
import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/globals/app_state.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/square_stats_data.dart';
import 'package:artbooking/types/user/stats.dart';
import 'package:artbooking/types/user/user.dart';
import 'package:artbooking/types/user/user_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicons/unicons.dart';

class ActivityPage extends ConsumerWidget {
  const ActivityPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final User userState = ref.watch(AppState.userProvider);

    final UserFirestore userFirestore =
        userState.firestoreUser ?? UserFirestore.empty();

    final int usedBytes = userFirestore.stats.storage.illustrations.used;
    final DateTime? createdAt = userFirestore.createdAt;
    final stats = userFirestore.stats;

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverEdgePadding(),
          ApplicationBar(),
          ActivityPageHeader(),
          SliverList(
            delegate: SliverChildListDelegate.fixed([
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ActivityPageCategories(
                    dataList: getStatsCategories(stats),
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
                          usedSpace: Utilities.getStringWithUnit(usedBytes),
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

  List<SquareStatsData> getStatsCategories(UserStats stats) {
    return [
      SquareStatsData(
        borderColor: Constants.colors.illustrations,
        count: stats.illustrations.owned,
        icon: Icon(
          UniconsLine.picture,
          size: 48.0,
        ),
        routePath: DashboardLocationContent.illustrationsRoute,
        titleValue: "illustrations".tr(),
      ),
      SquareStatsData(
        borderColor: Constants.colors.books,
        count: stats.books.owned,
        icon: Icon(
          UniconsLine.book_alt,
          size: 48.0,
        ),
        routePath: DashboardLocationContent.booksRoute,
        titleValue: "books".tr(),
      ),
      SquareStatsData(
        borderColor: Constants.colors.galleries,
        count: stats.galleries.owned,
        titleValue: "galleries".tr(),
        icon: Icon(UniconsLine.abacus),
        routePath: '',
      ),
      SquareStatsData(
        borderColor: Constants.colors.challenges,
        count: stats.challenges.participating,
        titleValue: "challenges".tr(),
        icon: Icon(UniconsLine.abacus),
        routePath: '',
      ),
      SquareStatsData(
        borderColor: Constants.colors.contests,
        count: stats.constests.participating,
        titleValue: "contests".tr(),
        icon: Icon(UniconsLine.abacus),
        routePath: '',
      ),
    ];
  }
}
