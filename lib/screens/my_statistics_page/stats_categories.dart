import 'package:artbooking/components/square_stats.dart';
import 'package:artbooking/types/square_stats_data.dart';
import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';

class StatsCategories extends StatelessWidget {
  const StatsCategories({
    Key? key,
    this.dataList = const [],
  }) : super(key: key);

  final List<SquareStatsData> dataList;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 50.0,
        right: 50.0,
        top: 20.0,
      ),
      child: Wrap(
        spacing: 16.0,
        runSpacing: 16.0,
        alignment: WrapAlignment.start,
        children: dataList.map((item) {
          return SquareStats(
            borderColor: item.borderColor,
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
