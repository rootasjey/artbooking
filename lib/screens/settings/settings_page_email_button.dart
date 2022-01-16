import 'package:artbooking/globals/utilities.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class SettingsPageEmailButton extends StatelessWidget {
  const SettingsPageEmailButton({
    Key? key,
    required this.email,
    required this.onPressed,
  }) : super(key: key);

  final String email;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        primary: Colors.black,
      ),
      onLongPress: () {
        showDialog(
            context: context,
            builder: (context) {
              return SimpleDialog(
                title: Text(
                  "email".tr(),
                  style: Utilities.fonts.style(
                    fontSize: 14.0,
                  ),
                ),
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 25.0,
                      right: 25.0,
                    ),
                    child: Text(
                      email,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ],
              );
            });
      },
      child: Container(
        width: 250.0,
        padding: const EdgeInsets.all(5.0),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 24.0),
                  child: Opacity(
                    opacity: 0.6,
                    child: Icon(UniconsLine.envelope),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Opacity(
                        opacity: 0.3,
                        child: Text(
                          "email".tr().toUpperCase(),
                          style: Utilities.fonts.style(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        email,
                        style: Utilities.fonts.style(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
