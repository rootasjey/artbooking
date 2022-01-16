import 'package:artbooking/components/cards/shimmer_card.dart';
import 'package:flutter/material.dart';

class ActivityPageLoadingView extends StatelessWidget {
  const ActivityPageLoadingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate([
        Padding(
          padding: const EdgeInsets.only(
            left: 50.0,
            right: 50.0,
            top: 20.0,
          ),
          child: Wrap(
            spacing: 16.0,
            runSpacing: 16.0,
            alignment: WrapAlignment.start,
            children: <Widget>[
              ShimmerCard(),
              ShimmerCard(),
              ShimmerCard(),
              ShimmerCard(),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            left: 50.0,
            right: 50.0,
            top: 60.0,
            bottom: 100.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerCard(height: 40.0, width: 300.0, elevation: 1.0),
              ShimmerCard(height: 40.0, width: 300.0, elevation: 1.0),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            bottom: 200.0,
          ),
        ),
      ]),
    );
  }
}
