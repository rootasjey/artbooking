import 'package:artbooking/components/application_bar/application_bar_search_button.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/router/locations/dashboard_location.dart';
import 'package:artbooking/router/locations/settings_location.dart';
import 'package:artbooking/types/app_bar_button_data.dart';
import 'package:artbooking/globals/app_state.dart';
import 'package:beamer/beamer.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// AppBar main section displayed for desktops.
class ApplicationBarMiddleDesktop extends ConsumerWidget {
  const ApplicationBarMiddleDesktop({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bodyTextColor = Theme.of(context).textTheme.bodyText1!.color!;

    return Wrap(
      spacing: 12.0,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ...getData().map(
          (buttonData) => TextButton(
            onPressed: () => onTap(context, buttonData.routePath, ref),
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
        ApplicationBarSearchButton(),
      ],
    );
  }

  /// Return buttons' data.
  List<AppBarButtonData> getData() {
    return [
      AppBarButtonData(
        textValue: "illustrations".tr().toUpperCase(),
        routePath: '/illustrations',
      ),
      AppBarButtonData(
        textValue: "books".tr().toUpperCase(),
        routePath: '/books',
      ),
      AppBarButtonData(
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

    Beamer.of(context, root: true).beamToNamed(routePath);
  }
}
