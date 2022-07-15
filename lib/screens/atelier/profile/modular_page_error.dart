import 'package:artbooking/components/application_bar/application_bar.dart';
import 'package:artbooking/components/error_view.dart';
import 'package:artbooking/types/enums/enum_page_type.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ModularPageError extends StatelessWidget {
  const ModularPageError({
    Key? key,
    this.isMobileSize = false,
    required this.pageType,
    this.onTryFetchPage,
  }) : super(key: key);

  final bool isMobileSize;
  final EnumPageType pageType;
  final void Function()? onTryFetchPage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          ApplicationBar(),
          ErrorView(
            subtitle: "try_again_later".tr(),
            title: pageType == EnumPageType.profile
                ? "profile_page_loading_error".tr()
                : "home_loading_error".tr(),
            onReload: onTryFetchPage,
          ),
        ],
      ),
    );
  }
}
