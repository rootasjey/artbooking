import 'package:artbooking/components/animations/fade_in_y.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

/// Aa simple Floating Action Button with an arrow icon as its main content.
/// When pressed, the provided `pageScrollController` will animate to top.
class FabToTop extends StatelessWidget {
  const FabToTop({
    Key? key,
    required this.pageScrollController,
    required this.show,
  }) : super(key: key);

  /// This FAB will be displayed if true.
  /// Otherwise an empty `Container` will be returned.
  final bool show;

  /// This controller will animate to top when pressed on the FAB.
  final ScrollController pageScrollController;

  @override
  Widget build(BuildContext context) {
    if (!show) {
      return Container();
    }

    return FadeInY(
      beginY: 25.0,
      duration: Duration(milliseconds: 250),
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: FloatingActionButton(
          onPressed: () {
            pageScrollController.animateTo(
              0.0,
              duration: Duration(milliseconds: 250),
              curve: Curves.decelerate,
            );
          },
          heroTag: null,
          backgroundColor: Colors.grey.shade900,
          child: Icon(UniconsLine.arrow_up),
        ),
      ),
    );
  }
}
