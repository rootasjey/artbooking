import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:artbooking/app.dart';
import 'package:artbooking/firebase_options.dart';
import 'package:artbooking/globals/app_state.dart';
import 'package:artbooking/globals/state/user_notifier.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/user/user.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:url_strategy/url_strategy.dart';

void main() async {
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Utilities.storage.initialize();
  await EasyLocalization.ensureInitialized();
  await GlobalConfiguration().loadFromAsset('app_settings');

  Utilities.search.init(
    applicationId: GlobalConfiguration().getValue('algolia_app_id'),
    searchApiKey: GlobalConfiguration().getValue('algolia_search_api_key'),
  );

  // Try re-authenticate w/ blocking call.
  // We want to avoid UI flickering from guest -> authenticated
  // if the user was already connected.
  final authUser = await Utilities.getFireAuthUser();
  if (authUser != null) {
    final firestoreUser = await Utilities.getFirestoreUser(authUser.uid);

    AppState.userProvider = StateNotifierProvider<UserNotifier, User>(
      (ref) => UserNotifier(User(
        authUser: authUser,
        firestoreUser: firestoreUser,
      )),
    );
  }

  setPathUrlStrategy();

  final savedThemeMode = await AdaptiveTheme.getThemeMode();

  return runApp(
    ProviderScope(
      child: EasyLocalization(
        path: 'assets/translations',
        supportedLocales: [Locale('en'), Locale('fr')],
        fallbackLocale: Locale('en'),
        child: App(
          savedThemeMode: savedThemeMode,
        ),
      ),
    ),
  );
}
