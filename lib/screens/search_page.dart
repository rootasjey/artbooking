import 'dart:async';

import 'package:algolia/algolia.dart';
import 'package:artbooking/components/application_bar/application_bar.dart';
import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/router/locations/home_location.dart';
import 'package:artbooking/screens/search_page/search_page_body.dart';
import 'package:artbooking/screens/search_page/search_page_fab.dart';
import 'package:artbooking/screens/search_page/search_page_header.dart';
import 'package:artbooking/types/enums/enum_search_item_type.dart';
import 'package:artbooking/types/illustration/illustration.dart';
import 'package:artbooking/globals/utilities/search_utilities.dart';
import 'package:artbooking/types/json_types.dart';
import 'package:beamer/beamer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flash/src/flash_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_improved_scrolling/flutter_improved_scrolling.dart';
import 'package:supercharged/supercharged.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  /// Show a floating action button if true.
  bool _showFab = false;

  /// True if a search request is running.
  bool _searching = false;

  /// Choose to show or hide results according to search input.
  bool _showResults = false;

  /// True if the first search hasn't been made yet.
  bool _isFirstSearch = true;

  /// Save last scroll offset value.
  /// Used to know if we're scrolling up or down.
  double _previousOffset = 0;

  /// Used to focus search input.
  final FocusNode _searchFocusNode = FocusNode();

  /// Search results for illustrations.
  final List<Illustration> _illustrationsSuggestions = [];

  /// Search results' limit.
  int _limit = 30;

  /// Page scroll controller.
  /// Multiple purpose: show/hide FAB.
  final ScrollController _pageScrollController = ScrollController();

  /// Text value of the search input.
  String _searchInputValue = "";

  /// Search input controller to follow input changes.
  TextEditingController _searchInputController = TextEditingController();

  /// Used to debounce search request.
  Timer? _searchTimer;

  @override
  initState() {
    super.initState();
  }

  @override
  dispose() {
    _searchFocusNode.dispose();
    _pageScrollController.dispose();
    _searchInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobileSize = Utilities.size.isMobileSize(context);

    return Scaffold(
      floatingActionButton: SearchPageFab(
        show: _showFab,
        onTabFab: onTapFab,
      ),
      body: ImprovedScrolling(
        scrollController: _pageScrollController,
        onScroll: onScroll,
        child: CustomScrollView(
          controller: _pageScrollController,
          slivers: <Widget>[
            ApplicationBar(),
            SearchPageHeader(
              isMobileSize: isMobileSize,
              resultCount: _illustrationsSuggestions.length,
              showResultMetrics: _showResults && !_isFirstSearch,
              onInputChanged: onInputChanged,
              searching: _searching,
              onClearInput: onClearInput,
              searchFocusNode: _searchFocusNode,
              searchInputController: _searchInputController,
            ),
            SearchPageBody(
              isMobileSize: isMobileSize,
              onClearInput: onClearInput,
              onInputChanged: onInputChanged,
              onTapSearchItem: onTapSearchItem,
              pageScrollController: _pageScrollController,
              results: _illustrationsSuggestions,
              searching: _searching,
              searchFocusNode: _searchFocusNode,
              searchInputController: _searchInputController,
              showWelcomePage: _showResults && !_isFirstSearch,
              showHeaderResults: _searchInputValue.isEmpty,
            ),
          ],
        ),
      ),
    );
  }

  void copyLink(Illustration illustration) async {
    final String url =
        "${Constants.links.baseIllustrationLink}{illustration.id}";
    await Clipboard.setData(ClipboardData(text: url));
    context.showSuccessBar(content: Text("copy_link_success".tr()));
  }

  void navigateToIllustration(String illustrationId) {
    Beamer.of(context).beamToNamed(
      HomeLocation.illustrationRoute
          .replaceFirst(":illustrationId", illustrationId),
      routeState: {
        "heroTag": illustrationId,
      },
    );
  }

  void onInputChanged(String newTextValue) {
    final bool refresh =
        _searchInputValue != newTextValue && newTextValue.isEmpty;

    _searchInputValue = newTextValue;
    _showResults = newTextValue.isNotEmpty;

    if (newTextValue.isEmpty) {
      if (refresh) {
        setState(() {});
      }
      return;
    }

    if (_searchTimer != null) {
      _searchTimer!.cancel();
    }

    _searchTimer = Timer(
      500.milliseconds,
      () => search(),
    );
  }

  void onClearInput() {
    _searchInputValue = "";
    _searchInputController.clear();
    _searchFocusNode.requestFocus();

    setState(() {});
  }

  void onTapSearchItem(EnumSearchItemType searchItemType, String id) {
    switch (searchItemType) {
      case EnumSearchItemType.book:
        break;
      case EnumSearchItemType.illustration:
        navigateToIllustration(id);
        break;
      case EnumSearchItemType.user:
        break;
      default:
    }
  }

  Future search() async {
    trySearchIllustrations();
  }

  void trySearchIllustrations() async {
    setState(() {
      _isFirstSearch = false;
      _searching = true;
      _illustrationsSuggestions.clear();
    });

    try {
      final AlgoliaQuery query = SearchUtilities.algolia
          .index("illustrations")
          .query(_searchInputValue)
          .setHitsPerPage(_limit)
          .setPage(0);

      final AlgoliaQuerySnapshot snapshot = await query.getObjects();

      if (snapshot.empty) {
        setState(() => _searching = false);
        return;
      }

      for (final AlgoliaObjectSnapshot hit in snapshot.hits) {
        final Json data = hit.data;
        data['id'] = hit.objectID;

        final Illustration illustration = Illustration.fromMap(data);
        _illustrationsSuggestions.add(illustration);
      }

      setState(() => _searching = false);
    } catch (error) {
      Utilities.logger.e(error);
      setState(() => _searching = false);
    }
  }

  void onScroll(double offset) {
    final bool scrollingDown = offset - _previousOffset > 0;
    _previousOffset = offset;

    if (scrollingDown) {
      if (!_showFab) {
        return;
      }

      setState(() => _showFab = false);
      return;
    }

    if (offset == 0.0) {
      setState(() => _showFab = false);
      return;
    }

    if (_showFab) {
      return;
    }

    setState(() => _showFab = true);
  }

  void onTapFab() {
    _pageScrollController.animateTo(
      0.0,
      duration: Duration(seconds: 1),
      curve: Curves.easeOut,
    );
  }
}
