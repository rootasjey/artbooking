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
    this.onGoToDeleteAccount,
    this.onGoToUpdatePasssword,
    this.onGoToUpdateUsername,
    this.onGoToUpdateEmail,
    this.onEditLocation,
    this.onEditBio,
  }) : super(key: key);

  final UserFirestore userFirestore;
  final void Function()? onGoToDeleteAccount;
  final void Function()? onGoToUpdatePasssword;
  final void Function()? onGoToUpdateUsername;
  final void Function()? onGoToUpdateEmail;
  final void Function()? onEditLocation;
  final void Function()? onEditBio;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double width = MediaQuery.of(context).size.width;
    final bool expanded = ref.watch(AppState.dashboardSideMenuOpenProvider);
    final bool compact = width < 1400.0 && expanded;

    int index = 0;

    final List<Widget> children = [
      AtelierPageCard(
        compact: compact,
        hoverColor: Constants.colors.activity,
        iconData: UniconsLine.space_key,
        textTitle: "username".tr(),
        textSubtitle: userFirestore.name,
        onTap: onGoToUpdateUsername,
      ),
      AtelierPageCard(
        compact: compact,
        hoverColor: Constants.colors.email,
        iconData: UniconsLine.envelope,
        textTitle: "email".tr(),
        textSubtitle: userFirestore.email,
        onTap: onGoToUpdateEmail,
      ),
      AtelierPageCard(
        compact: compact,
        hoverColor: Constants.colors.location,
        iconData: UniconsLine.location_point,
        textTitle: "location".tr(),
        textSubtitle: userFirestore.location,
        onTap: onEditLocation,
      ),
      AtelierPageCard(
        compact: compact,
        hoverColor: Constants.colors.bio,
        iconData: UniconsLine.subject,
        textTitle: "bio".tr(),
        textSubtitle: userFirestore.bio,
        onTap: onEditBio,
      ),
      AtelierPageCard(
        compact: compact,
        hoverColor: Constants.colors.password,
        iconData: UniconsLine.lock,
        textTitle: "security".tr(),
        textSubtitle: "password_update".tr(),
        onTap: onGoToUpdatePasssword,
      ),
      AtelierPageCard(
        compact: compact,
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

    return Expanded(
      child: Wrap(
        spacing: 12.0,
        runSpacing: 12.0,
        children: children,
      ),
    );
  }
}
