import 'package:artbooking/components/buttons/dark_outlined_button.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/enums/enum_like_type.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';

class LikesPageHeader extends StatelessWidget {
  const LikesPageHeader({
    Key? key,
    required this.selectedTab,
    this.onChangedTab,
  }) : super(key: key);

  final EnumLikeType selectedTab;
  final Function(EnumLikeType)? onChangedTab;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(
        top: 60.0,
        left: 54.0,
        bottom: 24.0,
      ),
      sliver: SliverList(
        delegate: SliverChildListDelegate.fixed([
          Opacity(
            opacity: 0.8,
            child: Text(
              "likes".tr(),
              style: Utilities.fonts.style(
                fontSize: 30.0,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Opacity(
            opacity: 0.4,
            child: Text(
              "like_tab_description".tr(),
              style: Utilities.fonts.style(
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
              ),
            ),
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
