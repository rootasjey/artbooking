import 'package:artbooking/components/app_icon.dart';
import 'package:artbooking/components/main_app_bar/main_section_desktop.dart';
import 'package:artbooking/components/main_app_bar/main_section_mobile.dart';
import 'package:artbooking/components/main_app_bar/user_auth_section.dart';
import 'package:artbooking/components/main_app_bar/user_guest_section.dart';
import 'package:artbooking/router/locations/home_location.dart';
import 'package:artbooking/types/globals/state.dart';
import 'package:artbooking/types/globals/user_notifier.dart';
import 'package:artbooking/utils/constants.dart';
import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainAppBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double pageWidth = MediaQuery.of(context).size.width;
    final bool compact = pageWidth < Constants.maxMobileWidth;

    ref.watch(AppState.userProvider);
    final UserNotifier userNotifier = ref.read(AppState.userProvider.notifier);

    final String avatarURL = userNotifier.getPPUrl();
    final String initials = userNotifier.getInitialsUsername();

    return SliverAppBar(
      floating: true,
      snap: true,
      pinned: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      automaticallyImplyLeading: false,
      title: Padding(
        padding: EdgeInsets.only(
          left: compact ? 0.0 : 80.0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            AppIcon(size: 32.0),
            mainSection(compact),
            userSection(
              context,
              ref: ref,
              compact: compact,
              isAuthenticated: userNotifier.isAuthenticated,
              initials: initials,
              avatarURL: avatarURL,
            ),
          ],
        ),
      ),
    );
  }

  Widget mainSection(bool compact) {
    if (compact) {
      return MainSectionMobile();
    }

    return MainSectionDesktop();
  }

  Widget userSection(
    BuildContext context, {
    bool compact = false,
    bool isAuthenticated = false,
    required WidgetRef ref,
    String initials = '',
    String avatarURL = '',
  }) {
    if (isAuthenticated) {
      return UserAuthSection(
        compact: compact,
        avatarInitials: initials,
        avatarURL: avatarURL,
        onSignOut: () => onSignOut(context, ref),
      );
    }

    return UserGuestSection();
  }

  void onSignOut(BuildContext context, WidgetRef ref) async {
    final user = ref.read(AppState.userProvider.notifier);
    await user.signOut();
    Beamer.of(context).beamToNamed(HomeLocation.route);
  }
}
