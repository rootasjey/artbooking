import 'package:artbooking/router/app_router.gr.dart';
import 'package:artbooking/state/user.dart';
import 'package:auto_route/auto_route.dart';

class AuthGuard extends AutoRouteGuard {
  @override
  Future<bool> canNavigate(
    List<PageRouteInfo> pendingRoutes,
    StackRouter router,
  ) async {
    if (stateUser.isUserConnected) {
      return true;
    }

    router.root.push(
      SigninRoute(onSigninResult: (isAuthenticated) {
        if (isAuthenticated) {
          router.replaceAll(pendingRoutes);
        }
      }),
    );

    return false;
  }
}
