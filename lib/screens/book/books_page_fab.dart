import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class BooksPageFab extends StatelessWidget {
  const BooksPageFab({
    Key? key,
    required this.show,
    this.onPressed,
  }) : super(key: key);

  final bool show;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    if (!show) {
      return Container();
    }

    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      child: Icon(UniconsLine.arrow_up),
    );
  }
}
