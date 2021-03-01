import 'package:artbooking/router/auth_guard.dart';
import 'package:artbooking/router/no_auth_guard.dart';
import 'package:artbooking/screens/about.dart';
import 'package:artbooking/screens/changelog.dart';
import 'package:artbooking/screens/contact.dart';
import 'package:artbooking/screens/dashboard_page.dart';
import 'package:artbooking/screens/delete_account.dart';
import 'package:artbooking/screens/forgot_password.dart';
import 'package:artbooking/screens/home/home.dart';
import 'package:artbooking/screens/illustration_page.dart';
import 'package:artbooking/screens/my_book.dart';
import 'package:artbooking/screens/my_books.dart';
import 'package:artbooking/screens/my_illustrations.dart';
import 'package:artbooking/screens/settings.dart';
import 'package:artbooking/screens/signin.dart';
import 'package:artbooking/screens/signup.dart';
import 'package:artbooking/screens/my_activity.dart';
import 'package:artbooking/screens/tos.dart';
import 'package:artbooking/screens/undefined_page.dart';
import 'package:artbooking/screens/update_email.dart';
import 'package:artbooking/screens/update_password.dart';
import 'package:artbooking/screens/update_username.dart';
import 'package:artbooking/screens/add_illustration.dart';
import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';

export 'app_router.gr.dart';

@MaterialAutoRouter(
  routes: <AutoRoute>[
    AutoRoute(path: '/', page: Home),
    MaterialRoute(path: '/about', page: About),
    MaterialRoute(path: '/changelog', page: Changelog),
    MaterialRoute(path: '/contact', page: Contact),
    AutoRoute(
      path: '/dashboard',
      page: DashboardPage,
      guards: [AuthGuard],
      children: [
        RedirectRoute(path: '', redirectTo: 'activity'),
        AutoRoute(path: 'add/illustration', page: AddIllustration),
        AutoRoute(path: 'activity', page: MyActivity),
        AutoRoute(path: 'illustrations', page: MyIllustrations),
        AutoRoute(
          path: 'books',
          page: EmptyRouterPage,
          name: 'MyBooksDeepRoute',
          children: [
            AutoRoute(path: '', page: MyBooks),
            AutoRoute(path: ':bookId', page: MyBook),
          ],
        ),
        AutoRoute(
          path: 'settings',
          page: EmptyRouterPage,
          name: 'DashboardSettingsDeepRoute',
          children: [
            MaterialRoute(
              path: '',
              page: Settings,
              name: 'DashboardSettingsRoute',
            ),
            AutoRoute(path: 'delete/account', page: DeleteAccount),
            AutoRoute(
              path: 'update',
              page: EmptyRouterPage,
              name: 'AccountUpdateDeepRoute',
              children: [
                MaterialRoute(path: 'email', page: UpdateEmail),
                MaterialRoute(path: 'password', page: UpdatePassword),
                MaterialRoute(path: 'username', page: UpdateUsername),
              ],
            ),
          ],
        ),
      ],
    ),
    MaterialRoute(path: '/forgotpassword', page: ForgotPassword),
    MaterialRoute(
        path: '/illustration/:illustrationId', page: IllustrationPage),
    MaterialRoute(path: '/settings', page: Settings),
    // MaterialRoute(path: '/search', page: Search),
    MaterialRoute(path: '/signin', page: Signin, guards: [NoAuthGuard]),
    MaterialRoute(path: '/signup', page: Signup, guards: [NoAuthGuard]),
    MaterialRoute(
      path: '/signout',
      page: EmptyRouterPage,
      name: 'SignOutRoute',
    ),
    AutoRoute(
      path: '/ext',
      page: EmptyRouterPage,
      name: 'ExtDeepRoute',
      children: [
        MaterialRoute(
          path: 'github',
          page: EmptyRouterPage,
          name: 'GitHubRoute',
        ),
        // MaterialRoute(
        //   path: 'android',
        //   page: EmptyRouterPage,
        //   name: 'AndroidAppRoute',
        // ),
        // MaterialRoute(
        //   path: 'ios',
        //   page: EmptyRouterPage,
        //   name: 'IosAppRoute',
        // ),
      ],
    ),
    MaterialRoute(path: '/tos', page: Tos),
    MaterialRoute(path: '*', page: UndefinedPage),
  ],
)
class $AppRouter {}
