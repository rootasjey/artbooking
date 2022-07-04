import 'package:artbooking/components/icons/app_icon.dart';
import 'package:artbooking/components/application_bar/middle_section/application_bar_middle_desktop.dart';
import 'package:artbooking/components/application_bar/user_section/application_bar_auth_user.dart';
import 'package:artbooking/components/application_bar/user_section/application_bar_guest_user.dart';
import 'package:artbooking/router/locations/home_location.dart';
import 'package:artbooking/globals/app_state.dart';
import 'package:artbooking/globals/state/user_notifier.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/user/user.dart';
import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ApplicationBar extends ConsumerWidget {
  ApplicationBar({
    this.padding = const EdgeInsets.only(top: 30.0),
    this.minimal = false,
    this.showSearch = true,
  });

  /// If true, will show a search button.
  /// Otherwise, the search button will be hidden.
  final bool showSearch;
  final EdgeInsets padding;

  /// If true, will only display right section with search, language, & avatar.
  final bool minimal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isMobileSize = Utilities.size.isMobileSize(context);

    final User userProvider = ref.watch(AppState.userProvider);
    final UserNotifier userNotifier = ref.read(AppState.userProvider.notifier);

    final String? avatarUrl = userProvider.firestoreUser?.getProfilePicture();
    final String initials = userNotifier.getInitialsUsername();

    return SliverPadding(
      padding: padding,
      sliver: SliverAppBar(
        floating: true,
        snap: true,
        pinned: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: EdgeInsets.only(
            top: 12.0,
            left: isMobileSize ? 12.0 : 48.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              AppIcon(size: 32.0),
              if (!minimal) mainSection(isMobileSize),
              userSection(
                context,
                ref: ref,
                isMobileSize: isMobileSize,
                minimal: minimal,
                isAuthenticated: userNotifier.isAuthenticated,
                initials: initials,
                avatarUrl: avatarUrl ?? "",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget mainSection(bool compact) {
    if (compact) {
      return Container();
    }

    return ApplicationBarMiddleDesktop();
  }

  Widget userSection(
    BuildContext context, {
    bool minimal = false,
    bool isAuthenticated = false,
    required WidgetRef ref,
    String initials = "",
    String avatarUrl = "",
    bool isMobileSize = false,
  }) {
    if (isAuthenticated) {
      final EdgeInsets margin = isMobileSize
          ? const EdgeInsets.only(top: 5.0, right: 0.0)
          : const EdgeInsets.only(top: 5.0, right: 30.0);

      return ApplicationBarAuthUser(
        isMobileSize: isMobileSize,
        avatarInitials: initials,
        avatarURL: avatarUrl,
        showSearch: showSearch,
        margin: margin,
        onSignOut: () => onSignOut(context, ref),
      );
    }

    return ApplicationBarGuestUser();
  }

  void onSignOut(BuildContext context, WidgetRef ref) async {
    final UserNotifier user = ref.read(AppState.userProvider.notifier);
    await user.signOut();
    Beamer.of(context, root: true).beamToNamed(HomeLocation.route);
  }
}
