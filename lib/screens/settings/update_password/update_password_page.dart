import 'package:artbooking/components/application_bar/application_bar.dart';
import 'package:artbooking/globals/app_state.dart';
import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/screens/settings/update_password/update_password_page_body.dart';
import 'package:artbooking/screens/settings/update_password/update_password_page_header.dart';
import 'package:artbooking/types/dialog_return_value.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flash/src/flash_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UpdatePasswordPage extends ConsumerStatefulWidget {
  @override
  _UpdatePasswordPageState createState() => _UpdatePasswordPageState();
}

class _UpdatePasswordPageState extends ConsumerState<UpdatePasswordPage> {
  /// The password has been successfully updated if true.
  bool _completed = false;

  /// The password is currently being updated if true.
  bool _updating = false;

  @override
  Widget build(BuildContext context) {
    final bool isMobileSize = Utilities.size.isMobileSize(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          ApplicationBar(),
          UpdatePasswordPageHeader(
            isMobileSize: isMobileSize,
          ),
          UpdatePasswordPageBody(
            beginY: 10.0,
            isMobileSize: isMobileSize,
            updating: _updating,
            completed: _completed,
            onShowTipsDialog: onShowTipsDialog,
            onTryUpdatePassword: onTryUpdatePassword,
          ),
        ],
      ),
    );
  }

  Widget bulletPoint({required String textValue}) {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: Row(
        children: [
          Utilities.fonts.coloredDot(),
          Expanded(
            child: Opacity(
              opacity: 0.6,
              child: Text(
                textValue,
                style: Utilities.fonts.body(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool checkInputs(String currentPassword, String newPassword) {
    if (currentPassword.isEmpty) {
      context.showErrorBar(
        content: Text("password_empty_forbidden".tr()),
      );

      return false;
    }

    if (newPassword.isEmpty) {
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
        return SimpleDialog(
          backgroundColor: Constants.colors.clairPink,
          title: Text(
            "password_tips".tr(),
            style: Utilities.fonts.title3(
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          children: <Widget>[
            Divider(
              color: Theme.of(context).secondaryHeaderColor,
              thickness: 2.0,
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 10.0,
                left: 25.0,
                right: 25.0,
                bottom: 25.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  bulletPoint(textValue: "password_tips_1".tr()),
                  bulletPoint(textValue: "password_tips_2".tr()),
                  bulletPoint(textValue: "password_tips_3".tr()),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void onTryUpdatePassword(String currentPassword, String newPassword) async {
    if (!checkInputs(currentPassword, newPassword)) {
      return;
    }

    setState(() => _updating = true);

    try {
      final DialogReturnValue<String> result =
          await ref.read(AppState.userProvider.notifier).updatePassword(
                currentPassword: currentPassword,
                newPassword: newPassword,
              );

      if (result.validated) {
        setState(() {
          _updating = false;
          _completed = true;
        });
        return;
      }

      setState(() {
        _updating = false;
        _completed = false;
      });

      context.showErrorBar(
        content: Text(result.value),
      );
    } catch (error) {
      Utilities.logger.e(error);
      setState(() {
        _updating = false;
        _completed = false;
      });

      context.showErrorBar(
        content: Text("password_update_error".tr()),
      );
    }
  }
}
