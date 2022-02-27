import 'package:artbooking/router/locations/about_location.dart';
import 'package:artbooking/router/locations/changelog_location.dart';
import 'package:artbooking/router/locations/contact_location.dart';
import 'package:artbooking/router/locations/atelier_location.dart';
import 'package:artbooking/router/locations/forgot_password_location.dart';
import 'package:artbooking/router/locations/home_location.dart';
import 'package:artbooking/router/locations/search_location.dart';
import 'package:artbooking/router/locations/signin_location.dart';
import 'package:artbooking/router/locations/signup_location.dart';
import 'package:artbooking/router/locations/tos_location.dart';
import 'package:artbooking/router/locations/undefined_location.dart';
import 'package:beamer/beamer.dart';

final appLocationsBuilder = BeamerDelegate(
  locationBuilder: BeamerLocationBuilder(
    beamLocations: [
      HomeLocation(),
      AboutLocation(),
      ChangelogLocation(),
      ContactLocation(),
      AtelierLocation(),
      ForgotPasswordLocation(),
      SigninLocation(),
      SignupLocation(),
      SearchLocation(),
      TosLocation(),
    ],
  ),
  notFoundRedirect: UndefinedLocation(),
);
