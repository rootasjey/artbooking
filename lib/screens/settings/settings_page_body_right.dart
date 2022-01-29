import 'package:artbooking/globals/app_state.dart';
import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/screens/dashboard/dashboard_page_card.dart';
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
    this.onEditSummary,
  }) : super(key: key);

  final UserFirestore userFirestore;
  final void Function()? onGoToDeleteAccount;
  final void Function()? onGoToUpdatePasssword;
  final void Function()? onGoToUpdateUsername;
  final void Function()? onGoToUpdateEmail;
  final void Function()? onEditLocation;
  final void Function()? onEditSummary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double width = MediaQuery.of(context).size.width;
    final bool expanded = ref.watch(AppState.dashboardSideMenuOpenProvider);
    final bool compact = width < 1400.0 && expanded;

    return Expanded(
      child: Wrap(
        spacing: 12.0,
        runSpacing: 12.0,
        children: [
          DashbordPageCard(
            compact: compact,
            hoverColor: Constants.colors.activity,
            iconData: UniconsLine.space_key,
            textTitle: "username".tr(),
            textSubtitle: userFirestore.name,
            onTap: onGoToUpdateUsername,
          ),
          DashbordPageCard(
            compact: compact,
            hoverColor: Constants.colors.email,
            iconData: UniconsLine.envelope,
            textTitle: "email".tr(),
            textSubtitle: userFirestore.email,
            onTap: onGoToUpdateEmail,
          ),
          DashbordPageCard(
            compact: compact,
            hoverColor: Constants.colors.location,
            iconData: UniconsLine.location_point,
            textTitle: "location".tr(),
            textSubtitle: userFirestore.location,
            onTap: onEditLocation,
          ),
          DashbordPageCard(
            compact: compact,
            hoverColor: Constants.colors.summary,
            iconData: UniconsLine.subject,
            textTitle: "summary".tr(),
            textSubtitle: userFirestore.summary,
            onTap: onEditSummary,
          ),
          DashbordPageCard(
            compact: compact,
            hoverColor: Constants.colors.password,
            iconData: UniconsLine.lock,
            textTitle: "security".tr(),
            textSubtitle: "password_update".tr(),
            onTap: onGoToUpdatePasssword,
          ),
          DashbordPageCard(
            compact: compact,
            hoverColor: Constants.colors.delete,
            iconData: UniconsLine.trash,
            textTitle: "security".tr(),
            textSubtitle: "account_delete".tr(),
            onTap: onGoToDeleteAccount,
          ),
        ],
      ),
    );
  }
}
