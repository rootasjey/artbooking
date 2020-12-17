import 'package:artbooking/components/full_page_loading.dart';
import 'package:artbooking/main_mobile.dart';
import 'package:artbooking/main_web.dart';
import 'package:artbooking/state/colors.dart';
import 'package:artbooking/state/user.dart';
import 'package:artbooking/types/enums.dart';
import 'package:artbooking/utils/app_storage.dart';
import 'package:artbooking/utils/snack.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
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

    appStorage.initialize().then((value) {
      final savedLang = appStorage.getLang();
      stateUser.setLang(savedLang);

      autoLogin();

      setState(() {
        isReady = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isReady) {
      return DynamicTheme(
        defaultBrightness: Brightness.light,
        data: (brightness) => ThemeData(
          textTheme: GoogleFonts.latoTextTheme(
            ThemeData(brightness: brightness).textTheme,
          ),
          brightness: brightness,
        ),
        themedWidgetBuilder: (context, theme) {
          stateColors.themeData = theme;

          if (kIsWeb) {
            return MainWeb();
          }

          return MainMobile();
        },
      );
    }

    return MaterialApp(
      title: 'ArtBooking',
      debugShowCheckedModeBanner: false,
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
  }

  void autoLogin() async {
    try {
      final credentials = appStorage.getCredentials();

      if (credentials == null) {
        return;
      }

      final email = credentials['email'];
      final password = credentials['password'];

      if ((email == null || email.isEmpty) ||
          (password == null || password.isEmpty)) {
        return;
      }

      final authResult = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      if (authResult.user == null) {
        return;
      }

      final username = authResult.user.displayName;

      appStorage.setUserName(username);
      stateUser.setUserConnected();
      stateUser.setUserName(username);

      showSnack(
        context: context,
        message: "Welcome back $username",
        type: SnackType.info,
      );
    } catch (error) {
      debugPrint(error.toString());
    }
  }
}
