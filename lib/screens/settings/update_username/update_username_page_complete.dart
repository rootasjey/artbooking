import 'package:beamer/beamer.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class UpdateUsernamePageComplete extends StatelessWidget {
  const UpdateUsernamePageComplete({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        width: 400.0,
        padding: const EdgeInsets.all(90.0),
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
                "username_update_success".tr(),
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
      ),
    );
  }
}
