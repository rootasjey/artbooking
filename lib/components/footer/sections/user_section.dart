import 'package:artbooking/globals/app_state.dart';
import 'package:artbooking/globals/state/user_notifier.dart';
import 'package:beamer/beamer.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:artbooking/components/footer/footer_link.dart';
import 'package:artbooking/components/footer/footer_section.dart';
import 'package:artbooking/router/locations/dashboard_location.dart';
import 'package:artbooking/router/locations/settings_location.dart';
import 'package:artbooking/router/locations/signin_location.dart';
import 'package:artbooking/router/locations/signup_location.dart';
import 'package:artbooking/types/footer_link_data.dart';

class UserSection extends ConsumerWidget {
  const UserSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FooterSection(
      titleValue: "user".tr().toUpperCase(),
      children: getItems(context, ref).map(
        (item) {
          return FooterLink(
            label: item.label,
            onPressed: item.onPressed,
          );
        },
      ).toList(),
    );
  }

  List<FooterLinkData> getItems(BuildContext context, WidgetRef ref) {
    return [
      FooterLinkData(
        label: "signin".tr(),
        onPressed: () => Beamer.of(context).beamToNamed(
          SigninLocation.route,
        ),
      ),
      FooterLinkData(
        label: "signup".tr(),
        onPressed: () => Beamer.of(context).beamToNamed(
          SignupLocation.route,
        ),
      ),
      FooterLinkData(
        label: "settings".tr(),
        onPressed: () {
          final UserNotifier userNotifier =
              ref.read(AppState.userProvider.notifier);

          if (userNotifier.isAuthenticated) {
            Beamer.of(context).beamToNamed(
              DashboardLocationContent.settingsRoute,
            );
            return;
          }

          Beamer.of(context).beamToNamed(SettingsLocation.route);
        },
      ),
    ];
  }
}
