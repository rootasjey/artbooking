import 'package:artbooking/router/app_router.gr.dart';
import 'package:artbooking/state/user.dart';
import 'package:artbooking/utils/app_storage.dart';
import 'package:artbooking/utils/storage_keys.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

class NavigationHelper {
  static GlobalKey<NavigatorState>? navigatorKey;

  static void clearSavedNotifiData() {
    appStorage.setString(StorageKeys.quoteIdNotification, '');
    appStorage.setString(StorageKeys.onOpenNotificationPath, '');
  }

  static void navigateNextFrame(
    PageRouteInfo pageRoute,
    BuildContext context,
  ) {
    SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
      context.router.navigate(pageRoute);
    });
  }

  static PageRouteInfo getSettingsRoute({bool showAppBar = false}) {
    if (stateUser.isUserConnected) {
      return DashboardPageRoute(children: [DashSettingsRouter()]);
    }

    return SettingsPageRoute(showAppBar: showAppBar);
  }
}
