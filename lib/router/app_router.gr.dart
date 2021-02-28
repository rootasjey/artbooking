// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

import 'package:auto_route/auto_route.dart' as _i1;
import 'package:flutter/material.dart' as _i2;
import 'auth_guard.dart' as _i3;
import 'no_auth_guard.dart' as _i4;
import '../screens/home/home.dart' as _i5;
import '../screens/about.dart' as _i6;
import '../screens/changelog.dart' as _i7;
import '../screens/contact.dart' as _i8;
import '../screens/dashboard_page.dart' as _i9;
import '../screens/forgot_password.dart' as _i10;
import '../screens/settings.dart' as _i11;
import '../screens/signin.dart' as _i12;
import '../screens/signup.dart' as _i13;
import '../screens/tos.dart' as _i14;
import '../screens/undefined_page.dart' as _i15;
import '../screens/add_illustration.dart' as _i16;
import '../screens/my_activity.dart' as _i17;
import '../screens/my_illustrations.dart' as _i18;
import '../screens/my_books.dart' as _i19;
import '../screens/my_book.dart' as _i20;
import '../screens/delete_account.dart' as _i21;
import '../screens/update_email.dart' as _i22;
import '../screens/update_password.dart' as _i23;
import '../screens/update_username.dart' as _i24;

class AppRouter extends _i1.RootStackRouter {
  AppRouter({@_i2.required this.authGuard, @_i2.required this.noAuthGuard})
      : assert(authGuard != null),
        assert(noAuthGuard != null);

  final _i3.AuthGuard authGuard;

  final _i4.NoAuthGuard noAuthGuard;

  @override
  final Map<String, _i1.PageFactory> pagesMap = {
    HomeRoute.name: (entry) {
      var route = entry.routeData.as<HomeRoute>();
      return _i1.MaterialPageX(
          entry: entry,
          child: _i5.Home(mobileInitialIndex: route.mobileInitialIndex ?? 0));
    },
    AboutRoute.name: (entry) {
      return _i1.MaterialPageX(entry: entry, child: _i6.About());
    },
    ChangelogRoute.name: (entry) {
      return _i1.MaterialPageX(entry: entry, child: _i7.Changelog());
    },
    ContactRoute.name: (entry) {
      return _i1.MaterialPageX(entry: entry, child: _i8.Contact());
    },
    DashboardPageRoute.name: (entry) {
      return _i1.MaterialPageX(entry: entry, child: _i9.DashboardPage());
    },
    ForgotPasswordRoute.name: (entry) {
      return _i1.MaterialPageX(entry: entry, child: _i10.ForgotPassword());
    },
    SettingsRoute.name: (entry) {
      var route = entry.routeData.as<SettingsRoute>();
      return _i1.MaterialPageX(
          entry: entry,
          child: _i11.Settings(
              key: route.key, showAppBar: route.showAppBar ?? true));
    },
    SigninRoute.name: (entry) {
      var route = entry.routeData.as<SigninRoute>();
      return _i1.MaterialPageX(
          entry: entry,
          child: _i12.Signin(
              key: route.key, onSigninResult: route.onSigninResult));
    },
    SignupRoute.name: (entry) {
      var route = entry.routeData.as<SignupRoute>();
      return _i1.MaterialPageX(
          entry: entry,
          child: _i13.Signup(
              key: route.key, onSignupResult: route.onSignupResult));
    },
    SignOutRoute.name: (entry) {
      return _i1.MaterialPageX(
          entry: entry, child: const _i1.EmptyRouterPage());
    },
    ExtDeepRoute.name: (entry) {
      return _i1.MaterialPageX(
          entry: entry, child: const _i1.EmptyRouterPage());
    },
    TosRoute.name: (entry) {
      return _i1.MaterialPageX(entry: entry, child: _i14.Tos());
    },
    UndefinedPageRoute.name: (entry) {
      return _i1.MaterialPageX(entry: entry, child: _i15.UndefinedPage());
    },
    AddIllustrationRoute.name: (entry) {
      return _i1.MaterialPageX(entry: entry, child: _i16.AddIllustration());
    },
    MyActivityRoute.name: (entry) {
      return _i1.MaterialPageX(entry: entry, child: _i17.MyActivity());
    },
    MyIllustrationsRoute.name: (entry) {
      return _i1.MaterialPageX(entry: entry, child: _i18.MyIllustrations());
    },
    MyBooksDeepRoute.name: (entry) {
      return _i1.MaterialPageX(
          entry: entry, child: const _i1.EmptyRouterPage());
    },
    DashboardSettingsDeepRoute.name: (entry) {
      return _i1.MaterialPageX(
          entry: entry, child: const _i1.EmptyRouterPage());
    },
    MyBooksRoute.name: (entry) {
      return _i1.MaterialPageX(entry: entry, child: _i19.MyBooks());
    },
    MyBookRoute.name: (entry) {
      var route = entry.routeData.as<MyBookRoute>();
      return _i1.MaterialPageX(
          entry: entry,
          child: _i20.MyBook(key: route.key, bookId: route.bookId));
    },
    DashboardSettingsRoute.name: (entry) {
      var route = entry.routeData.as<DashboardSettingsRoute>();
      return _i1.MaterialPageX(
          entry: entry,
          child: _i11.Settings(
              key: route.key, showAppBar: route.showAppBar ?? true));
    },
    DeleteAccountRoute.name: (entry) {
      return _i1.MaterialPageX(entry: entry, child: _i21.DeleteAccount());
    },
    AccountUpdateDeepRoute.name: (entry) {
      return _i1.MaterialPageX(
          entry: entry, child: const _i1.EmptyRouterPage());
    },
    UpdateEmailRoute.name: (entry) {
      return _i1.MaterialPageX(entry: entry, child: _i22.UpdateEmail());
    },
    UpdatePasswordRoute.name: (entry) {
      return _i1.MaterialPageX(entry: entry, child: _i23.UpdatePassword());
    },
    UpdateUsernameRoute.name: (entry) {
      return _i1.MaterialPageX(entry: entry, child: _i24.UpdateUsername());
    },
    GitHubRoute.name: (entry) {
      return _i1.MaterialPageX(
          entry: entry, child: const _i1.EmptyRouterPage());
    }
  };

  @override
  List<_i1.RouteConfig> get routes => [
        _i1.RouteConfig<HomeRoute>(HomeRoute.name,
            path: '/', routeBuilder: (match) => HomeRoute.fromMatch(match)),
        _i1.RouteConfig<AboutRoute>(AboutRoute.name,
            path: '/about',
            routeBuilder: (match) => AboutRoute.fromMatch(match)),
        _i1.RouteConfig<ChangelogRoute>(ChangelogRoute.name,
            path: '/changelog',
            routeBuilder: (match) => ChangelogRoute.fromMatch(match)),
        _i1.RouteConfig<ContactRoute>(ContactRoute.name,
            path: '/contact',
            routeBuilder: (match) => ContactRoute.fromMatch(match)),
        _i1.RouteConfig<DashboardPageRoute>(DashboardPageRoute.name,
            path: '/dashboard',
            routeBuilder: (match) => DashboardPageRoute.fromMatch(match),
            guards: [
              authGuard
            ],
            children: [
              _i1.RouteConfig('#redirect',
                  path: '', redirectTo: 'activity', fullMatch: true),
              _i1.RouteConfig<AddIllustrationRoute>(AddIllustrationRoute.name,
                  path: 'add/illustration',
                  routeBuilder: (match) =>
                      AddIllustrationRoute.fromMatch(match)),
              _i1.RouteConfig<MyActivityRoute>(MyActivityRoute.name,
                  path: 'activity',
                  routeBuilder: (match) => MyActivityRoute.fromMatch(match)),
              _i1.RouteConfig<MyIllustrationsRoute>(MyIllustrationsRoute.name,
                  path: 'illustrations',
                  routeBuilder: (match) =>
                      MyIllustrationsRoute.fromMatch(match)),
              _i1.RouteConfig<MyBooksDeepRoute>(MyBooksDeepRoute.name,
                  path: 'books',
                  routeBuilder: (match) => MyBooksDeepRoute.fromMatch(match),
                  children: [
                    _i1.RouteConfig<MyBooksRoute>(MyBooksRoute.name,
                        path: '',
                        routeBuilder: (match) => MyBooksRoute.fromMatch(match)),
                    _i1.RouteConfig<MyBookRoute>(MyBookRoute.name,
                        path: ':bookId',
                        routeBuilder: (match) => MyBookRoute.fromMatch(match))
                  ]),
              _i1.RouteConfig<DashboardSettingsDeepRoute>(
                  DashboardSettingsDeepRoute.name,
                  path: 'settings',
                  routeBuilder: (match) =>
                      DashboardSettingsDeepRoute.fromMatch(match),
                  children: [
                    _i1.RouteConfig<DashboardSettingsRoute>(
                        DashboardSettingsRoute.name,
                        path: '',
                        routeBuilder: (match) =>
                            DashboardSettingsRoute.fromMatch(match)),
                    _i1.RouteConfig<DeleteAccountRoute>(DeleteAccountRoute.name,
                        path: 'delete/account',
                        routeBuilder: (match) =>
                            DeleteAccountRoute.fromMatch(match)),
                    _i1.RouteConfig<AccountUpdateDeepRoute>(
                        AccountUpdateDeepRoute.name,
                        path: 'update',
                        routeBuilder: (match) =>
                            AccountUpdateDeepRoute.fromMatch(match),
                        children: [
                          _i1.RouteConfig<UpdateEmailRoute>(
                              UpdateEmailRoute.name,
                              path: 'email',
                              routeBuilder: (match) =>
                                  UpdateEmailRoute.fromMatch(match)),
                          _i1.RouteConfig<UpdatePasswordRoute>(
                              UpdatePasswordRoute.name,
                              path: 'password',
                              routeBuilder: (match) =>
                                  UpdatePasswordRoute.fromMatch(match)),
                          _i1.RouteConfig<UpdateUsernameRoute>(
                              UpdateUsernameRoute.name,
                              path: 'username',
                              routeBuilder: (match) =>
                                  UpdateUsernameRoute.fromMatch(match))
                        ])
                  ])
            ]),
        _i1.RouteConfig<ForgotPasswordRoute>(ForgotPasswordRoute.name,
            path: '/forgotpassword',
            routeBuilder: (match) => ForgotPasswordRoute.fromMatch(match)),
        _i1.RouteConfig<SettingsRoute>(SettingsRoute.name,
            path: '/settings',
            routeBuilder: (match) => SettingsRoute.fromMatch(match)),
        _i1.RouteConfig<SigninRoute>(SigninRoute.name,
            path: '/signin',
            routeBuilder: (match) => SigninRoute.fromMatch(match),
            guards: [noAuthGuard]),
        _i1.RouteConfig<SignupRoute>(SignupRoute.name,
            path: '/signup',
            routeBuilder: (match) => SignupRoute.fromMatch(match),
            guards: [noAuthGuard]),
        _i1.RouteConfig<SignOutRoute>(SignOutRoute.name,
            path: '/signout',
            routeBuilder: (match) => SignOutRoute.fromMatch(match)),
        _i1.RouteConfig<ExtDeepRoute>(ExtDeepRoute.name,
            path: '/ext',
            routeBuilder: (match) => ExtDeepRoute.fromMatch(match),
            children: [
              _i1.RouteConfig<GitHubRoute>(GitHubRoute.name,
                  path: 'github',
                  routeBuilder: (match) => GitHubRoute.fromMatch(match))
            ]),
        _i1.RouteConfig<TosRoute>(TosRoute.name,
            path: '/tos', routeBuilder: (match) => TosRoute.fromMatch(match)),
        _i1.RouteConfig<UndefinedPageRoute>(UndefinedPageRoute.name,
            path: '*',
            routeBuilder: (match) => UndefinedPageRoute.fromMatch(match))
      ];
}

class HomeRoute extends _i1.PageRouteInfo {
  HomeRoute({this.mobileInitialIndex = 0}) : super(name, path: '/');

  HomeRoute.fromMatch(_i1.RouteMatch match)
      : mobileInitialIndex = null,
        super.fromMatch(match);

  final int mobileInitialIndex;

  static const String name = 'HomeRoute';
}

class AboutRoute extends _i1.PageRouteInfo {
  const AboutRoute() : super(name, path: '/about');

  AboutRoute.fromMatch(_i1.RouteMatch match) : super.fromMatch(match);

  static const String name = 'AboutRoute';
}

class ChangelogRoute extends _i1.PageRouteInfo {
  const ChangelogRoute() : super(name, path: '/changelog');

  ChangelogRoute.fromMatch(_i1.RouteMatch match) : super.fromMatch(match);

  static const String name = 'ChangelogRoute';
}

class ContactRoute extends _i1.PageRouteInfo {
  const ContactRoute() : super(name, path: '/contact');

  ContactRoute.fromMatch(_i1.RouteMatch match) : super.fromMatch(match);

  static const String name = 'ContactRoute';
}

class DashboardPageRoute extends _i1.PageRouteInfo {
  const DashboardPageRoute({List<_i1.PageRouteInfo> children})
      : super(name, path: '/dashboard', initialChildren: children);

  DashboardPageRoute.fromMatch(_i1.RouteMatch match) : super.fromMatch(match);

  static const String name = 'DashboardPageRoute';
}

class ForgotPasswordRoute extends _i1.PageRouteInfo {
  const ForgotPasswordRoute() : super(name, path: '/forgotpassword');

  ForgotPasswordRoute.fromMatch(_i1.RouteMatch match) : super.fromMatch(match);

  static const String name = 'ForgotPasswordRoute';
}

class SettingsRoute extends _i1.PageRouteInfo {
  SettingsRoute({this.key, this.showAppBar = true})
      : super(name, path: '/settings');

  SettingsRoute.fromMatch(_i1.RouteMatch match)
      : key = null,
        showAppBar = match.pathParams.getBool('showAppBar'),
        super.fromMatch(match);

  final _i2.Key key;

  final bool showAppBar;

  static const String name = 'SettingsRoute';
}

class SigninRoute extends _i1.PageRouteInfo {
  SigninRoute({this.key, this.onSigninResult}) : super(name, path: '/signin');

  SigninRoute.fromMatch(_i1.RouteMatch match)
      : key = null,
        onSigninResult = null,
        super.fromMatch(match);

  final _i2.Key key;

  final void Function(bool) onSigninResult;

  static const String name = 'SigninRoute';
}

class SignupRoute extends _i1.PageRouteInfo {
  SignupRoute({this.key, this.onSignupResult}) : super(name, path: '/signup');

  SignupRoute.fromMatch(_i1.RouteMatch match)
      : key = null,
        onSignupResult = null,
        super.fromMatch(match);

  final _i2.Key key;

  final void Function(bool) onSignupResult;

  static const String name = 'SignupRoute';
}

class SignOutRoute extends _i1.PageRouteInfo {
  const SignOutRoute() : super(name, path: '/signout');

  SignOutRoute.fromMatch(_i1.RouteMatch match) : super.fromMatch(match);

  static const String name = 'SignOutRoute';
}

class ExtDeepRoute extends _i1.PageRouteInfo {
  const ExtDeepRoute({List<_i1.PageRouteInfo> children})
      : super(name, path: '/ext', initialChildren: children);

  ExtDeepRoute.fromMatch(_i1.RouteMatch match) : super.fromMatch(match);

  static const String name = 'ExtDeepRoute';
}

class TosRoute extends _i1.PageRouteInfo {
  const TosRoute() : super(name, path: '/tos');

  TosRoute.fromMatch(_i1.RouteMatch match) : super.fromMatch(match);

  static const String name = 'TosRoute';
}

class UndefinedPageRoute extends _i1.PageRouteInfo {
  const UndefinedPageRoute() : super(name, path: '*');

  UndefinedPageRoute.fromMatch(_i1.RouteMatch match) : super.fromMatch(match);

  static const String name = 'UndefinedPageRoute';
}

class AddIllustrationRoute extends _i1.PageRouteInfo {
  const AddIllustrationRoute() : super(name, path: 'add/illustration');

  AddIllustrationRoute.fromMatch(_i1.RouteMatch match) : super.fromMatch(match);

  static const String name = 'AddIllustrationRoute';
}

class MyActivityRoute extends _i1.PageRouteInfo {
  const MyActivityRoute() : super(name, path: 'activity');

  MyActivityRoute.fromMatch(_i1.RouteMatch match) : super.fromMatch(match);

  static const String name = 'MyActivityRoute';
}

class MyIllustrationsRoute extends _i1.PageRouteInfo {
  const MyIllustrationsRoute() : super(name, path: 'illustrations');

  MyIllustrationsRoute.fromMatch(_i1.RouteMatch match) : super.fromMatch(match);

  static const String name = 'MyIllustrationsRoute';
}

class MyBooksDeepRoute extends _i1.PageRouteInfo {
  const MyBooksDeepRoute({List<_i1.PageRouteInfo> children})
      : super(name, path: 'books', initialChildren: children);

  MyBooksDeepRoute.fromMatch(_i1.RouteMatch match) : super.fromMatch(match);

  static const String name = 'MyBooksDeepRoute';
}

class DashboardSettingsDeepRoute extends _i1.PageRouteInfo {
  const DashboardSettingsDeepRoute({List<_i1.PageRouteInfo> children})
      : super(name, path: 'settings', initialChildren: children);

  DashboardSettingsDeepRoute.fromMatch(_i1.RouteMatch match)
      : super.fromMatch(match);

  static const String name = 'DashboardSettingsDeepRoute';
}

class MyBooksRoute extends _i1.PageRouteInfo {
  const MyBooksRoute() : super(name, path: '');

  MyBooksRoute.fromMatch(_i1.RouteMatch match) : super.fromMatch(match);

  static const String name = 'MyBooksRoute';
}

class MyBookRoute extends _i1.PageRouteInfo {
  MyBookRoute({this.key, @_i2.required this.bookId})
      : super(name, path: ':bookId', params: {'bookId': bookId});

  MyBookRoute.fromMatch(_i1.RouteMatch match)
      : key = null,
        bookId = match.pathParams.getString('bookId'),
        super.fromMatch(match);

  final _i2.Key key;

  final String bookId;

  static const String name = 'MyBookRoute';
}

class DashboardSettingsRoute extends _i1.PageRouteInfo {
  DashboardSettingsRoute({this.key, this.showAppBar = true})
      : super(name, path: '');

  DashboardSettingsRoute.fromMatch(_i1.RouteMatch match)
      : key = null,
        showAppBar = match.pathParams.getBool('showAppBar'),
        super.fromMatch(match);

  final _i2.Key key;

  final bool showAppBar;

  static const String name = 'DashboardSettingsRoute';
}

class DeleteAccountRoute extends _i1.PageRouteInfo {
  const DeleteAccountRoute() : super(name, path: 'delete/account');

  DeleteAccountRoute.fromMatch(_i1.RouteMatch match) : super.fromMatch(match);

  static const String name = 'DeleteAccountRoute';
}

class AccountUpdateDeepRoute extends _i1.PageRouteInfo {
  const AccountUpdateDeepRoute({List<_i1.PageRouteInfo> children})
      : super(name, path: 'update', initialChildren: children);

  AccountUpdateDeepRoute.fromMatch(_i1.RouteMatch match)
      : super.fromMatch(match);

  static const String name = 'AccountUpdateDeepRoute';
}

class UpdateEmailRoute extends _i1.PageRouteInfo {
  const UpdateEmailRoute() : super(name, path: 'email');

  UpdateEmailRoute.fromMatch(_i1.RouteMatch match) : super.fromMatch(match);

  static const String name = 'UpdateEmailRoute';
}

class UpdatePasswordRoute extends _i1.PageRouteInfo {
  const UpdatePasswordRoute() : super(name, path: 'password');

  UpdatePasswordRoute.fromMatch(_i1.RouteMatch match) : super.fromMatch(match);

  static const String name = 'UpdatePasswordRoute';
}

class UpdateUsernameRoute extends _i1.PageRouteInfo {
  const UpdateUsernameRoute() : super(name, path: 'username');

  UpdateUsernameRoute.fromMatch(_i1.RouteMatch match) : super.fromMatch(match);

  static const String name = 'UpdateUsernameRoute';
}

class GitHubRoute extends _i1.PageRouteInfo {
  const GitHubRoute() : super(name, path: 'github');

  GitHubRoute.fromMatch(_i1.RouteMatch match) : super.fromMatch(match);

  static const String name = 'GitHubRoute';
}
