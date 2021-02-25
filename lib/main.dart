import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:artbooking/actions/users.dart';
import 'package:artbooking/components/full_page_loading.dart';
import 'package:artbooking/state/colors.dart';
import 'package:artbooking/state/user.dart';
import 'package:artbooking/utils/app_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await appStorage.initialize();
  runApp(App());
}

class App extends StatefulWidget {
  @override
  AppState createState() => AppState();
}

class AppState extends State<App> {
  bool isReady = false;

  @override
  void initState() {
    super.initState();
    initAsync();
  }

  void initAsync() async {
    final savedLang = appStorage.getLang();
    stateUser.setLang(savedLang);

    await autoLogin();

    setState(() => isReady = true);
  }

  @override
  Widget build(BuildContext context) {
    final brightness = getBrightness();
    stateColors.refreshTheme(brightness);

    if (isReady) {
      return AdaptiveTheme(
        light: ThemeData(
          brightness: Brightness.light,
          fontFamily: GoogleFonts.ibmPlexSans().fontFamily,
        ),
        dark: ThemeData(
          brightness: Brightness.dark,
          fontFamily: GoogleFonts.raleway().fontFamily,
        ),
        initial: brightness == Brightness.light
            ? AdaptiveThemeMode.light
            : AdaptiveThemeMode.dark,
        builder: (theme, darkTheme) {
          stateColors.themeData = theme;

          return MaterialApp(
            title: 'ArtBooking',
            theme: stateColors.themeData,
            debugShowCheckedModeBanner: true,
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 200.0,
                  height: 200.0,
                  child: FullPageLoading(),
                ),
              ),
            ),
          );
        },
      );
    }

    // On the web, if an user accesses an auth route (w/o going first to home),
    // they will be redirected to the Sign in screen before the app auth them.
    // This waiting screen solves this issue.
    return AdaptiveTheme(
      light: ThemeData(
        brightness: Brightness.light,
        fontFamily: GoogleFonts.ibmPlexSans().fontFamily,
      ),
      dark: ThemeData(
        brightness: Brightness.dark,
        fontFamily: GoogleFonts.raleway().fontFamily,
      ),
      initial: brightness == Brightness.light
          ? AdaptiveThemeMode.light
          : AdaptiveThemeMode.dark,
      builder: (theme, darkTheme) {
        stateColors.themeData = theme;
        return MaterialApp(
          title: 'ArtBooking',
          theme: stateColors.themeData,
          debugShowCheckedModeBanner: true,
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 200.0,
                height: 200.0,
                child: FullPageLoading(),
              ),
            ),
          ),
        );
      },
    );
  }

  Future autoLogin() async {
    try {
      final userCred = await userSignin();

      if (userCred == null) {
        userSignOut(context: context, autoNavigateAfter: false);
        // PushNotifications.unlinkAuthUser();
      }
    } catch (error) {
      debugPrint(error.toString());
      userSignOut(context: context, autoNavigateAfter: false);
      // PushNotifications.unlinkAuthUser();
    }
  }

  Brightness getBrightness() {
    final autoBrightness = appStorage.getAutoBrightness();

    if (!autoBrightness) {
      return appStorage.getBrightness();
    }

    Brightness brightness = Brightness.light;
    final now = DateTime.now();

    if (now.hour < 6 || now.hour > 17) {
      brightness = Brightness.dark;
    }

    return brightness;
  }
}
