import 'package:artbooking/components/animations/fade_in_y.dart';
import 'package:artbooking/globals/app_state.dart';
import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/screens/atelier/atelier_page_card.dart';
import 'package:artbooking/types/user/user_firestore.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicons/unicons.dart';

class SettingsPageBodyRight extends ConsumerWidget {
  const SettingsPageBodyRight({
    Key? key,
    required this.userFirestore,
    this.isMobileSize = false,
    this.windowWidth = 0.0,
    this.onEditBio,
    this.onEditLocation,
    this.onGoToDeleteAccount,
    this.onGoToUpdatePasssword,
    this.onGoToUpdateUsername,
    this.onGoToUpdateEmail,
  }) : super(key: key);

  /// If true, this widget adapt its layout to small screens.
  final bool isMobileSize;

  /// App window's width.
  final double windowWidth;

  /// Callback fired to edit our biography.
  final void Function()? onEditBio;

  /// Callback fired when we tap on the profile picture.
  final void Function()? onEditLocation;

  /// Callback fired to navigate to account deletion.
  final void Function()? onGoToDeleteAccount;

  /// Callback fired to navigate to password update page.
  final void Function()? onGoToUpdatePasssword;

  /// Callback fired to navigate to username update page.
  final void Function()? onGoToUpdateUsername;

  /// Callback fired to navigate to email update page.
  final void Function()? onGoToUpdateEmail;

  /// Current authenticated user.
  final UserFirestore userFirestore;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool expanded = ref.watch(AppState.dashboardSideMenuOpenProvider);
    bool compact = windowWidth < 1400.0 && expanded;

    if (isMobileSize) {
      compact = false;
    }

    final double elevation = windowWidth < 1400.0 ? 0.0 : 2.0;
    final bool isWide = windowWidth < 1400.0;

    int index = 0;

    final List<Widget> children = [
      AtelierPageCard(
        compact: compact,
        isWide: isWide,
        elevation: elevation,
        hoverColor: Constants.colors.activity,
        iconData: UniconsLine.space_key,
        textTitle: "username".tr(),
        textSubtitle: userFirestore.name,
        onTap: onGoToUpdateUsername,
      ),
      AtelierPageCard(
        compact: compact,
        isWide: isWide,
        elevation: elevation,
        hoverColor: Constants.colors.email,
        iconData: UniconsLine.envelope,
        textTitle: "email".tr(),
        textSubtitle: userFirestore.email,
        onTap: onGoToUpdateEmail,
      ),
      AtelierPageCard(
        compact: compact,
        isWide: isWide,
        elevation: elevation,
        hoverColor: Constants.colors.location,
        iconData: UniconsLine.location_point,
        textTitle: "location".tr(),
        textSubtitle: userFirestore.location,
        onTap: onEditLocation,
      ),
      AtelierPageCard(
        compact: compact,
        isWide: isWide,
        elevation: elevation,
        hoverColor: Constants.colors.bio,
        iconData: UniconsLine.subject,
        textTitle: "bio".tr(),
        textSubtitle: userFirestore.bio,
        onTap: onEditBio,
      ),
      AtelierPageCard(
        compact: compact,
        isWide: isWide,
        elevation: elevation,
        hoverColor: Constants.colors.password,
        iconData: UniconsLine.lock,
        textTitle: "security".tr(),
        textSubtitle: "password_update".tr(),
        onTap: onGoToUpdatePasssword,
      ),
      AtelierPageCard(
        compact: compact,
        isWide: isWide,
        elevation: elevation,
        hoverColor: Constants.colors.delete,
        iconData: UniconsLine.trash,
        textTitle: "security".tr(),
        textSubtitle: "account_delete".tr(),
        onTap: onGoToDeleteAccount,
      ),
    ].map((child) {
      index++;

      return FadeInY(
        delay: Duration(milliseconds: index * 50),
        beginY: 32.0,
        child: child,
      );
    }).toList();

    if (isMobileSize) {
      return Wrap(
        spacing: 12.0,
        runSpacing: 12.0,
        children: children,
      );
    }

    return Expanded(
      child: Wrap(
        spacing: 12.0,
        runSpacing: 12.0,
        children: children,
      ),
    );
  }
}
