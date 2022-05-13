import 'package:artbooking/globals/utilities.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';

class IllustrationPosterStory extends StatelessWidget {
  const IllustrationPosterStory({
    Key? key,
    required this.story,
  }) : super(key: key);

  final String story;

  @override
  Widget build(BuildContext context) {
    if (story.isEmpty) {
      return Container();
    }

    return Container(
      width: 500.0,
      padding: const EdgeInsets.only(top: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "story".tr().toUpperCase(),
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
              story,
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
