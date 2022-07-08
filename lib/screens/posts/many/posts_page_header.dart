import 'package:artbooking/components/buttons/dark_outlined_button.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/enums/enum_content_visibility.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';

class PostsPageHeader extends StatelessWidget {
  const PostsPageHeader({
    Key? key,
    required this.selectedTab,
    this.onChangedTab,
    this.isMobileSize = false,
  }) : super(key: key);

  /// If true, this widget adapt its layout to small screens.
  final bool isMobileSize;

  /// Currently selected tab (published or drafts).
  final EnumContentVisibility selectedTab;

  /// Callback fired when selected tab changes.
  final Function(EnumContentVisibility)? onChangedTab;

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
          Opacity(
            opacity: 0.8,
            child: Text(
              "posts".tr(),
              style: Utilities.fonts.body(
                fontSize: 30.0,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Opacity(
            opacity: 0.4,
            child: Text(
              "posts_tab_description".tr(),
              style: Utilities.fonts.body(
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
                  selected: EnumContentVisibility.public == selectedTab,
                  onPressed: onChangedTab != null ? onPressedPublished : null,
                  child: Text("published".tr().toUpperCase()),
                ),
                DarkOutlinedButton(
                  accentColor: Colors.grey,
                  selected: EnumContentVisibility.private == selectedTab ||
                      EnumContentVisibility.acl == selectedTab,
                  onPressed: onChangedTab != null ? onPressedDrafts : null,
                  child: Text("drafts".tr().toUpperCase()),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  void onPressedPublished() {
    onChangedTab?.call(EnumContentVisibility.public);
  }

  void onPressedDrafts() {
    onChangedTab?.call(EnumContentVisibility.private);
  }
}
