import 'package:artbooking/components/icons/app_icon.dart';
import 'package:artbooking/components/application_bar/middle_section/application_bar_middle_desktop.dart';
import 'package:artbooking/components/application_bar/middle_section/application_bar_middle_mobile.dart';
import 'package:artbooking/components/application_bar/user_section/application_bar_auth_user.dart';
import 'package:artbooking/components/application_bar/user_section/application_bar_guest_user.dart';
import 'package:artbooking/router/locations/home_location.dart';
import 'package:artbooking/globals/app_state.dart';
import 'package:artbooking/globals/state/user_notifier.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ApplicationBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool compact = Utilities.size.isMobileSize(context);

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
      return ApplicationBarMiddleMobile();
    }

    return ApplicationBarMiddleDesktop();
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
      return ApplicationBarAuthUser(
        compact: compact,
        avatarInitials: initials,
        avatarURL: avatarURL,
        onSignOut: () => onSignOut(context, ref),
      );
    }

    return ApplicationBarGuestUser();
  }

  void onSignOut(BuildContext context, WidgetRef ref) async {
    final user = ref.read(AppState.userProvider.notifier);
    await user.signOut();
    Beamer.of(context).beamToNamed(HomeLocation.route);
  }
}
