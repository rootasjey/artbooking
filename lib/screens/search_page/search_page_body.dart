import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/screens/search_page/search_result_card.dart';
import 'package:artbooking/screens/search_page/search_welcome.dart';
import 'package:artbooking/types/enums/enum_search_item_type.dart';
import 'package:artbooking/types/search_result_item.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class SearchPageBody extends StatelessWidget {
  const SearchPageBody({
    Key? key,
    required this.showHeaderResults,
    required this.pageScrollController,
    required this.searching,
    required this.searchFocusNode,
    required this.searchInputController,
    required this.showWelcomePage,
    this.onInputChanged,
    this.onClearInput,
    this.results = const [],
    this.isMobileSize = false,
    this.onTapSearchItem,
  }) : super(key: key);

  /// If true, this widget adapts its size to small screens.
  final bool isMobileSize;

  /// Display welcome search widget if true.
  final bool showWelcomePage;

  /// True if a search request is running.
  final bool searching;

  /// Display results count if true.
  final bool showHeaderResults;

  /// Used to focus search input.
  final FocusNode searchFocusNode;

  /// Search results.
  final List<SearchResultItem> results;

  /// Callback fired to clear search input.
  final void Function()? onClearInput;

  /// Callback fired when search input changes.
  final void Function(String)? onInputChanged;

  /// Callback fired when an item is tapped.
  final void Function(
    EnumSearchItemType searchItemType,
    String id,
  )? onTapSearchItem;

  /// Page scroll controller.
  /// Multiple purpose: show/hide FAB.
  final ScrollController pageScrollController;

  /// Search input controller to follow input changes.
  final TextEditingController searchInputController;

  @override
  Widget build(BuildContext context) {
    if (!showWelcomePage) {
      return SearchWelcome();
    }

    if (results.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Opacity(
            opacity: 0.6,
            child: Text(
              "search_no_result".tr(args: [searchInputController.text]),
              style: Utilities.fonts.body4(
                fontSize: 32.0,
                fontWeight: FontWeight.w200,
              ),
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(12.0),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 160.0,
          childAspectRatio: 0.7,
          mainAxisSpacing: 12.0,
          crossAxisSpacing: 12.0,
        ),
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            final SearchResultItem searchResultItem = results.elementAt(index);

            return SearchResultCard(
              id: searchResultItem.id,
              imageUrl: searchResultItem.imageUrl,
              index: index,
              onTap: onTapSearchItem,
              searchItemType: searchResultItem.type,
              titleValue: searchResultItem.name,
            );
          },
          childCount: results.length,
        ),
      ),
    );
  }
}
