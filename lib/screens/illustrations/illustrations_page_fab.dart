import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class IllustrationsPageFab extends StatelessWidget {
  const IllustrationsPageFab({
    Key? key,
    required this.pageScrollController,
    required this.show,
  }) : super(key: key);

  final bool show;
  final ScrollController pageScrollController;

  @override
  Widget build(BuildContext context) {
    if (!show) {
      return Container();
    }

    return FloatingActionButton(
      onPressed: () {
        pageScrollController.animateTo(
          0.0,
          duration: const Duration(seconds: 1),
          curve: Curves.easeOut,
        );
      },
      backgroundColor: Colors.grey.shade900,
      foregroundColor: Colors.white,
      child: Icon(UniconsLine.arrow_up),
    );
  }
}
