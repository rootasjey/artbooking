import 'package:artbooking/router/locations/home_location.dart';
import 'package:beamer/src/beamer.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class DeleteAccountPageCompleted extends StatelessWidget {
  const DeleteAccountPageCompleted({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 40.0),
              child: Icon(
                UniconsLine.check,
                color: Colors.green.shade300,
                size: 80.0,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 30.0,
              ),
              child: Text(
                "account_delete_successfull".tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20.0,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 10.0,
              ),
              child: Opacity(
                opacity: 0.6,
                child: Text(
                  "see_you".tr(),
                  style: TextStyle(
                    fontSize: 15.0,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 45.0,
              ),
              child: OutlinedButton(
                onPressed: () {
                  context.beamToNamed(HomeLocation.route);
                },
                child: Opacity(
                  opacity: 0.6,
                  child: Text("back".tr()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
