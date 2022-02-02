import 'package:beamer/beamer.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class UpdateEmailPageCompleted extends StatelessWidget {
  const UpdateEmailPageCompleted({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400.0,
      padding: const EdgeInsets.all(40.0),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 30.0),
            child: Icon(
              UniconsLine.check,
              size: 80.0,
              color: Colors.green,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 30.0, bottom: 40.0),
            child: Text(
              "email_update_successful".tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.0,
              ),
            ),
          ),
          OutlinedButton(
            onPressed: Beamer.of(context).popRoute,
            child: Text("back".tr()),
          ),
        ],
      ),
    );
  }
}
