import 'package:artbooking/components/buttons/circle_button.dart';
import 'package:artbooking/components/icons/app_icon.dart';
import 'package:artbooking/router/locations/home_location.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicons/unicons.dart';

class ProfileApplicationBar extends ConsumerWidget {
  ProfileApplicationBar({
    required this.title,
    this.padding = const EdgeInsets.only(top: 30.0),
    this.minimal = false,
  });

  final EdgeInsets padding;

  /// If true, will only display right section with search, language, & avatar.
  final bool minimal;

  /// A widget to show on the app bar. Typically a Text widget.
  final Widget title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isMobileSize = Utilities.size.isMobileSize(context);

    final String? location = Beamer.of(context)
        .beamingHistory
        .last
        .history
        .last
        .routeInformation
        .location;

    final bool hasHistory = location != HomeLocation.route;

    return SliverPadding(
      padding: padding,
      sliver: SliverAppBar(
        floating: true,
        snap: true,
        pinned: false,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: EdgeInsets.only(
            top: 16.0,
            left: isMobileSize ? 0.0 : 48.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  if (hasHistory)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: CircleButton.outlined(
                        onTap: () => Utilities.navigation.back(
                          context,
                          isMobile: isMobileSize,
                        ),
                        child: Icon(
                          UniconsLine.arrow_left,
                          color: Theme.of(context).textTheme.bodyText2?.color,
                        ),
                      ),
                    ),
                  AppIcon(size: 32.0),
                  title,
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
