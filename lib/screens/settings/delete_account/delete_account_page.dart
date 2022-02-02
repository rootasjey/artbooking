import 'package:artbooking/components/dialogs/themed_dialog.dart';
import 'package:artbooking/components/application_bar/application_bar.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/screens/settings/delete_account/delete_account_page_body.dart';
import 'package:artbooking/screens/settings/delete_account/delete_account_page_header.dart';
import 'package:artbooking/types/cloud_functions/cloud_functions_response.dart';
import 'package:artbooking/globals/app_state.dart';
import 'package:beamer/beamer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash/src/flash_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsPageDeleteAccount extends ConsumerStatefulWidget {
  @override
  DeleteAccountPageState createState() => DeleteAccountPageState();
}

class DeleteAccountPageState extends ConsumerState<SettingsPageDeleteAccount> {
  bool _deleting = false;
  bool _completed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          ApplicationBar(),
          DeleteAccountPageHeader(),
          DeleteAccountPageBody(
            beginY: 10.0,
            completed: _completed,
            deleting: _deleting,
            onShowTipsDialog: onShowTipsDialog,
            onTryDeleteAccount: onTryDeleteAccount,
          ),
        ],
      ),
    );
  }

  bool checkInputs(String password) {
    if (password.isEmpty) {
      context.showErrorBar(
        content: Text("password_empty_forbidden".tr()),
      );

      return false;
    }

    return true;
  }

  void onShowTipsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return ThemedDialog(
          title: Opacity(
            opacity: 0.6,
            child: Text(
              "account_deletion_after".tr().toUpperCase(),
              style: Utilities.fonts.style(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Opacity(
              opacity: 0.6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "• " + "account_deletion_point_1".tr(),
                    style: Utilities.fonts.style(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Padding(padding: const EdgeInsets.only(top: 15.0)),
                  Text(
                    "• " + "account_deletion_point_2".tr(),
                    style: Utilities.fonts.style(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          onCancel: Beamer.of(context).popRoute,
          onValidate: Beamer.of(context).popRoute,
          textButtonValidation: "alright_exclamation".tr(),
        );
      },
    );
  }

  void onTryDeleteAccount(String password) async {
    if (!checkInputs(password)) {
      return;
    }

    setState(() => _deleting = true);

    try {
      final authUser = ref.read(AppState.userProvider).authUser;

      if (authUser == null) {
        throw ErrorDescription("user_not_connected".tr());
      }

      final credentials = EmailAuthProvider.credential(
        email: authUser.email ?? '',
        password: password,
      );

      await authUser.reauthenticateWithCredential(credentials);
      final idToken = await authUser.getIdToken();

      final CloudFunctionsResponse response =
          await ref.read(AppState.userProvider.notifier).deleteAccount(
                idToken,
              );

      if (response.success) {
        setState(() {
          _deleting = false;
          _completed = true;
        });
        return;
      }

      setState(() {
        _completed = false;
        _deleting = false;
      });

      context.showErrorBar(
        content: Text(
          response.error?.message ?? "account_delete_error".tr(),
        ),
      );
    } catch (error) {
      Utilities.logger.e(error);
      setState(() {
        _completed = false;
        _deleting = false;
      });

      context.showErrorBar(
        content: Text(error.toString()),
      );
    }
  }
}
