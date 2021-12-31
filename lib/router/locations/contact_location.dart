import 'package:artbooking/screens/contact_page.dart';
import 'package:beamer/beamer.dart';
import 'package:flutter/widgets.dart';

class ContactLocation extends BeamLocation<BeamState> {
  /// Main root value for this location.
  static const String route = '/contact';

  @override
  List<String> get pathPatterns => [route];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    return [
      BeamPage(
        child: ContactPage(),
        key: ValueKey(route),
        title: "Contact",
        type: BeamPageType.fadeTransition,
      ),
    ];
  }
}
