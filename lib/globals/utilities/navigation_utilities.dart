import 'package:artbooking/router/locations/atelier_location.dart';
import 'package:artbooking/router/navigation_state_helper.dart';
import 'package:artbooking/types/illustration/illustration.dart';
import 'package:beamer/beamer.dart';
import 'package:flutter/widgets.dart';

class NavigationUtilities {
  const NavigationUtilities();

  void back(BuildContext context) {
    if (Beamer.of(context).canBeamBack) {
      Beamer.of(context).beamBack();
      return;
    }

    Beamer.of(context).popRoute();
  }

  /// Return hero tag stored as a string from `routeState` map if any.
  String getHeroTag(Object? routeState) {
    if (routeState == null) {
      return "";
    }

    final mapState = routeState as Map<String, dynamic>;
    return mapState["heroTag"] ?? "";
  }

  /// Navigate from a profile page to an illustration page.
  void profileToIllustration(
    BuildContext context, {
    required Illustration illustration,
    required String heroTag,
  }) {
    NavigationStateHelper.illustration = illustration;
    Beamer.of(context).beamToNamed(
      AtelierLocationContent.profileIllustrationRoute.replaceFirst(
        ":illustrationId",
        illustration.id,
      ),
      data: {"illustrationId": illustration.id},
      routeState: {"heroTag": heroTag},
    );
  }
}
