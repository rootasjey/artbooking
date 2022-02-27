import 'package:artbooking/components/buttons/dark_elevated_button.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/enums/enum_visibility_tab.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicons/unicons.dart';

class MyIllustrationsPageEmpty extends ConsumerWidget {
  const MyIllustrationsPageEmpty({
    Key? key,
    required this.selectedTab,
    this.uploadIllustration,
    this.onGoToActiveTab,
    this.limitThreeInRow = false,
  }) : super(key: key);

  final bool limitThreeInRow;
  final EnumVisibilityTab selectedTab;
  final void Function()? uploadIllustration;
  final void Function()? onGoToActiveTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    EdgeInsets padding = const EdgeInsets.only(
      top: 40.0,
      left: 54.0,
      bottom: 100.0,
    );

    if (limitThreeInRow) {
      padding = const EdgeInsets.only(
        top: 40.0,
        left: 120.0,
        bottom: 100.0,
      );
    }
    return SliverToBoxAdapter(
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Opacity(
              opacity: 0.8,
              child: Icon(
                UniconsLine.no_entry,
                size: 60.0,
              ),
            ),
            Stack(
              children: [
                Positioned(
                  bottom: 6.0,
                  left: 0.0,
                  right: 0.0,
                  child: SizedBox(
                    height: 8.0,
                    child: Container(
                      color: Colors.pink.withOpacity(0.4),
                    ),
                  ),
                ),
                Text(
                  selectedTab == EnumVisibilityTab.active
                      ? "illustrations_my_empty".tr()
                      : "illustrations_my_empty_archived".tr(),
                  style: Utilities.fonts.style(
                    fontSize: 26.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Container(
              width: 500.0,
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Opacity(
                opacity: 0.4,
                child: Text(
                  selectedTab == EnumVisibilityTab.active
                      ? "illustrations_my_empty_subtitle".tr()
                      : "illustrations_my_empty_archived_subtitle".tr(),
                  style: Utilities.fonts.style(
                    fontSize: 16.0,
                  ),
                ),
              ),
            ),
            if (selectedTab == EnumVisibilityTab.active)
              DarkElevatedButton.large(
                onPressed: uploadIllustration,
                child: Text("upload".tr()),
              )
            else
              DarkElevatedButton.large(
                onPressed: onGoToActiveTab,
                child: Text("illustrations_go_to_active".tr()),
              ),
          ],
        ),
      ),
    );
  }
}
