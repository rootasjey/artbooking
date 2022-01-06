import 'package:artbooking/components/main_app_bar/search_button.dart';
import 'package:artbooking/components/underlined_button.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/router/locations/dashboard_location.dart';
import 'package:artbooking/router/locations/settings_location.dart';
import 'package:artbooking/types/button_data.dart';
import 'package:artbooking/globals/app_state.dart';
import 'package:beamer/beamer.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// AppBar main section displayed for desktops.
class MainSectionDesktop extends ConsumerWidget {
  const MainSectionDesktop({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bodyTextColor = Theme.of(context).textTheme.bodyText1!.color!;
    final underlineColor = bodyTextColor.withOpacity(0.8);

    return Wrap(
      spacing: 12.0,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ...getData().map(
          (buttonData) => UnderlinedButton(
            onTap: () => onTap(context, buttonData.routePath, ref),
            underlineColor: underlineColor,
            child: Opacity(
              opacity: 0.8,
              child: Text(
                buttonData.textValue,
                style: Utilities.fonts.style(
                  color: bodyTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        SearchButton(),
      ],
    );
  }

  /// Return buttons' data.
  List<ButtonData> getData() {
    return [
      ButtonData(
        textValue: "illustrations".tr().toUpperCase(),
        routePath: '/illustrations',
      ),
      ButtonData(
        textValue: "books".tr().toUpperCase(),
        routePath: '/books',
      ),
      ButtonData(
        textValue: "contests".tr().toUpperCase(),
        routePath: '/contests',
      ),
    ];
  }

  void navigateToSettings(BuildContext context, WidgetRef ref) {
    if (ref.read(AppState.userProvider.notifier).isAuthenticated) {
      Beamer.of(context).beamToNamed(DashboardLocationContent.settingsRoute);
      return;
    }

    Beamer.of(context).beamToNamed(SettingsLocation.route);
  }

  void onTap(BuildContext context, String routePath, WidgetRef ref) {
    if (routePath == SettingsLocation.route) {
      navigateToSettings(context, ref);
      return;
    }

    Beamer.of(context).beamToNamed(routePath);
  }
}
