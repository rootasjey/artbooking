import 'package:artbooking/router/route_names.dart';
import 'package:artbooking/router/web/route_handlers.dart';
import 'package:fluro/fluro.dart';

class FluroRouter {
  static Router router = Router();

  static void setupMobileRouter() {}

  static void setupWebRouter() {
    router.define(
      RootRoute,
      handler: WebRouteHandlers.home,
    );
  }
}