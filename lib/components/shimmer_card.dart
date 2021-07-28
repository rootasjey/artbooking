import 'package:artbooking/state/colors.dart';
import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:supercharged/supercharged.dart';

/// A shimmer card for loading purpose and quick usage.
class ShimmerCard extends StatelessWidget {
  const ShimmerCard({
    Key? key,
    this.width = 220.0,
    this.height = 220.0,
    this.elevation = 3.0,
  }) : super(key: key);

  /// The card's width. Default to [220.0].
  final double width;

  /// The card's height. Default to [220.0].
  final double height;

  /// The card's elevation. Default to [3.0].
  final double elevation;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Card(
        color: stateColors.clairPink,
        elevation: elevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        clipBehavior: Clip.hardEdge,
        child: Shimmer(
          color: stateColors.primary,
          duration: 2.seconds,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Stack(
              children: [],
            ),
          ),
        ),
      ),
    );
  }
}
