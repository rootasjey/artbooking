import 'package:artbooking/globals/constants.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class UpdatePasswordPageCompleted extends StatelessWidget {
  const UpdatePasswordPageCompleted({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 80.0),
              child: Icon(
                UniconsLine.check,
                color: Constants.colors.validation,
                size: 80.0,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30.0, bottom: 0.0),
              child: Text(
                "password_update_success".tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
