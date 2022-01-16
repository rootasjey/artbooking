import 'package:artbooking/components/buttons/lang_popup_menu_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ApplicationBarLangButton extends StatelessWidget {
  const ApplicationBarLangButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LangPopupMenuButton(
      onLangChanged: (newLang) async {
        await context.setLocale(Locale(newLang));
      },
      lang: context.locale.languageCode,
    );
  }
}
