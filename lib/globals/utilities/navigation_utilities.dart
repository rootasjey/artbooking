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
}
