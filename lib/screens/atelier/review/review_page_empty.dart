import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/enums/enum_tab_data_type.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class ReviewPageEmpty extends StatelessWidget {
  const ReviewPageEmpty({
    Key? key,
    required this.selectedTab,
  }) : super(key: key);

  final EnumTabDataType selectedTab;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(
          top: 40.0,
          left: 76.0,
          bottom: 100.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 6.0),
              child: Opacity(
                opacity: 0.8,
                child: Icon(
                  UniconsLine.no_entry,
                  size: 60.0,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 6.0),
              child: Text(
                selectedTab == EnumTabDataType.books
                    ? "review_book_empty".tr()
                    : "review_illustration_empty".tr(),
                style: Utilities.fonts.body(
                  fontSize: 26.0,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            Opacity(
              opacity: 0.4,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    selectedTab == EnumTabDataType.books
                        ? "review_book_empty_subtitle".tr()
                        : "review_illustration_empty_subtitle".tr(),
                    style: Utilities.fonts.body(
                      fontSize: 16.0,
                    ),
                  ),
                  Icon(UniconsLine.arrow_right),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
