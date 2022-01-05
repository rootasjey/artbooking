import 'package:artbooking/components/main_app_bar/search_button.dart';
import 'package:artbooking/router/locations/dashboard_location.dart';
import 'package:artbooking/router/locations/settings_location.dart';
import 'package:artbooking/types/button_data.dart';
import 'package:artbooking/types/globals/state.dart';
import 'package:artbooking/utils/fonts.dart';
import 'package:beamer/beamer.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainSectionMobile extends ConsumerWidget {
  const MainSectionMobile({Key? key}) : super(key: key);

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
              style: FontsUtils.mainStyle(
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

  void onSelected(BuildContext context, String routePath, WidgetRef ref) {
    if (routePath != SettingsLocation.route) {
      Beamer.of(context).beamToNamed(routePath);
      return;
    }

    if (ref.read(AppState.userProvider.notifier).isAuthenticated) {
      Beamer.of(context).beamToNamed(DashboardLocationContent.settingsRoute);
      return;
    }

    Beamer.of(context).beamToNamed(SettingsLocation.route);
  }
}
