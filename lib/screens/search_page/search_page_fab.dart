import 'package:flutter/material.dart';

class SearchPageFab extends StatelessWidget {
  const SearchPageFab({
    Key? key,
    required this.show,
    this.onTabFab,
  }) : super(key: key);

  /// Show this widget if true. Otherwise display an empty `Container`.
  final bool show;

  /// Callback fired when this widget is tapped.
  final void Function()? onTabFab;

  @override
  Widget build(BuildContext context) {
    if (!show) {
      return Container();
    }

    return FloatingActionButton(
      onPressed: onTabFab,
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      child: Icon(Icons.arrow_upward),
    );
  }
}
