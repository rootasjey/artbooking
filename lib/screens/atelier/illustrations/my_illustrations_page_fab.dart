import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class MyIllustrationsPageFab extends StatelessWidget {
  const MyIllustrationsPageFab({
    Key? key,
    required this.show,
    required this.scrollController,
    this.uploadIllustration,
    this.isOwner = false,
  }) : super(key: key);

  /// Show create book FAB if true.
  final bool isOwner;

  /// Show the scroll to top FAB if true.
  final bool show;

  /// Callback to upload an illustration.
  final void Function()? uploadIllustration;

  /// Page scroll controller to scroll to top.
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    if (show) {
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

    if (isOwner) {
      return FloatingActionButton(
        onPressed: uploadIllustration,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        child: Icon(UniconsLine.upload),
      );
    }

    return Container();
  }
}
