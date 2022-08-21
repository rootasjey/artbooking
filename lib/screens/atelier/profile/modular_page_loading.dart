import 'package:artbooking/components/loading_view.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/enums/enum_page_type.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ModularPageLoading extends StatelessWidget {
  const ModularPageLoading({
    Key? key,
    required this.pageType,
  }) : super(key: key);

  final EnumPageType pageType;

  @override
  Widget build(BuildContext context) {
    final String loadingText = pageType == EnumPageType.profile
        ? "profile_page_loading".tr() + "..."
        : "loading".tr();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: LoadingView(
          sliver: false,
          title: Center(
            child: Opacity(
              opacity: 0.8,
              child: Text(
                loadingText,
                textAlign: TextAlign.center,
                style: Utilities.fonts.body4(
                  fontSize: 24.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
