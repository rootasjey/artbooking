import 'package:artbooking/globals/utilities.dart';
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
          onPressed: () => Utilities.navigation.back(context),
          icon: Icon(UniconsLine.arrow_left),
        ),
      ],
    );
  }
}
