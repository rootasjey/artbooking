import 'package:artbooking/router/route_names.dart';
import 'package:artbooking/router/web/route_handlers.dart';
import 'package:fluro/fluro.dart';

class FluroRouter {
  static Router router = Router();

  static void setupMobileRouter() {}

  static void setupWebRouter() {
    router.define(
      DashboardRoute,
      handler: WebRouteHandlers.dashbard,
    );

    router.define(
      ForgotPasswordRoute,
      handler: WebRouteHandlers.forgotPassword,
    );

    router.define(
      IllustrationsRoute,
      handler: WebRouteHandlers.illustrations,
    );

    router.define(
      RootRoute,
      handler: WebRouteHandlers.home,
    );

    router.define(
      SigninRoute,
      handler: WebRouteHandlers.signin,
    );

    router.define(
      SignupRoute,
      handler: WebRouteHandlers.signup,
    );

    router.define(
      UploadRoute,
      handler: WebRouteHandlers.upload,
    );
  }
}