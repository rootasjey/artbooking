import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class IllustrationPageHeader extends StatelessWidget {
  const IllustrationPageHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          color: Theme.of(context).primaryColor,
          onPressed: Beamer.of(context).popRoute,
          icon: Icon(UniconsLine.arrow_left),
        ),
      ],
    );
  }
}
