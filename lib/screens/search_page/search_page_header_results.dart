import 'package:artbooking/globals/utilities.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class SearchPageHeaderResults extends StatelessWidget {
  const SearchPageHeaderResults({
    Key? key,
    required this.show,
    required this.resultCount,
  }) : super(key: key);

  /// Show this widget if true. Otherwise display an empty `Container`.
  final bool show;

  /// Number of search result items.
  final int resultCount;

  @override
  Widget build(BuildContext context) {
    if (!show) {
      return Container();
    }

    return Padding(
      padding: const EdgeInsets.only(left: 6.0, top: 40.0),
      child: Opacity(
        opacity: 1.0,
        child: Text(
          "search_result_count".tr(args: [resultCount.toString()]),
          style: Utilities.fonts.body4(
            fontSize: 32.0,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
