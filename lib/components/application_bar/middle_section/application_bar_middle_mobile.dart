import 'package:artbooking/components/application_bar/application_bar_search_button.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/router/locations/atelier_location.dart';
import 'package:artbooking/router/locations/settings_location.dart';
import 'package:artbooking/types/app_bar_button_data.dart';
import 'package:artbooking/globals/app_state.dart';
import 'package:beamer/beamer.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ApplicationBarMiddleMobile extends ConsumerWidget {
  const ApplicationBarMiddleMobile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 24.0),
          child: PopupMenuButton<String>(
            child: Text(
              "sections".toUpperCase(),
              style: Utilities.fonts.body(
                color: Colors.black,
                fontSize: 18.0,
              ),
            ),
            onSelected: (String routePath) =>
                onSelected(context, routePath, ref),
            itemBuilder: (BuildContext context) => getData()
                .map(
                  (buttonData) => PopupMenuItem(
                    value: buttonData.routePath,
                    child: ListTile(
                      leading: Icon(buttonData.iconData),
                      title: Text(
                        buttonData.textValue,
                      ),
                    ),
                  ),
                )
                .toList(),
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

  void onSelected(BuildContext context, String routePath, WidgetRef ref) {
    if (routePath != SettingsLocation.route) {
      Beamer.of(context).beamToNamed(routePath);
      return;
    }

    if (ref.read(AppState.userProvider.notifier).isAuthenticated) {
      Beamer.of(context).beamToNamed(AtelierLocationContent.settingsRoute);
      return;
    }

    Beamer.of(context).beamToNamed(SettingsLocation.route);
  }
}
