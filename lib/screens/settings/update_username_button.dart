import 'package:artbooking/globals/utilities.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class UpdateUsernameButton extends StatelessWidget {
  const UpdateUsernameButton({
    Key? key,
    required this.username,
    required this.onPressed,
  }) : super(key: key);

  final String username;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        primary: Theme.of(context).textTheme.bodyText1?.color,
      ),
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
                    child: Icon(UniconsLine.user),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Opacity(
                        opacity: 0.3,
                        child: Text(
                          "username".tr().toUpperCase(),
                          style: Utilities.fonts.style(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        username,
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
