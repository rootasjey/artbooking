import 'dart:async';

import 'package:artbooking/actions/users.dart';
import 'package:artbooking/components/application_bar/application_bar.dart';
import 'package:artbooking/components/dialogs/themed_dialog.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/screens/settings/update_username/update_username_page_body.dart';
import 'package:artbooking/screens/settings/update_username/update_username_page_header.dart';
import 'package:artbooking/types/cloud_functions/cloud_functions_response.dart';
import 'package:artbooking/globals/app_state.dart';
import 'package:artbooking/types/user/user_firestore.dart';
import 'package:beamer/beamer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flash/src/flash_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supercharged/supercharged.dart';

class UpdateUsernamePage extends ConsumerStatefulWidget {
  @override
  _UpdateUsernamePageState createState() => _UpdateUsernamePageState();
}

class _UpdateUsernamePageState extends ConsumerState<UpdateUsernamePage> {
  bool _checkingName = false;
  bool _completed = false;
  bool _isNameAvailable = false;
  bool _updating = false;

  final _pageScrollController = ScrollController();

  String _nameErrorMessage = '';
  String _newUsername = '';
  String _username = '';

  Timer? _nameTimer;

  @override
  Widget build(BuildContext context) {
    final bool isMobileSize = Utilities.size.isMobileSize(context);
    final UserFirestore? firestoureUser =
        ref.watch(AppState.userProvider).firestoreUser;
    if (firestoureUser != null) {
      _username = firestoureUser.name;
    }

    return Scaffold(
      body: CustomScrollView(
        controller: _pageScrollController,
        slivers: <Widget>[
          ApplicationBar(),
          UpdateUsernamePageHeader(
            isMobileSize: isMobileSize,
          ),
          UpdateUsernamePageBody(
            checking: _checkingName,
            completed: _completed,
            isMobileSize: isMobileSize,
            onChanged: onChangedInput,
            updating: _updating,
            onShowTipsDialog: onShowTipsDialog,
            onTryUpdateUsername: onTryUpdateUsername,
            username: _username,
            newUsername: _newUsername,
            nameErrorMessage: _nameErrorMessage,
          ),
        ],
      ),
    );
  }

  bool checkInputs() {
    final isWellFormatted = UsersActions.checkUsernameFormat(_newUsername);

    if (!isWellFormatted) {
      setState(() {
        _checkingName = false;
        _nameErrorMessage = _newUsername.length < 3
            ? "input_minimum_char".tr()
            : "input_valid_format".tr();
      });

      return false;
    }

    return true;
  }

  void onChangedInput(value) async {
    setState(() {
      _newUsername = value;
      _checkingName = true;
    });

    final isWellFormatted = UsersActions.checkUsernameFormat(_newUsername);

    if (!isWellFormatted) {
      setState(() {
        _checkingName = false;
        _nameErrorMessage = _newUsername.length < 3
            ? "input_minimum_char".tr()
            : "input_valid_format".tr();
      });

      return;
    }

    _nameTimer?.cancel();
    _nameTimer = null;

    _nameTimer = Timer(1.seconds, () async {
      _isNameAvailable =
          await UsersActions.checkUsernameAvailability(_newUsername);

      if (!_isNameAvailable) {
        setState(() {
          _checkingName = false;
          _nameErrorMessage = "username_not_available".tr();
        });

        return;
      }

      setState(() {
        _checkingName = false;
        _nameErrorMessage = '';
      });
    });
  }

  void onShowTipsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return ThemedDialog(
          title: Opacity(
            opacity: 0.6,
            child: Text(
              "username_current".tr(),
              style: Utilities.fonts.body(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25.0,
                ),
                child: Opacity(
                  opacity: 0.6,
                  child: Text(
                    _username,
                    style: Utilities.fonts.body(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25.0,
                ),
                child: Opacity(
                  opacity: 0.4,
                  child: Text(
                    "username_choose_description".tr(),
                    style: Utilities.fonts.body(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          textButtonValidation: "alright_exclamation".tr(),
          onCancel: Beamer.of(context).popRoute,
          onValidate: Beamer.of(context).popRoute,
        );
      },
    );
  }

  void onTryUpdateUsername() async {
    if (!checkInputs()) {
      return;
    }

    setState(() => _updating = true);

    try {
      _isNameAvailable = await UsersActions.checkUsernameAvailability(
        _newUsername,
      );

      if (!_isNameAvailable) {
        setState(() {
          _completed = false;
          _updating = false;
        });

        context.showErrorBar(
          content: Text("username_not_available_args".tr(args: [_newUsername])),
        );

        return;
      }

      final CloudFunctionsResponse response =
          await ref.read(AppState.userProvider.notifier).updateUsername(
                _newUsername,
              );

      if (!response.success) {
        final exception = response.error!;

        setState(() {
          _completed = false;
          _updating = false;
        });

        context.showErrorBar(
          content: Text("[code: ${exception.code}] - ${exception.message}"),
        );

        return;
      }

      setState(() {
        _completed = true;
        _updating = false;
        _username = _newUsername;
        _newUsername = '';
      });

      context.showSuccessBar(
        content: Text("username_update_success".tr()),
      );
    } catch (error) {
      Utilities.logger.e(error);

      setState(() {
        _completed = false;
        _updating = false;
      });

      context.showErrorBar(
        content: Text("username_update_error".tr()),
      );
    }
  }
}
