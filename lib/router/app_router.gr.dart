// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

import 'package:auto_route/auto_route.dart' as _i1;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as _i2;

import '../components/hero_empty_router_page.dart' as _i18;
import '../screens/about_page.dart' as _i6;
import '../screens/changelog_page.dart' as _i7;
import '../screens/contact_page.dart' as _i8;
import '../screens/dashboard_page.dart' as _i9;
import '../screens/delete_account_page.dart' as _i25;
import '../screens/edit_image_page.dart' as _i24;
import '../screens/forgot_password_page.dart' as _i10;
import '../screens/home_page.dart' as _i5;
import '../screens/illustration_page.dart' as _i20;
import '../screens/illustrations_page.dart' as _i29;
import '../screens/my_activity_page.dart' as _i17;
import '../screens/my_book_page.dart' as _i22;
import '../screens/my_books_page.dart' as _i21;
import '../screens/my_illustrations_page.dart' as _i19;
import '../screens/my_profile_page.dart' as _i23;
import '../screens/search_page.dart' as _i11;
import '../screens/settings_page.dart' as _i12;
import '../screens/signin_page.dart' as _i13;
import '../screens/signup_page.dart' as _i14;
import '../screens/tos_page.dart' as _i15;
import '../screens/undefined_page.dart' as _i16;
import '../screens/update_email_page.dart' as _i26;
import '../screens/update_password_page.dart' as _i27;
import '../screens/update_username_page.dart' as _i28;
import '../types/book.dart' as _i31;
import '../types/illustration/illustration.dart' as _i30;
import 'auth_guard.dart' as _i3;
import 'no_auth_guard.dart' as _i4;

class AppRouter extends _i1.RootStackRouter {
  AppRouter(
      {_i2.GlobalKey<_i2.NavigatorState> navigatorKey,
      @required this.authGuard,
      @required this.noAuthGuard})
      : super(navigatorKey);

  final _i3.AuthGuard authGuard;

  final _i4.NoAuthGuard noAuthGuard;

  @override
  final Map<String, _i1.PageFactory> pagesMap = {
    HomePageRoute.name: (routeData) => _i1.CustomPage<dynamic>(
        routeData: routeData,
        builder: (_) {
          return _i5.HomePage();
        },
        transitionsBuilder: _i1.TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false),
    AboutPageRoute.name: (routeData) => _i1.CustomPage<dynamic>(
        routeData: routeData,
        builder: (_) {
          return _i6.AboutPage();
        },
        transitionsBuilder: _i1.TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false),
    ChangelogPageRoute.name: (routeData) => _i1.CustomPage<dynamic>(
        routeData: routeData,
        builder: (_) {
          return _i7.ChangelogPage();
        },
        transitionsBuilder: _i1.TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false),
    ContactPageRoute.name: (routeData) => _i1.CustomPage<dynamic>(
        routeData: routeData,
        builder: (_) {
          return _i8.ContactPage();
        },
        transitionsBuilder: _i1.TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false),
    DashboardPageRoute.name: (routeData) => _i1.CustomPage<dynamic>(
        routeData: routeData,
        builder: (_) {
          return _i9.DashboardPage();
        },
        transitionsBuilder: _i1.TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false),
    ForgotPasswordPageRoute.name: (routeData) => _i1.MaterialPageX<dynamic>(
        routeData: routeData,
        builder: (_) {
          return _i10.ForgotPasswordPage();
        }),
    IllustrationsRouter.name: (routeData) => _i1.CustomPage<dynamic>(
        routeData: routeData,
        builder: (_) {
          return const _i1.EmptyRouterPage();
        },
        transitionsBuilder: _i1.TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false),
    SearchPageRoute.name: (routeData) => _i1.CustomPage<dynamic>(
        routeData: routeData,
        builder: (_) {
          return _i11.SearchPage();
        },
        transitionsBuilder: _i1.TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false),
    SettingsPageRoute.name: (routeData) => _i1.CustomPage<dynamic>(
        routeData: routeData,
        builder: (data) {
          final pathParams = data.pathParams;
          final args = data.argsAs<SettingsPageRouteArgs>(
              orElse: () => SettingsPageRouteArgs(
                  showAppBar: pathParams.getBool('showAppBar')));
          return _i12.SettingsPage(key: args.key, showAppBar: args.showAppBar);
        },
        transitionsBuilder: _i1.TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false),
    SigninPageRoute.name: (routeData) => _i1.CustomPage<dynamic>(
        routeData: routeData,
        builder: (data) {
          final args = data.argsAs<SigninPageRouteArgs>(
              orElse: () => const SigninPageRouteArgs());
          return _i13.SigninPage(
              key: args.key, onSigninResult: args.onSigninResult);
        },
        transitionsBuilder: _i1.TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false),
    SignupPageRoute.name: (routeData) => _i1.CustomPage<dynamic>(
        routeData: routeData,
        builder: (data) {
          final args = data.argsAs<SignupPageRouteArgs>(
              orElse: () => const SignupPageRouteArgs());
          return _i14.SignupPage(
              key: args.key, onSignupResult: args.onSignupResult);
        },
        transitionsBuilder: _i1.TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false),
    SignOutRoute.name: (routeData) => _i1.MaterialPageX<dynamic>(
        routeData: routeData,
        builder: (_) {
          return const _i1.EmptyRouterPage();
        }),
    ExtRouter.name: (routeData) => _i1.MaterialPageX<dynamic>(
        routeData: routeData,
        builder: (_) {
          return const _i1.EmptyRouterPage();
        }),
    TosPageRoute.name: (routeData) => _i1.CustomPage<dynamic>(
        routeData: routeData,
        builder: (_) {
          return _i15.TosPage();
        },
        transitionsBuilder: _i1.TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false),
    UndefinedPageRoute.name: (routeData) => _i1.CustomPage<dynamic>(
        routeData: routeData,
        builder: (_) {
          return _i16.UndefinedPage();
        },
        transitionsBuilder: _i1.TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false),
    MyActivityPageRoute.name: (routeData) => _i1.MaterialPageX<dynamic>(
        routeData: routeData,
        builder: (_) {
          return _i17.MyActivityPage();
        }),
    DashIllustrationsRouter.name: (routeData) => _i1.MaterialPageX<dynamic>(
        routeData: routeData,
        builder: (_) {
          return _i18.HeroEmptyRouterPage();
        }),
    DashBooksRouter.name: (routeData) => _i1.MaterialPageX<dynamic>(
        routeData: routeData,
        builder: (_) {
          return const _i1.EmptyRouterPage();
        }),
    DashProfileRouter.name: (routeData) => _i1.MaterialPageX<dynamic>(
        routeData: routeData,
        builder: (_) {
          return const _i1.EmptyRouterPage();
        }),
    DashSettingsRouter.name: (routeData) => _i1.CustomPage<dynamic>(
        routeData: routeData,
        builder: (_) {
          return const _i1.EmptyRouterPage();
        },
        transitionsBuilder: _i1.TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false),
    MyIllustrationsPageRoute.name: (routeData) => _i1.CustomPage<dynamic>(
        routeData: routeData,
        builder: (_) {
          return _i19.MyIllustrationsPage();
        },
        transitionsBuilder: _i1.TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false),
    DashIllustrationPage.name: (routeData) => _i1.CustomPage<dynamic>(
        routeData: routeData,
        builder: (data) {
          final pathParams = data.pathParams;
          final args = data.argsAs<DashIllustrationPageArgs>(
              orElse: () => DashIllustrationPageArgs(
                  illustrationId: pathParams.getString('illustrationId')));
          return _i20.IllustrationPage(
              key: args.key,
              illustrationId: args.illustrationId,
              illustration: args.illustration);
        },
        transitionsBuilder: _i1.TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false),
    MyBooksPageRoute.name: (routeData) => _i1.CustomPage<dynamic>(
        routeData: routeData,
        builder: (_) {
          return _i21.MyBooksPage();
        },
        transitionsBuilder: _i1.TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false),
    DashBookPage.name: (routeData) => _i1.CustomPage<dynamic>(
        routeData: routeData,
        builder: (data) {
          final pathParams = data.pathParams;
          final args = data.argsAs<DashBookPageArgs>(
              orElse: () =>
                  DashBookPageArgs(bookId: pathParams.getString('bookId')));
          return _i22.MyBookPage(
              key: args.key, bookId: args.bookId, book: args.book);
        },
        transitionsBuilder: _i1.TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false),
    MyProfilePageRoute.name: (routeData) => _i1.CustomPage<dynamic>(
        routeData: routeData,
        builder: (_) {
          return _i23.MyProfilePage();
        },
        transitionsBuilder: _i1.TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false),
    EditImagePageRoute.name: (routeData) => _i1.CustomPage<dynamic>(
        routeData: routeData,
        builder: (data) {
          final args = data.argsAs<EditImagePageRouteArgs>(
              orElse: () => const EditImagePageRouteArgs());
          return _i24.EditImagePage(key: args.key, image: args.image);
        },
        transitionsBuilder: _i1.TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false),
    DashSettingsRoute.name: (routeData) => _i1.CustomPage<dynamic>(
        routeData: routeData,
        builder: (data) {
          final pathParams = data.pathParams;
          final args = data.argsAs<DashSettingsRouteArgs>(
              orElse: () => DashSettingsRouteArgs(
                  showAppBar: pathParams.getBool('showAppBar')));
          return _i12.SettingsPage(key: args.key, showAppBar: args.showAppBar);
        },
        opaque: true,
        barrierDismissible: false),
    DeleteAccountPageRoute.name: (routeData) => _i1.CustomPage<dynamic>(
        routeData: routeData,
        builder: (_) {
          return _i25.DeleteAccountPage();
        },
        transitionsBuilder: _i1.TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false),
    DashAccountUpdateRouter.name: (routeData) => _i1.CustomPage<dynamic>(
        routeData: routeData,
        builder: (_) {
          return const _i1.EmptyRouterPage();
        },
        transitionsBuilder: _i1.TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false),
    UpdateEmailPageRoute.name: (routeData) => _i1.CustomPage<dynamic>(
        routeData: routeData,
        builder: (_) {
          return _i26.UpdateEmailPage();
        },
        opaque: true,
        barrierDismissible: false),
    UpdatePasswordPageRoute.name: (routeData) => _i1.CustomPage<dynamic>(
        routeData: routeData,
        builder: (_) {
          return _i27.UpdatePasswordPage();
        },
        opaque: true,
        barrierDismissible: false),
    UpdateUsernamePageRoute.name: (routeData) => _i1.CustomPage<dynamic>(
        routeData: routeData,
        builder: (_) {
          return _i28.UpdateUsernamePage();
        },
        opaque: true,
        barrierDismissible: false),
    IllustrationsPageRoute.name: (routeData) => _i1.MaterialPageX<dynamic>(
        routeData: routeData,
        builder: (_) {
          return _i29.IllustrationsPage();
        }),
    IllustrationPageRoute.name: (routeData) => _i1.MaterialPageX<dynamic>(
        routeData: routeData,
        builder: (data) {
          final pathParams = data.pathParams;
          final args = data.argsAs<IllustrationPageRouteArgs>(
              orElse: () => IllustrationPageRouteArgs(
                  illustrationId: pathParams.getString('illustrationId')));
          return _i20.IllustrationPage(
              key: args.key,
              illustrationId: args.illustrationId,
              illustration: args.illustration);
        }),
    GitHubRoute.name: (routeData) => _i1.MaterialPageX<dynamic>(
        routeData: routeData,
        builder: (_) {
          return const _i1.EmptyRouterPage();
        })
  };

  @override
  List<_i1.RouteConfig> get routes => [
        _i1.RouteConfig(HomePageRoute.name, path: '/'),
        _i1.RouteConfig(AboutPageRoute.name, path: '/about'),
        _i1.RouteConfig(ChangelogPageRoute.name, path: '/changelog'),
        _i1.RouteConfig(ContactPageRoute.name, path: '/contact'),
        _i1.RouteConfig(DashboardPageRoute.name, path: '/dashboard', guards: [
          authGuard
        ], children: [
          _i1.RouteConfig(MyActivityPageRoute.name, path: 'activity'),
          _i1.RouteConfig(DashIllustrationsRouter.name,
              path: 'illustrations',
              children: [
                _i1.RouteConfig(MyIllustrationsPageRoute.name, path: ''),
                _i1.RouteConfig(DashIllustrationPage.name,
                    path: ':illustrationId'),
                _i1.RouteConfig('*#redirect',
                    path: '*', redirectTo: '', fullMatch: true)
              ]),
          _i1.RouteConfig(DashBooksRouter.name, path: 'books', children: [
            _i1.RouteConfig(MyBooksPageRoute.name, path: ''),
            _i1.RouteConfig(DashBookPage.name, path: ':bookId'),
            _i1.RouteConfig('*#redirect',
                path: '*', redirectTo: '', fullMatch: true)
          ]),
          _i1.RouteConfig(DashProfileRouter.name, path: 'profile', children: [
            _i1.RouteConfig(MyProfilePageRoute.name, path: ''),
            _i1.RouteConfig(EditImagePageRoute.name, path: 'edit/pp'),
            _i1.RouteConfig('*#redirect',
                path: '*', redirectTo: '', fullMatch: true)
          ]),
          _i1.RouteConfig(DashSettingsRouter.name, path: 'settings', children: [
            _i1.RouteConfig(DashSettingsRoute.name, path: ''),
            _i1.RouteConfig(DeleteAccountPageRoute.name,
                path: 'delete/account'),
            _i1.RouteConfig(DashAccountUpdateRouter.name,
                path: 'update',
                children: [
                  _i1.RouteConfig(UpdateEmailPageRoute.name, path: 'email'),
                  _i1.RouteConfig(UpdatePasswordPageRoute.name,
                      path: 'password'),
                  _i1.RouteConfig(UpdateUsernamePageRoute.name,
                      path: 'username')
                ])
          ]),
          _i1.RouteConfig('#redirect',
              path: '', redirectTo: 'activity', fullMatch: true)
        ]),
        _i1.RouteConfig(ForgotPasswordPageRoute.name, path: '/forgotpassword'),
        _i1.RouteConfig(IllustrationsRouter.name,
            path: '/illustrations',
            children: [
              _i1.RouteConfig(IllustrationsPageRoute.name, path: ''),
              _i1.RouteConfig(IllustrationPageRoute.name,
                  path: ':illustrationId')
            ]),
        _i1.RouteConfig(SearchPageRoute.name, path: '/search'),
        _i1.RouteConfig(SettingsPageRoute.name, path: '/settings'),
        _i1.RouteConfig(SigninPageRoute.name,
            path: '/signin', guards: [noAuthGuard]),
        _i1.RouteConfig(SignupPageRoute.name,
            path: '/signup', guards: [noAuthGuard]),
        _i1.RouteConfig(SignOutRoute.name, path: '/signout'),
        _i1.RouteConfig(ExtRouter.name,
            path: '/ext',
            children: [_i1.RouteConfig(GitHubRoute.name, path: 'github')]),
        _i1.RouteConfig(TosPageRoute.name, path: '/tos'),
        _i1.RouteConfig(UndefinedPageRoute.name, path: '*')
      ];
}

class HomePageRoute extends _i1.PageRouteInfo {
  const HomePageRoute() : super(name, path: '/');

  static const String name = 'HomePageRoute';
}

class AboutPageRoute extends _i1.PageRouteInfo {
  const AboutPageRoute() : super(name, path: '/about');

  static const String name = 'AboutPageRoute';
}

class ChangelogPageRoute extends _i1.PageRouteInfo {
  const ChangelogPageRoute() : super(name, path: '/changelog');

  static const String name = 'ChangelogPageRoute';
}

class ContactPageRoute extends _i1.PageRouteInfo {
  const ContactPageRoute() : super(name, path: '/contact');

  static const String name = 'ContactPageRoute';
}

class DashboardPageRoute extends _i1.PageRouteInfo {
  const DashboardPageRoute({List<_i1.PageRouteInfo> children})
      : super(name, path: '/dashboard', initialChildren: children);

  static const String name = 'DashboardPageRoute';
}

class ForgotPasswordPageRoute extends _i1.PageRouteInfo {
  const ForgotPasswordPageRoute() : super(name, path: '/forgotpassword');

  static const String name = 'ForgotPasswordPageRoute';
}

class IllustrationsRouter extends _i1.PageRouteInfo {
  const IllustrationsRouter({List<_i1.PageRouteInfo> children})
      : super(name, path: '/illustrations', initialChildren: children);

  static const String name = 'IllustrationsRouter';
}

class SearchPageRoute extends _i1.PageRouteInfo {
  const SearchPageRoute() : super(name, path: '/search');

  static const String name = 'SearchPageRoute';
}

class SettingsPageRoute extends _i1.PageRouteInfo<SettingsPageRouteArgs> {
  SettingsPageRoute({_i2.Key key, bool showAppBar})
      : super(name,
            path: '/settings',
            args: SettingsPageRouteArgs(key: key, showAppBar: showAppBar));

  static const String name = 'SettingsPageRoute';
}

class SettingsPageRouteArgs {
  const SettingsPageRouteArgs({this.key, this.showAppBar});

  final _i2.Key key;

  final bool showAppBar;
}

class SigninPageRoute extends _i1.PageRouteInfo<SigninPageRouteArgs> {
  SigninPageRoute({_i2.Key key, void Function(bool) onSigninResult})
      : super(name,
            path: '/signin',
            args:
                SigninPageRouteArgs(key: key, onSigninResult: onSigninResult));

  static const String name = 'SigninPageRoute';
}

class SigninPageRouteArgs {
  const SigninPageRouteArgs({this.key, this.onSigninResult});

  final _i2.Key key;

  final void Function(bool) onSigninResult;
}

class SignupPageRoute extends _i1.PageRouteInfo<SignupPageRouteArgs> {
  SignupPageRoute({_i2.Key key, void Function(bool) onSignupResult})
      : super(name,
            path: '/signup',
            args:
                SignupPageRouteArgs(key: key, onSignupResult: onSignupResult));

  static const String name = 'SignupPageRoute';
}

class SignupPageRouteArgs {
  const SignupPageRouteArgs({this.key, this.onSignupResult});

  final _i2.Key key;

  final void Function(bool) onSignupResult;
}

class SignOutRoute extends _i1.PageRouteInfo {
  const SignOutRoute() : super(name, path: '/signout');

  static const String name = 'SignOutRoute';
}

class ExtRouter extends _i1.PageRouteInfo {
  const ExtRouter({List<_i1.PageRouteInfo> children})
      : super(name, path: '/ext', initialChildren: children);

  static const String name = 'ExtRouter';
}

class TosPageRoute extends _i1.PageRouteInfo {
  const TosPageRoute() : super(name, path: '/tos');

  static const String name = 'TosPageRoute';
}

class UndefinedPageRoute extends _i1.PageRouteInfo {
  const UndefinedPageRoute() : super(name, path: '*');

  static const String name = 'UndefinedPageRoute';
}

class MyActivityPageRoute extends _i1.PageRouteInfo {
  const MyActivityPageRoute() : super(name, path: 'activity');

  static const String name = 'MyActivityPageRoute';
}

class DashIllustrationsRouter extends _i1.PageRouteInfo {
  const DashIllustrationsRouter({List<_i1.PageRouteInfo> children})
      : super(name, path: 'illustrations', initialChildren: children);

  static const String name = 'DashIllustrationsRouter';
}

class DashBooksRouter extends _i1.PageRouteInfo {
  const DashBooksRouter({List<_i1.PageRouteInfo> children})
      : super(name, path: 'books', initialChildren: children);

  static const String name = 'DashBooksRouter';
}

class DashProfileRouter extends _i1.PageRouteInfo {
  const DashProfileRouter({List<_i1.PageRouteInfo> children})
      : super(name, path: 'profile', initialChildren: children);

  static const String name = 'DashProfileRouter';
}

class DashSettingsRouter extends _i1.PageRouteInfo {
  const DashSettingsRouter({List<_i1.PageRouteInfo> children})
      : super(name, path: 'settings', initialChildren: children);

  static const String name = 'DashSettingsRouter';
}

class MyIllustrationsPageRoute extends _i1.PageRouteInfo {
  const MyIllustrationsPageRoute() : super(name, path: '');

  static const String name = 'MyIllustrationsPageRoute';
}

class DashIllustrationPage extends _i1.PageRouteInfo<DashIllustrationPageArgs> {
  DashIllustrationPage(
      {_i2.Key key, String illustrationId, _i30.Illustration illustration})
      : super(name,
            path: ':illustrationId',
            args: DashIllustrationPageArgs(
                key: key,
                illustrationId: illustrationId,
                illustration: illustration),
            rawPathParams: {'illustrationId': illustrationId});

  static const String name = 'DashIllustrationPage';
}

class DashIllustrationPageArgs {
  const DashIllustrationPageArgs(
      {this.key, this.illustrationId, this.illustration});

  final _i2.Key key;

  final String illustrationId;

  final _i30.Illustration illustration;
}

class MyBooksPageRoute extends _i1.PageRouteInfo {
  const MyBooksPageRoute() : super(name, path: '');

  static const String name = 'MyBooksPageRoute';
}

class DashBookPage extends _i1.PageRouteInfo<DashBookPageArgs> {
  DashBookPage({_i2.Key key, String bookId, _i31.Book book})
      : super(name,
            path: ':bookId',
            args: DashBookPageArgs(key: key, bookId: bookId, book: book),
            rawPathParams: {'bookId': bookId});

  static const String name = 'DashBookPage';
}

class DashBookPageArgs {
  const DashBookPageArgs({this.key, this.bookId, this.book});

  final _i2.Key key;

  final String bookId;

  final _i31.Book book;
}

class MyProfilePageRoute extends _i1.PageRouteInfo {
  const MyProfilePageRoute() : super(name, path: '');

  static const String name = 'MyProfilePageRoute';
}

class EditImagePageRoute extends _i1.PageRouteInfo<EditImagePageRouteArgs> {
  EditImagePageRoute({_i2.Key key, _i2.ImageProvider<Object> image})
      : super(name,
            path: 'edit/pp',
            args: EditImagePageRouteArgs(key: key, image: image));

  static const String name = 'EditImagePageRoute';
}

class EditImagePageRouteArgs {
  const EditImagePageRouteArgs({this.key, this.image});

  final _i2.Key key;

  final _i2.ImageProvider<Object> image;
}

class DashSettingsRoute extends _i1.PageRouteInfo<DashSettingsRouteArgs> {
  DashSettingsRoute({_i2.Key key, bool showAppBar})
      : super(name,
            path: '',
            args: DashSettingsRouteArgs(key: key, showAppBar: showAppBar));

  static const String name = 'DashSettingsRoute';
}

class DashSettingsRouteArgs {
  const DashSettingsRouteArgs({this.key, this.showAppBar});

  final _i2.Key key;

  final bool showAppBar;
}

class DeleteAccountPageRoute extends _i1.PageRouteInfo {
  const DeleteAccountPageRoute() : super(name, path: 'delete/account');

  static const String name = 'DeleteAccountPageRoute';
}

class DashAccountUpdateRouter extends _i1.PageRouteInfo {
  const DashAccountUpdateRouter({List<_i1.PageRouteInfo> children})
      : super(name, path: 'update', initialChildren: children);

  static const String name = 'DashAccountUpdateRouter';
}

class UpdateEmailPageRoute extends _i1.PageRouteInfo {
  const UpdateEmailPageRoute() : super(name, path: 'email');

  static const String name = 'UpdateEmailPageRoute';
}

class UpdatePasswordPageRoute extends _i1.PageRouteInfo {
  const UpdatePasswordPageRoute() : super(name, path: 'password');

  static const String name = 'UpdatePasswordPageRoute';
}

class UpdateUsernamePageRoute extends _i1.PageRouteInfo {
  const UpdateUsernamePageRoute() : super(name, path: 'username');

  static const String name = 'UpdateUsernamePageRoute';
}

class IllustrationsPageRoute extends _i1.PageRouteInfo {
  const IllustrationsPageRoute() : super(name, path: '');

  static const String name = 'IllustrationsPageRoute';
}

class IllustrationPageRoute
    extends _i1.PageRouteInfo<IllustrationPageRouteArgs> {
  IllustrationPageRoute(
      {_i2.Key key, String illustrationId, _i30.Illustration illustration})
      : super(name,
            path: ':illustrationId',
            args: IllustrationPageRouteArgs(
                key: key,
                illustrationId: illustrationId,
                illustration: illustration),
            rawPathParams: {'illustrationId': illustrationId});

  static const String name = 'IllustrationPageRoute';
}

class IllustrationPageRouteArgs {
  const IllustrationPageRouteArgs(
      {this.key, this.illustrationId, this.illustration});

  final _i2.Key key;

  final String illustrationId;

  final _i30.Illustration illustration;
}

class GitHubRoute extends _i1.PageRouteInfo {
  const GitHubRoute() : super(name, path: 'github');

  static const String name = 'GitHubRoute';
}
