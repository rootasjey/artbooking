import 'package:artbooking/components/buttons/dark_outlined_button.dart';
import 'package:artbooking/components/texts/page_title.dart';
import 'package:artbooking/types/enums/enum_like_type.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';

class LikesPageHeader extends StatelessWidget {
  const LikesPageHeader({
    Key? key,
    required this.selectedTab,
    this.onChangedTab,
    this.isMobileSize = false,
  }) : super(key: key);

  /// If true, this widget adapt its layout to small screens.
  final bool isMobileSize;

  /// Current tab selected (illustration or books).
  final EnumLikeType selectedTab;

  /// Callback fired when changing tab.
  final Function(EnumLikeType)? onChangedTab;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.only(
        top: isMobileSize ? 24.0 : 60.0,
        left: isMobileSize ? 12.0 : 54.0,
        bottom: 24.0,
      ),
      sliver: SliverList(
        delegate: SliverChildListDelegate.fixed([
          PageTitle(
            renderSliver: false,
            titleValue: "likes".tr(),
            subtitleValue: "like_tab_description".tr(),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Wrap(
              spacing: 12.0,
              runSpacing: 12.0,
              children: [
                DarkOutlinedButton(
                  selected: EnumLikeType.illustration == selectedTab,
                  onPressed:
                      onChangedTab != null ? onPressedIllustration : null,
                  child: Text("illustrations".tr().toUpperCase()),
                ),
                DarkOutlinedButton(
                  selected: EnumLikeType.book == selectedTab,
                  onPressed: onChangedTab != null ? onPressedBook : null,
                  child: Text("books".tr().toUpperCase()),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  void onPressedBook() {
    onChangedTab?.call(EnumLikeType.book);
  }

  void onPressedIllustration() {
    onChangedTab?.call(EnumLikeType.illustration);
  }
}
