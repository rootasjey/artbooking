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
    required this.selectedTab,
    this.onChangedTab,
    required this.hideDisapproved,
    this.onUpdateShowHidden,
  }) : super(key: key);

  final bool hideDisapproved;
  final EnumTabDataType selectedTab;

  final void Function(EnumTabDataType)? onChangedTab;
  final void Function()? onUpdateShowHidden;

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
          PageTitle(
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
                  onTap: onUpdateShowHidden,
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
