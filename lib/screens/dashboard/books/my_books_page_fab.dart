import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class MyBooksPageFab extends StatelessWidget {
  const MyBooksPageFab({
    Key? key,
    required this.show,
    this.onShowCreateBookDialog,
    required this.scrollController,
  }) : super(key: key);

  final bool show;
  final void Function()? onShowCreateBookDialog;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    if (!show) {
      return FloatingActionButton(
        onPressed: onShowCreateBookDialog,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        child: Icon(UniconsLine.plus),
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
