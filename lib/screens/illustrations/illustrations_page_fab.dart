import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class IllustrationsPageFab extends StatelessWidget {
  const IllustrationsPageFab({
    Key? key,
    required this.show,
    required this.scrollController,
  }) : super(key: key);

  final bool show;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        scrollController.animateTo(
          0.0,
          duration: const Duration(seconds: 1),
          curve: Curves.easeOut,
        );
      },
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      child: Icon(UniconsLine.arrow_up),
    );
  }
}
