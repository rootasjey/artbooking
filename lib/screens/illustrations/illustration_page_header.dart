import 'package:artbooking/globals/utilities.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class IllustrationPageHeader extends StatelessWidget {
  const IllustrationPageHeader({
    Key? key,
    required this.show,
  }) : super(key: key);

  /// If true, this widget will be displayed.
  /// This widget will be hidden otherwise.
  final bool show;

  @override
  Widget build(BuildContext context) {
    if (!show) {
      return Container();
    }

    return Row(
      children: [
        IconButton(
          color: Theme.of(context).primaryColor,
          onPressed: () => Utilities.navigation.back(context),
          icon: Icon(UniconsLine.arrow_left),
        ),
      ],
    );
  }
}
