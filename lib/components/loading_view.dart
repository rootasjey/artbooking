import 'package:artbooking/components/animated_app_icon.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class LoadingView extends StatelessWidget {
  final String title;
  final EdgeInsets padding;

  LoadingView({
    this.title = 'Loading...',
    this.padding = const EdgeInsets.all(60.0),
  });

  @override
  Widget build(BuildContext context) {
    String loadingText = title.isNotEmpty ? title : "loading".tr();

    return Padding(
      padding: padding,
      child: Column(
        children: [
          AnimatedAppIcon(),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Opacity(
              opacity: 0.6,
              child: Text(
                loadingText,
                style: TextStyle(
                  fontSize: 25.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
