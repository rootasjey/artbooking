import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class LikesPageFab extends StatelessWidget {
  const LikesPageFab({
    Key? key,
    required this.show,
    required this.scrollController,
  }) : super(key: key);

  final bool show;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    if (!show) {
      return Container();
    }

    return FloatingActionButton(
      onPressed: () {
        scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      },
      child: Icon(UniconsLine.arrow_up),
      backgroundColor: Theme.of(context).secondaryHeaderColor,
    );
  }
}
