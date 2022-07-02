import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:artbooking/router/app_routes.dart';
import 'package:artbooking/globals/constants.dart';
import 'package:beamer/beamer.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Main app class.
class App extends StatelessWidget {
  const App({Key? key, this.savedThemeMode}) : super(key: key);

  final AdaptiveThemeMode? savedThemeMode;

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: ThemeData(
        brightness: Brightness.light,
        backgroundColor: Constants.colors.lightBackground,
        scaffoldBackgroundColor: Constants.colors.lightBackground,
        fontFamily: GoogleFonts.raleway().fontFamily,
        primaryColor: Constants.colors.primary,
        secondaryHeaderColor: Constants.colors.secondary,
        colorScheme: ThemeData()
            .colorScheme
            .copyWith(primary: Colors.deepPurple.shade700),
      ),
      dark: ThemeData(
        brightness: Brightness.dark,
        backgroundColor: Constants.colors.dark,
        scaffoldBackgroundColor: Constants.colors.dark,
        fontFamily: GoogleFonts.raleway().fontFamily,
        primaryColor: Constants.colors.primary,
        secondaryHeaderColor: Constants.colors.secondary,
        colorScheme: ThemeData().colorScheme.copyWith(
              primary: Colors.deepPurple.shade700,
              brightness: Brightness.dark,
            ),
      ),
      initial: savedThemeMode ?? AdaptiveThemeMode.light,
      builder: (theme, darkTheme) {
        return MaterialApp.router(
          title: "ArtBooking",
          theme: theme,
          darkTheme: darkTheme,
          debugShowCheckedModeBanner: false,
          locale: context.locale,
          supportedLocales: context.supportedLocales,
          localizationsDelegates: context.localizationDelegates,
          routerDelegate: appLocationsBuilder,
          routeInformationParser: BeamerParser(),
        );
      },
    );
  }
}
