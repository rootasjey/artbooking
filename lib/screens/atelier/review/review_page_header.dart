import 'package:artbooking/components/buttons/dark_outlined_button.dart';
import 'package:artbooking/components/buttons/square_button.dart';
import 'package:artbooking/components/texts/page_title.dart';
import 'package:artbooking/types/enums/enum_tab_data_type.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class ReviewPageHeader extends StatelessWidget {
  const ReviewPageHeader({
    Key? key,
    required this.hideDisapproved,
    required this.selectedTab,
    this.isMobileSize = false,
    this.onChangedTab,
    this.onToggleShowDisapproved,
  }) : super(key: key);

  /// If true, this widget adapt its layout to small screens.
  final bool isMobileSize;

  /// If true, disapproved items (books or illustrations) will be hidden.
  final bool hideDisapproved;

  /// Current selected tab (books or illustrations).
  final EnumTabDataType selectedTab;

  /// Callback fired when the tab changes.
  final void Function(EnumTabDataType)? onChangedTab;

  /// Callback fired when we toggle the [hideDisapproved] value.
  final void Function()? onToggleShowDisapproved;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.only(
        top: isMobileSize ? 42.0 : 60.0,
        left: isMobileSize ? 12.0 : 54.0,
        bottom: 24.0,
      ),
      sliver: SliverList(
        delegate: SliverChildListDelegate.fixed([
          PageTitle(
            isMobileSize: isMobileSize,
            renderSliver: false,
            titleValue: "review".tr(),
            subtitleValue: "review_subtitle".tr(),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Wrap(
              spacing: 12.0,
              runSpacing: 12.0,
              children: [
                DarkOutlinedButton(
                  selected: EnumTabDataType.illustrations == selectedTab,
                  onPressed:
                      onChangedTab != null ? onPressedIllustration : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: Text("illustrations".tr().toUpperCase()),
                  ),
                ),
                DarkOutlinedButton(
                  selected: EnumTabDataType.books == selectedTab,
                  onPressed: onChangedTab != null ? onPressedBook : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: Text("books".tr().toUpperCase()),
                  ),
                ),
                SquareButton(
                  active: hideDisapproved,
                  message: hideDisapproved
                      ? "review_show_disapproved".tr()
                      : "review_hide_disapproved".tr(),
                  onTap: onToggleShowDisapproved,
                  opacity: hideDisapproved ? 1.0 : 0.4,
                  child: Icon(
                    UniconsLine.eye_slash,
                    color: hideDisapproved ? Colors.white : null,
                  ),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  void onPressedBook() {
    onChangedTab?.call(EnumTabDataType.books);
  }

  void onPressedIllustration() {
    onChangedTab?.call(EnumTabDataType.illustrations);
  }
}
