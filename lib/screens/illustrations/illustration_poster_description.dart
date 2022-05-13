import 'package:artbooking/globals/utilities.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';

class IllustrationPosterDescription extends StatelessWidget {
  const IllustrationPosterDescription({
    Key? key,
    required this.description,
  }) : super(key: key);

  final String description;

  @override
  Widget build(BuildContext context) {
    if (description.isEmpty) {
      return Container();
    }

    return Container(
      width: 500.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "description".tr().toUpperCase(),
            style: Utilities.fonts.body(
              fontSize: 14.0,
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          Divider(),
          Opacity(
            opacity: 0.6,
            child: Text(
              description,
              style: Utilities.fonts.body(
                fontSize: 18.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
