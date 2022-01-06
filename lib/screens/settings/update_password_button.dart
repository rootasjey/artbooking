import 'package:artbooking/globals/utilities.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class UpdatePasswordButton extends StatelessWidget {
  const UpdatePasswordButton({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(10.0),
          width: 90.0,
          height: 90.0,
          child: Card(
            elevation: 4.0,
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Opacity(
                  opacity: 0.6,
                  child: Icon(UniconsLine.shield),
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          width: 80.0,
          child: Opacity(
            opacity: 0.8,
            child: Text(
              "password_update".tr(),
              textAlign: TextAlign.center,
              style: Utilities.fonts.style(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
