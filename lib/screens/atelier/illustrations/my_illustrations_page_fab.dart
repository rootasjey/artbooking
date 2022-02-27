import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class MyIllustrationsPageFab extends StatelessWidget {
  const MyIllustrationsPageFab({
    Key? key,
    required this.show,
    this.uploadIllustration,
    required this.scrollController,
  }) : super(key: key);

  final bool show;
  final void Function()? uploadIllustration;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    if (!show) {
      return FloatingActionButton(
        onPressed: uploadIllustration,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        child: Icon(UniconsLine.upload),
      );
    }

    return FloatingActionButton(
      onPressed: () {
        scrollController.animateTo(
          0.0,
          duration: Duration(seconds: 1),
          curve: Curves.easeOut,
        );
      },
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      child: Icon(UniconsLine.arrow_up),
    );
  }
}
