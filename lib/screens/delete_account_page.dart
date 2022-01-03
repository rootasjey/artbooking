import 'package:artbooking/components/animated_app_icon.dart';
import 'package:artbooking/components/fade_in_y.dart';
import 'package:artbooking/components/main_app_bar/main_app_bar.dart';
import 'package:artbooking/router/locations/home_location.dart';
import 'package:artbooking/router/locations/signin_location.dart';
import 'package:artbooking/types/cloud_function_response.dart';
import 'package:artbooking/types/globals/globals.dart';
import 'package:artbooking/utils/fonts.dart';
import 'package:artbooking/utils/snack.dart';
import 'package:beamer/beamer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supercharged/supercharged.dart';
import 'package:unicons/unicons.dart';

class DeleteAccountPage extends StatefulWidget {
  @override
  DeleteAccountPageState createState() => DeleteAccountPageState();
}

class DeleteAccountPageState extends State<DeleteAccountPage> {
  bool _isDeleting = false;
  bool _isCompleted = false;

  double _beginY = 10.0;

  String _password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          MainAppBar(),
          header(),
          body(),
        ],
      ),
    );
  }

  Widget body() {
    if (_isCompleted) {
      return completedView();
    }

    if (_isDeleting) {
      return deletingView();
    }

    return idleView();
  }

  Widget completedView() {
    return SliverList(
      delegate: SliverChildListDelegate([
        Container(
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
      ]),
    );
  }

  Widget deletingView() {
    return SliverList(
      delegate: SliverChildListDelegate([
        Container(
          padding: const EdgeInsets.only(top: 100.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              AnimatedAppIcon(),
              Padding(
                padding: const EdgeInsets.only(top: 40.0),
                child: Text(
                  'Deleting your data...',
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
              )
            ],
          ),
        ),
      ]),
    );
  }

  Widget header() {
    return SliverList(
      delegate: SliverChildListDelegate.fixed([
        Padding(
          padding: const EdgeInsets.only(top: 60.0),
          child: Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 24.0),
                    child: Opacity(
                      opacity: 0.8,
                      child: IconButton(
                        onPressed: Beamer.of(context).popRoute,
                        icon: Icon(UniconsLine.arrow_left),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Opacity(
                        opacity: 0.4,
                        child: Text(
                          "settings".tr().toUpperCase(),
                          style: FontsUtils.mainStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Opacity(
                        opacity: 0.8,
                        child: Text(
                          "account_delete".tr(),
                          style: FontsUtils.mainStyle(
                            fontSize: 50.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Container(
                        width: 400.0,
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Opacity(
                          opacity: 0.5,
                          child: Text(
                            "account_delete_description".tr(),
                            style: FontsUtils.mainStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ]),
    );
  }

  Widget helperCard() {
    return Container(
      width: 350.0,
      padding: EdgeInsets.only(
        top: 60.0,
        bottom: 40.0,
      ),
      child: Card(
        color: Globals.constants.colors.clairPink,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 32.0,
            vertical: 16.0,
          ),
          title: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 30.0),
                child: Icon(
                  UniconsLine.exclamation_triangle,
                  color: Theme.of(context).secondaryHeaderColor,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "are_you_sure".tr(),
                      style: FontsUtils.mainStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16.0,
                      ),
                    ),
                    Opacity(
                      opacity: 0.6,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 0.0),
                        child: Text(
                          "action_irreversible".tr(),
                          style: FontsUtils.mainStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          onTap: showTipsDialog,
        ),
      ),
    );
  }

  Widget idleView() {
    return SliverList(
      delegate: SliverChildListDelegate([
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            children: <Widget>[
              FadeInY(
                delay: 0.milliseconds,
                beginY: _beginY,
                child: helperCard(),
              ),
              FadeInY(
                delay: 100.milliseconds,
                beginY: _beginY,
                child: passwordInput(),
              ),
              FadeInY(
                delay: 200.milliseconds,
                beginY: _beginY,
                child: Padding(
                  padding: const EdgeInsets.only(top: 60.0),
                  child: validationButton(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 200.0),
              ),
            ],
          ),
        )
      ]),
    );
  }

  Widget imageTitle() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 50.0),
      child: Image.asset(
        'assets/images/delete-user-light.png',
        width: 100.0,
      ),
    );
  }

  Widget passwordInput() {
    return SizedBox(
      width: 340.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            decoration: InputDecoration(
              fillColor: Colors.white,
              focusColor: Globals.constants.colors.clairPink,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8.0,
              ),
              labelText: "password_enter".tr(),
              border: OutlineInputBorder(),
            ),
            autofocus: true,
            obscureText: true,
            onChanged: (value) {
              _password = value;
            },
            onFieldSubmitted: (value) => deleteAccountProcess(),
            validator: (value) {
              if (value!.isEmpty) {
                return "password_empty_forbidden".tr();
              }

              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget validationButton() {
    return ElevatedButton(
      onPressed: deleteAccountProcess,
      style: ElevatedButton.styleFrom(
        primary: Colors.black87,
      ),
      child: SizedBox(
        width: 324.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Text(
                "account_delete".tr().toUpperCase(),
                style: FontsUtils.mainStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void deleteAccountProcess() async {
    if (!inputValuesOk()) {
      return;
    }

    setState(() => _isDeleting = true);

    try {
      final userAuth = Globals.state.getUserAuth();
      final userNotifier = Globals.state.getUserNotifier();

      if (userAuth == null) {
        setState(() => _isDeleting = false);
        context.beamToNamed(SigninLocation.route);
        return;
      }

      final credentials = EmailAuthProvider.credential(
        email: userAuth.email!,
        password: _password,
      );

      await userAuth.reauthenticateWithCredential(credentials);
      final idToken = await userAuth.getIdToken();
      final CloudFunctionResponse response = await userNotifier.deleteAccount(
        idToken,
      );

      if (!response.success) {
        throw ErrorDescription(
          "We cannot delete your account right now. Try again later.",
        );
      }

      setState(() {
        _isDeleting = false;
        _isCompleted = true;
      });
    } catch (error) {
      debugPrint(error.toString());

      setState(() {
        _isDeleting = false;
      });

      Snack.e(
        context: context,
        message: (error as PlatformException).message,
      );
    }
  }

  bool inputValuesOk() {
    if (_password.isEmpty) {
      Snack.e(
        context: context,
        message: "password_empty_forbidden".tr(),
      );

      return false;
    }

    return true;
  }

  void showTipsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          backgroundColor: Globals.constants.colors.clairPink,
          title: Text(
            "account_deletion_after".tr(),
            style: FontsUtils.mainStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          children: <Widget>[
            Divider(
              color: Theme.of(context).secondaryHeaderColor,
              thickness: 1.0,
            ),
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("account_deletion_point_1".tr()),
                  Padding(padding: const EdgeInsets.only(top: 15.0)),
                  Text("account_deletion_point_2".tr()),
                  Padding(padding: const EdgeInsets.only(top: 15.0)),
                  Text("account_deletion_point_3".tr()),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
