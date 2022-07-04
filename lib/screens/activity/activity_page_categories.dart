import 'package:artbooking/components/square/square_stats.dart';
import 'package:artbooking/types/square_stats_data.dart';
import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';

class ActivityPageCategories extends StatelessWidget {
  const ActivityPageCategories({
    Key? key,
    this.dataList = const [],
    this.isMobileSize = false,
  }) : super(key: key);

  /// If true, will adapt this widget for small screen (responsive).
  final bool isMobileSize;
  final List<SquareStatsData> dataList;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: isMobileSize ? 12.0 : 50.0,
        right: isMobileSize ? 12.0 : 50.0,
        top: 20.0,
      ),
      child: Wrap(
        spacing: isMobileSize ? 6.0 : 16.0,
        runSpacing: isMobileSize ? 6.0 : 16.0,
        alignment: WrapAlignment.start,
        children: dataList.map((item) {
          return SquareStats(
            borderColor: item.borderColor,
            compact: isMobileSize,
            count: item.count,
            textTitle: item.titleValue,
            onTap: item.routePath.isEmpty
                ? null
                : () => Beamer.of(context).beamToNamed(item.routePath),
          );
        }).toList(),
      ),
    );
  }
}
