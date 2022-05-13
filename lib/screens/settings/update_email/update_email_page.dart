import 'dart:async';

import 'package:artbooking/actions/users.dart';
import 'package:artbooking/components/application_bar/application_bar.dart';
import 'package:artbooking/components/dialogs/themed_dialog.dart';
import 'package:artbooking/globals/app_state.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/screens/settings/update_email/update_email_page_body.dart';
import 'package:artbooking/screens/settings/update_email/update_email_page_header.dart';
import 'package:beamer/beamer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flash/src/flash_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supercharged/supercharged.dart';

class UpdateEmailPage extends ConsumerStatefulWidget {
  @override
  _UpdateEmailPageState createState() => _UpdateEmailPageState();
}

class _UpdateEmailPageState extends ConsumerState<UpdateEmailPage> {
  bool _checkingEmail = false;
  bool _updating = false;
  bool _completed = false;

  String _newEmail = '';
  String _errorMessage = '';

  Timer? _emailTimer;

  @override
  void dispose() {
    _emailTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String email =
        ref.watch(AppState.userProvider).firestoreUser?.email ?? '';

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          ApplicationBar(),
          UpdateEmailPageHeader(),
          UpdateEmailPageBody(
            beginY: 10.0,
            completed: _completed,
            checking: _checkingEmail,
            updating: _updating,
            errorMessage: _errorMessage,
            currentEmail: email,
            newEmail: _newEmail,
            onChangedInput: onChangedEmailInput,
            onShowTipsDialog: onShowTipsDialog,
            onTryUpdateEmail: onTryUpdateEmail,
          ),
        ],
      ),
    );
  }

  Future<bool> checkInputsAvailbility() async {
    return await UsersActions.checkEmailAvailability(_newEmail);
  }

  bool checkInputs(String password) {
    if (_newEmail.isEmpty) {
      context.showErrorBar(
        content: Text("email_empty_forbidden".tr()),
      );

      return false;
    }

    if (password.isEmpty) {
      context.showErrorBar(
        content: Text("password_empty_forbidden".tr()),
      );

      return false;
    }

    if (!UsersActions.checkEmailFormat(_newEmail)) {
      context.showErrorBar(
        content: Text("email_not_valid".tr()),
      );

      return false;
    }

    return true;
  }

  void onChangedEmailInput(value) async {
    _newEmail = value;

    setState(() {
      _checkingEmail = true;
    });

    final isWellFormatted = UsersActions.checkEmailFormat(_newEmail);

    if (!isWellFormatted) {
      setState(() {
        _checkingEmail = false;
        _errorMessage = "email_not_valid".tr();
      });

      return;
    }

    _emailTimer?.cancel();
    _emailTimer = null;

    _emailTimer = Timer(1.seconds, () async {
      final isAvailable =
          await (UsersActions.checkEmailAvailability(_newEmail));

      if (!isAvailable) {
        setState(() {
          _checkingEmail = false;
          _errorMessage = "email_not_available".tr();
        });

        return;
      }

      setState(() {
        _checkingEmail = false;
        _errorMessage = '';
      });
    });
  }

  void onShowTipsDialog(String email) {
    showDialog(
      context: context,
      builder: (context) {
        return ThemedDialog(
          title: Opacity(
            opacity: 0.6,
            child: Text(
              "email_current".tr(),
              style: Utilities.fonts.body(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          body: Center(
            child: Opacity(
              opacity: 0.6,
              child: Text(
                email,
                style: Utilities.fonts.body(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          textButtonValidation: "alright_exclamation".tr(),
          onCancel: Beamer.of(context).popRoute,
          onValidate: Beamer.of(context).popRoute,
        );
      },
    );
  }

  void onTryUpdateEmail(String password) async {
    if (!checkInputs(password)) {
      return;
    }

    setState(() => _updating = true);

    try {
      if (!await checkInputsAvailbility()) {
        setState(() => _updating = false);

        context.showErrorBar(
          content: Text("email_not_available".tr()),
        );

        return;
      }

      final response =
          await ref.read(AppState.userProvider.notifier).updateEmail(
                newEmail: _newEmail,
                password: password,
              );

      if (!response.success) {
        throw ErrorDescription(response.error?.message ?? '');
      }

      setState(() {
        _updating = false;
        _completed = true;
      });
    } catch (error) {
      Utilities.logger.e(error);
      setState(() => _updating = false);

      context.showErrorBar(
        content: Text("email_update_error".tr()),
      );
    }
  }
}
