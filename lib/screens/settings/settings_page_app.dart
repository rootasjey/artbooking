import 'package:artbooking/components/application_bar/application_bar_brightness_button.dart';
import 'package:artbooking/components/application_bar/application_bar_lang_button.dart';
import 'package:flutter/material.dart';

class SettingsPageApp extends StatelessWidget {
  const SettingsPageApp({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 20.0,
        top: 20.0,
        right: 20.0,
        bottom: 120.0,
      ),
      child: Column(
        children: <Widget>[
          ApplicationBarBrightnessButton(),
          ApplicationBarLangButton(),
        ],
      ),
    );
  }
}
