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
    final bool isMobileSize = Utilities.size.isMobileSize(context);

    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.only(top: isMobileSize ? 54.0 : 0.0),
        child: Column(
          children: [
            LottieBuilder.asset(
              "assets/animations/whale.json",
              width: isMobileSize ? 200.0 : 500.0,
              height: isMobileSize ? 200.0 : 500.0,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: Utilities.fonts.body(
                  fontSize: isMobileSize ? 20.0 : 24.0,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).primaryColor.withOpacity(0.9),
                ),
              ),
            ),
            if (subtitle.isNotEmpty)
              InkWell(
                onTap: onReload,
                child: Opacity(
                  opacity: 0.6,
                  child: Text(
                    subtitle,
                    style: Utilities.fonts.body(
                      fontWeight: FontWeight.w700,
                      backgroundColor: Constants.colors.tertiary,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
