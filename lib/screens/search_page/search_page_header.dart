import 'package:artbooking/screens/search_page/search_page_header_results.dart';
import 'package:artbooking/components/inputs/search_text_input.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class SearchPageHeader extends StatelessWidget {
  const SearchPageHeader({
    Key? key,
    required this.resultCount,
    required this.searching,
    required this.searchFocusNode,
    required this.searchInputController,
    this.onInputChanged,
    this.onClearInput,
    this.isMobileSize = false,
    this.showResultMetrics = false,
  }) : super(key: key);

  /// Show search result count if true.
  final bool showResultMetrics;

  /// If true, this widget adapts its size to small screens.
  final bool isMobileSize;

  /// True if a search request is running.
  final bool searching;

  /// Used to focus search input.
  final FocusNode searchFocusNode;

  /// Callback fired to clear search input.
  final void Function()? onClearInput;

  /// Callback fired when search input changes.
  final void Function(String)? onInputChanged;

  /// Number of search result items.
  final int resultCount;

  /// Search input controller to follow input changes.
  final TextEditingController searchInputController;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.only(
          top: isMobileSize ? 54.0 : 100.0,
          bottom: isMobileSize ? 24.0 : 50.0,
          left: 12.0,
          right: 12.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: SearchTextInput(
                    autofocus: true,
                    controller: searchInputController,
                    focusNode: searchFocusNode,
                    hintText: "search_input_hint_text".tr(),
                    keyboardType: TextInputType.multiline,
                    textCapitalization: TextCapitalization.sentences,
                    onChanged: onInputChanged,
                    onClearInput: onClearInput,
                  ),
                ),
                if (searching) LinearProgressIndicator(),
              ],
            ),
            SearchPageHeaderResults(
              resultCount: resultCount,
              show: showResultMetrics,
            ),
          ],
        ),
      ),
    );
  }
}
