import 'package:artbooking/components/main_app_bar/main_app_bar.dart';
import 'package:artbooking/components/sliver_edge_padding.dart';
import 'package:artbooking/router/locations/dashboard_location.dart';
import 'package:artbooking/screens/my_statistics_page/member_since.dart';
import 'package:artbooking/screens/my_statistics_page/my_stats_header.dart';
import 'package:artbooking/screens/my_statistics_page/stats_categories.dart';
import 'package:artbooking/screens/my_statistics_page/used_storage.dart';
import 'package:artbooking/types/globals/globals.dart';
import 'package:artbooking/types/globals/app_state.dart';
import 'package:artbooking/types/square_stats_data.dart';
import 'package:artbooking/types/user/stats.dart';
import 'package:artbooking/types/user/user.dart';
import 'package:artbooking/types/user/user_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicons/unicons.dart';

class MyActivityPage extends ConsumerWidget {
  const MyActivityPage({Key? key}) : super(key: key);
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
          MainAppBar(),
          MyStatsHeader(),
          SliverList(
            delegate: SliverChildListDelegate.fixed([
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StatsCategories(
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
                        UsedStorage(
                          usedSpace: Globals.utils.getStringWithUnit(usedBytes),
                        ),
                        MemberSince(createdAt: createdAt),
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
        borderColor: Globals.constants.colors.illustrations,
        count: stats.illustrations.owned,
        icon: Icon(
          UniconsLine.picture,
          size: 48.0,
        ),
        routePath: DashboardLocationContent.illustrationsRoute,
        titleValue: "illustrations".tr(),
      ),
      SquareStatsData(
        borderColor: Globals.constants.colors.books,
        count: stats.books.owned,
        icon: Icon(
          UniconsLine.book_alt,
          size: 48.0,
        ),
        routePath: DashboardLocationContent.booksRoute,
        titleValue: "books".tr(),
      ),
      SquareStatsData(
        borderColor: Globals.constants.colors.galleries,
        count: stats.galleries.owned,
        titleValue: "galleries".tr(),
        icon: Icon(UniconsLine.abacus),
        routePath: '',
      ),
      SquareStatsData(
        borderColor: Globals.constants.colors.challenges,
        count: stats.challenges.participating,
        titleValue: "challenges".tr(),
        icon: Icon(UniconsLine.abacus),
        routePath: '',
      ),
      SquareStatsData(
        borderColor: Globals.constants.colors.contests,
        count: stats.constests.participating,
        titleValue: "contests".tr(),
        icon: Icon(UniconsLine.abacus),
        routePath: '',
      ),
    ];
  }
}
