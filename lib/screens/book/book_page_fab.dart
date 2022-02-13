import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class BookPageFab extends StatelessWidget {
  const BookPageFab({
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
