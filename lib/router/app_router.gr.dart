// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

import 'package:auto_route/auto_route.dart' as _i1;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as _i2;

import '../screens/about.dart' as _i6;
import '../screens/add_illustration.dart' as _i17;
import '../screens/changelog.dart' as _i7;
import '../screens/contact.dart' as _i8;
import '../screens/dashboard_page.dart' as _i9;
import '../screens/delete_account.dart' as _i22;
import '../screens/forgot_password.dart' as _i10;
import '../screens/home/home.dart' as _i5;
import '../screens/illustration_page.dart' as _i11;
import '../screens/my_activity.dart' as _i18;
import '../screens/my_book.dart' as _i21;
import '../screens/my_books.dart' as _i20;
import '../screens/my_illustrations.dart' as _i19;
import '../screens/settings.dart' as _i12;
import '../screens/signin.dart' as _i13;
import '../screens/signup.dart' as _i14;
import '../screens/tos.dart' as _i15;
import '../screens/undefined_page.dart' as _i16;
import '../screens/update_email.dart' as _i23;
import '../screens/update_password.dart' as _i24;
import '../screens/update_username.dart' as _i25;
import '../types/book.dart' as _i27;
import '../types/illustration/illustration.dart' as _i26;
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
    HomeRoute.name: (routeData) => _i1.MaterialPageX<dynamic>(
        routeData: routeData,
        builder: (data) {
          final args =
              data.argsAs<HomeRouteArgs>(orElse: () => const HomeRouteArgs());
          return _i5.Home(mobileInitialIndex: args.mobileInitialIndex);
        }),
    AboutRoute.name: (routeData) => _i1.MaterialPageX<dynamic>(
        routeData: routeData,
        builder: (_) {
          return _i6.About();
        }),
    ChangelogRoute.name: (routeData) => _i1.MaterialPageX<dynamic>(
        routeData: routeData,
        builder: (_) {
          return _i7.Changelog();
        }),
    ContactRoute.name: (routeData) => _i1.MaterialPageX<dynamic>(
        routeData: routeData,
        builder: (_) {
          return _i8.Contact();
        }),
    DashboardPageRoute.name: (routeData) => _i1.MaterialPageX<dynamic>(
        routeData: routeData,
        builder: (_) {
          return _i9.DashboardPage();
        }),
    ForgotPasswordRoute.name: (routeData) => _i1.MaterialPageX<dynamic>(
        routeData: routeData,
        builder: (_) {
          return _i10.ForgotPassword();
        }),
    IllustrationPageRoute.name: (routeData) => _i1.MaterialPageX<dynamic>(
        routeData: routeData,
        builder: (data) {
          final pathParams = data.pathParams;
          final args = data.argsAs<IllustrationPageRouteArgs>(
              orElse: () => IllustrationPageRouteArgs(
                  illustrationId: pathParams.getString('illustrationId')));
          return _i11.IllustrationPage(
              key: args.key,
              illustrationId: args.illustrationId,
              illustration: args.illustration);
        }),
    SettingsRoute.name: (routeData) => _i1.MaterialPageX<dynamic>(
        routeData: routeData,
        builder: (data) {
          final pathParams = data.pathParams;
          final args = data.argsAs<SettingsRouteArgs>(
              orElse: () => SettingsRouteArgs(
                  showAppBar: pathParams.getBool('showAppBar')));
          return _i12.Settings(key: args.key, showAppBar: args.showAppBar);
        }),
    SigninRoute.name: (routeData) => _i1.MaterialPageX<dynamic>(
        routeData: routeData,
        builder: (data) {
          final args = data.argsAs<SigninRouteArgs>(
              orElse: () => const SigninRouteArgs());
          return _i13.Signin(
              key: args.key, onSigninResult: args.onSigninResult);
        }),
    SignupRoute.name: (routeData) => _i1.MaterialPageX<dynamic>(
        routeData: routeData,
        builder: (data) {
          final args = data.argsAs<SignupRouteArgs>(
              orElse: () => const SignupRouteArgs());
          return _i14.Signup(
              key: args.key, onSignupResult: args.onSignupResult);
        }),
    SignOutRoute.name: (routeData) => _i1.MaterialPageX<dynamic>(
        routeData: routeData,
        builder: (_) {
          return const _i1.EmptyRouterPage();
        }),
    ExtDeepRoute.name: (routeData) => _i1.MaterialPageX<dynamic>(
        routeData: routeData,
        builder: (_) {
          return const _i1.EmptyRouterPage();
        }),
    TosRoute.name: (routeData) => _i1.MaterialPageX<dynamic>(
        routeData: routeData,
        builder: (_) {
          return _i15.Tos();
        }),
    UndefinedPageRoute.name: (routeData) => _i1.MaterialPageX<dynamic>(
        routeData: routeData,
        builder: (_) {
          return _i16.UndefinedPage();
        }),
    AddIllustrationRoute.name: (routeData) => _i1.MaterialPageX<dynamic>(
        routeData: routeData,
        builder: (_) {
          return _i17.AddIllustration();
        }),
    MyActivityRoute.name: (routeData) => _i1.MaterialPageX<dynamic>(
        routeData: routeData,
        builder: (_) {
          return _i18.MyActivity();
        }),
    MyIllustrationsRoute.name: (routeData) => _i1.MaterialPageX<dynamic>(
        routeData: routeData,
        builder: (_) {
          return _i19.MyIllustrations();
        }),
    MyBooksDeepRoute.name: (routeData) => _i1.MaterialPageX<dynamic>(
        routeData: routeData,
        builder: (_) {
          return const _i1.EmptyRouterPage();
        }),
    DashboardSettingsDeepRoute.name: (routeData) => _i1.MaterialPageX<dynamic>(
        routeData: routeData,
        builder: (_) {
          return const _i1.EmptyRouterPage();
        }),
    MyBooksRoute.name: (routeData) => _i1.MaterialPageX<dynamic>(
        routeData: routeData,
        builder: (_) {
          return _i20.MyBooks();
        }),
    MyBookRoute.name: (routeData) => _i1.MaterialPageX<dynamic>(
        routeData: routeData,
        builder: (data) {
          final pathParams = data.pathParams;
          final args = data.argsAs<MyBookRouteArgs>(
              orElse: () =>
                  MyBookRouteArgs(bookId: pathParams.getString('bookId')));
          return _i21.MyBook(
              key: args.key, bookId: args.bookId, book: args.book);
        }),
    DashboardSettingsRoute.name: (routeData) => _i1.MaterialPageX<dynamic>(
        routeData: routeData,
        builder: (data) {
          final pathParams = data.pathParams;
          final args = data.argsAs<DashboardSettingsRouteArgs>(
              orElse: () => DashboardSettingsRouteArgs(
                  showAppBar: pathParams.getBool('showAppBar')));
          return _i12.Settings(key: args.key, showAppBar: args.showAppBar);
        }),
    DeleteAccountRoute.name: (routeData) => _i1.MaterialPageX<dynamic>(
        routeData: routeData,
        builder: (_) {
          return _i22.DeleteAccount();
        }),
    AccountUpdateDeepRoute.name: (routeData) => _i1.MaterialPageX<dynamic>(
        routeData: routeData,
        builder: (_) {
          return const _i1.EmptyRouterPage();
        }),
    UpdateEmailRoute.name: (routeData) => _i1.MaterialPageX<dynamic>(
        routeData: routeData,
        builder: (_) {
          return _i23.UpdateEmail();
        }),
    UpdatePasswordRoute.name: (routeData) => _i1.MaterialPageX<dynamic>(
        routeData: routeData,
        builder: (_) {
          return _i24.UpdatePassword();
        }),
    UpdateUsernameRoute.name: (routeData) => _i1.MaterialPageX<dynamic>(
        routeData: routeData,
        builder: (_) {
          return _i25.UpdateUsername();
        }),
    GitHubRoute.name: (routeData) => _i1.MaterialPageX<dynamic>(
        routeData: routeData,
        builder: (_) {
          return const _i1.EmptyRouterPage();
        })
  };

  @override
  List<_i1.RouteConfig> get routes => [
        _i1.RouteConfig(HomeRoute.name, path: '/'),
        _i1.RouteConfig(AboutRoute.name, path: '/about'),
        _i1.RouteConfig(ChangelogRoute.name, path: '/changelog'),
        _i1.RouteConfig(ContactRoute.name, path: '/contact'),
        _i1.RouteConfig(DashboardPageRoute.name, path: '/dashboard', guards: [
          authGuard
        ], children: [
          _i1.RouteConfig('#redirect',
              path: '', redirectTo: 'activity', fullMatch: true),
          _i1.RouteConfig(AddIllustrationRoute.name, path: 'add/illustration'),
          _i1.RouteConfig(MyActivityRoute.name, path: 'activity'),
          _i1.RouteConfig(MyIllustrationsRoute.name, path: 'illustrations'),
          _i1.RouteConfig(MyBooksDeepRoute.name, path: 'books', children: [
            _i1.RouteConfig(MyBooksRoute.name, path: ''),
            _i1.RouteConfig(MyBookRoute.name, path: ':bookId')
          ]),
          _i1.RouteConfig(DashboardSettingsDeepRoute.name,
              path: 'settings',
              children: [
                _i1.RouteConfig(DashboardSettingsRoute.name, path: ''),
                _i1.RouteConfig(DeleteAccountRoute.name,
                    path: 'delete/account'),
                _i1.RouteConfig(AccountUpdateDeepRoute.name,
                    path: 'update',
                    children: [
                      _i1.RouteConfig(UpdateEmailRoute.name, path: 'email'),
                      _i1.RouteConfig(UpdatePasswordRoute.name,
                          path: 'password'),
                      _i1.RouteConfig(UpdateUsernameRoute.name,
                          path: 'username')
                    ])
              ])
        ]),
        _i1.RouteConfig(ForgotPasswordRoute.name, path: '/forgotpassword'),
        _i1.RouteConfig(IllustrationPageRoute.name,
            path: '/illustration/:illustrationId'),
        _i1.RouteConfig(SettingsRoute.name, path: '/settings'),
        _i1.RouteConfig(SigninRoute.name,
            path: '/signin', guards: [noAuthGuard]),
        _i1.RouteConfig(SignupRoute.name,
            path: '/signup', guards: [noAuthGuard]),
        _i1.RouteConfig(SignOutRoute.name, path: '/signout'),
        _i1.RouteConfig(ExtDeepRoute.name,
            path: '/ext',
            children: [_i1.RouteConfig(GitHubRoute.name, path: 'github')]),
        _i1.RouteConfig(TosRoute.name, path: '/tos'),
        _i1.RouteConfig(UndefinedPageRoute.name, path: '*')
      ];
}

class HomeRoute extends _i1.PageRouteInfo<HomeRouteArgs> {
  HomeRoute({int mobileInitialIndex})
      : super(name,
            path: '/',
            args: HomeRouteArgs(mobileInitialIndex: mobileInitialIndex));

  static const String name = 'HomeRoute';
}

class HomeRouteArgs {
  const HomeRouteArgs({this.mobileInitialIndex});

  final int mobileInitialIndex;
}

class AboutRoute extends _i1.PageRouteInfo {
  const AboutRoute() : super(name, path: '/about');

  static const String name = 'AboutRoute';
}

class ChangelogRoute extends _i1.PageRouteInfo {
  const ChangelogRoute() : super(name, path: '/changelog');

  static const String name = 'ChangelogRoute';
}

class ContactRoute extends _i1.PageRouteInfo {
  const ContactRoute() : super(name, path: '/contact');

  static const String name = 'ContactRoute';
}

class DashboardPageRoute extends _i1.PageRouteInfo {
  const DashboardPageRoute({List<_i1.PageRouteInfo> children})
      : super(name, path: '/dashboard', initialChildren: children);

  static const String name = 'DashboardPageRoute';
}

class ForgotPasswordRoute extends _i1.PageRouteInfo {
  const ForgotPasswordRoute() : super(name, path: '/forgotpassword');

  static const String name = 'ForgotPasswordRoute';
}

class IllustrationPageRoute
    extends _i1.PageRouteInfo<IllustrationPageRouteArgs> {
  IllustrationPageRoute(
      {_i2.Key key, String illustrationId, _i26.Illustration illustration})
      : super(name,
            path: '/illustration/:illustrationId',
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

  final _i26.Illustration illustration;
}

class SettingsRoute extends _i1.PageRouteInfo<SettingsRouteArgs> {
  SettingsRoute({_i2.Key key, bool showAppBar})
      : super(name,
            path: '/settings',
            args: SettingsRouteArgs(key: key, showAppBar: showAppBar));

  static const String name = 'SettingsRoute';
}

class SettingsRouteArgs {
  const SettingsRouteArgs({this.key, this.showAppBar});

  final _i2.Key key;

  final bool showAppBar;
}

class SigninRoute extends _i1.PageRouteInfo<SigninRouteArgs> {
  SigninRoute({_i2.Key key, void Function(bool) onSigninResult})
      : super(name,
            path: '/signin',
            args: SigninRouteArgs(key: key, onSigninResult: onSigninResult));

  static const String name = 'SigninRoute';
}

class SigninRouteArgs {
  const SigninRouteArgs({this.key, this.onSigninResult});

  final _i2.Key key;

  final void Function(bool) onSigninResult;
}

class SignupRoute extends _i1.PageRouteInfo<SignupRouteArgs> {
  SignupRoute({_i2.Key key, void Function(bool) onSignupResult})
      : super(name,
            path: '/signup',
            args: SignupRouteArgs(key: key, onSignupResult: onSignupResult));

  static const String name = 'SignupRoute';
}

class SignupRouteArgs {
  const SignupRouteArgs({this.key, this.onSignupResult});

  final _i2.Key key;

  final void Function(bool) onSignupResult;
}

class SignOutRoute extends _i1.PageRouteInfo {
  const SignOutRoute() : super(name, path: '/signout');

  static const String name = 'SignOutRoute';
}

class ExtDeepRoute extends _i1.PageRouteInfo {
  const ExtDeepRoute({List<_i1.PageRouteInfo> children})
      : super(name, path: '/ext', initialChildren: children);

  static const String name = 'ExtDeepRoute';
}

class TosRoute extends _i1.PageRouteInfo {
  const TosRoute() : super(name, path: '/tos');

  static const String name = 'TosRoute';
}

class UndefinedPageRoute extends _i1.PageRouteInfo {
  const UndefinedPageRoute() : super(name, path: '*');

  static const String name = 'UndefinedPageRoute';
}

class AddIllustrationRoute extends _i1.PageRouteInfo {
  const AddIllustrationRoute() : super(name, path: 'add/illustration');

  static const String name = 'AddIllustrationRoute';
}

class MyActivityRoute extends _i1.PageRouteInfo {
  const MyActivityRoute() : super(name, path: 'activity');

  static const String name = 'MyActivityRoute';
}

class MyIllustrationsRoute extends _i1.PageRouteInfo {
  const MyIllustrationsRoute() : super(name, path: 'illustrations');

  static const String name = 'MyIllustrationsRoute';
}

class MyBooksDeepRoute extends _i1.PageRouteInfo {
  const MyBooksDeepRoute({List<_i1.PageRouteInfo> children})
      : super(name, path: 'books', initialChildren: children);

  static const String name = 'MyBooksDeepRoute';
}

class DashboardSettingsDeepRoute extends _i1.PageRouteInfo {
  const DashboardSettingsDeepRoute({List<_i1.PageRouteInfo> children})
      : super(name, path: 'settings', initialChildren: children);

  static const String name = 'DashboardSettingsDeepRoute';
}

class MyBooksRoute extends _i1.PageRouteInfo {
  const MyBooksRoute() : super(name, path: '');

  static const String name = 'MyBooksRoute';
}

class MyBookRoute extends _i1.PageRouteInfo<MyBookRouteArgs> {
  MyBookRoute({_i2.Key key, String bookId, _i27.Book book})
      : super(name,
            path: ':bookId',
            args: MyBookRouteArgs(key: key, bookId: bookId, book: book),
            rawPathParams: {'bookId': bookId});

  static const String name = 'MyBookRoute';
}

class MyBookRouteArgs {
  const MyBookRouteArgs({this.key, this.bookId, this.book});

  final _i2.Key key;

  final String bookId;

  final _i27.Book book;
}

class DashboardSettingsRoute
    extends _i1.PageRouteInfo<DashboardSettingsRouteArgs> {
  DashboardSettingsRoute({_i2.Key key, bool showAppBar})
      : super(name,
            path: '',
            args: DashboardSettingsRouteArgs(key: key, showAppBar: showAppBar));

  static const String name = 'DashboardSettingsRoute';
}

class DashboardSettingsRouteArgs {
  const DashboardSettingsRouteArgs({this.key, this.showAppBar});

  final _i2.Key key;

  final bool showAppBar;
}

class DeleteAccountRoute extends _i1.PageRouteInfo {
  const DeleteAccountRoute() : super(name, path: 'delete/account');

  static const String name = 'DeleteAccountRoute';
}

class AccountUpdateDeepRoute extends _i1.PageRouteInfo {
  const AccountUpdateDeepRoute({List<_i1.PageRouteInfo> children})
      : super(name, path: 'update', initialChildren: children);

  static const String name = 'AccountUpdateDeepRoute';
}

class UpdateEmailRoute extends _i1.PageRouteInfo {
  const UpdateEmailRoute() : super(name, path: 'email');

  static const String name = 'UpdateEmailRoute';
}

class UpdatePasswordRoute extends _i1.PageRouteInfo {
  const UpdatePasswordRoute() : super(name, path: 'password');

  static const String name = 'UpdatePasswordRoute';
}

class UpdateUsernameRoute extends _i1.PageRouteInfo {
  const UpdateUsernameRoute() : super(name, path: 'username');

  static const String name = 'UpdateUsernameRoute';
}

class GitHubRoute extends _i1.PageRouteInfo {
  const GitHubRoute() : super(name, path: 'github');

  static const String name = 'GitHubRoute';
}
