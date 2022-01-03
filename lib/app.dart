import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:artbooking/router/app_routes.dart';
import 'package:artbooking/types/globals/globals.dart';
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
        backgroundColor: Globals.constants.colors.lightBackground,
        scaffoldBackgroundColor: Globals.constants.colors.lightBackground,
        fontFamily: GoogleFonts.raleway().fontFamily,
        primaryColor: Globals.constants.colors.primary,
        secondaryHeaderColor: Globals.constants.colors.secondary,
      ),
      dark: ThemeData(
        brightness: Brightness.dark,
        backgroundColor: Globals.constants.colors.dark,
        scaffoldBackgroundColor: Globals.constants.colors.dark,
        fontFamily: GoogleFonts.raleway().fontFamily,
        primaryColor: Globals.constants.colors.primary,
        secondaryHeaderColor: Globals.constants.colors.secondary,
      ),
      initial: savedThemeMode ?? AdaptiveThemeMode.light,
      builder: (theme, darkTheme) {
        return MaterialApp.router(
          title: 'ArtBooking',
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
