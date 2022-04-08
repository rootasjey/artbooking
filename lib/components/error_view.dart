import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ErrorView extends StatelessWidget {
  const ErrorView({
    Key? key,
    required this.title,
    this.subtitle = "",
    this.onReload,
  }) : super(key: key);

  final String title;
  final String subtitle;
  final void Function()? onReload;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          LottieBuilder.asset(
            "assets/animations/whale.json",
            width: 500.0,
            height: 500.0,
          ),
          Text(
            title,
            style: Utilities.fonts.style(
              fontSize: 24.0,
              fontWeight: FontWeight.w400,
              color: Theme.of(context).primaryColor.withOpacity(0.9),
            ),
          ),
          if (subtitle.isNotEmpty)
            InkWell(
              onTap: onReload,
              child: Opacity(
                opacity: 0.6,
                child: Text(
                  subtitle,
                  style: Utilities.fonts.style(
                    fontWeight: FontWeight.w700,
                    backgroundColor: Constants.colors.tertiary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
