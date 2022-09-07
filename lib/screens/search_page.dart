import 'dart:async';

import 'package:algolia/algolia.dart';
import 'package:artbooking/components/application_bar/application_bar.dart';
import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/router/locations/home_location.dart';
import 'package:artbooking/screens/search_page/search_page_body.dart';
import 'package:artbooking/screens/search_page/search_page_fab.dart';
import 'package:artbooking/screens/search_page/search_page_header.dart';
import 'package:artbooking/types/book/book.dart';
import 'package:artbooking/types/enums/enum_search_item_type.dart';
import 'package:artbooking/types/illustration/illustration.dart';
import 'package:artbooking/globals/utilities/search_utilities.dart';
import 'package:artbooking/types/json_types.dart';
import 'package:artbooking/types/search_result_item.dart';
import 'package:artbooking/types/user/user_firestore.dart';
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

  /// Search results containing books, illustrations, artists.
  final List<SearchResultItem> _searchResultItemList = [];

  /// Search results' limit.
  int _limit = 10;

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
            ApplicationBar(
              pinned: false,
              bottom: PreferredSize(
                child: SearchPageHeader(
                  isMobileSize: isMobileSize,
                  resultCount: _searchResultItemList.length,
                  showResultMetrics: _showResults && !_isFirstSearch,
                  onInputChanged: onInputChanged,
                  searching: _searching,
                  onClearInput: onClearInput,
                  searchFocusNode: _searchFocusNode,
                  searchInputController: _searchInputController,
                ),
                preferredSize: Size.fromHeight(180.0),
              ),
            ),
            SearchPageBody(
              isMobileSize: isMobileSize,
              onClearInput: onClearInput,
              onInputChanged: onInputChanged,
              onTapSearchItem: onTapSearchItem,
              pageScrollController: _pageScrollController,
              results: _searchResultItemList,
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

  void navigateToBook(String bookId) {
    final String route = HomeLocation.bookRoute.replaceFirst(
      ":bookId",
      bookId,
    );

    Beamer.of(context).beamToNamed(
      route,
      routeState: {
        "heroTag": bookId,
      },
    );
  }

  void navigateToIllustration(String illustrationId) {
    final String route = HomeLocation.illustrationRoute.replaceFirst(
      ":illustrationId",
      illustrationId,
    );

    Beamer.of(context).beamToNamed(
      route,
      routeState: {
        "heroTag": illustrationId,
      },
    );
  }

  void navigateToUser(String userId) {
    final String route = HomeLocation.profileRoute.replaceFirst(
      ":userId",
      userId,
    );

    Beamer.of(context).beamToNamed(
      route,
      routeState: {
        "heroTag": userId,
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
        navigateToBook(id);
        break;
      case EnumSearchItemType.illustration:
        navigateToIllustration(id);
        break;
      case EnumSearchItemType.user:
        navigateToUser(id);
        break;
      default:
    }
  }

  Future search() async {
    _searchResultItemList.clear();

    setState(() {
      _isFirstSearch = false;
      _searching = true;
    });

    await Future.wait([
      trySearchUsers(),
      trySearchBooks(),
      trySearchIllustrations(),
    ]);

    setState(() => _searching = false);
  }

  Future<void> trySearchUsers() async {
    try {
      final AlgoliaQuery query = SearchUtilities.algolia
          .index("users")
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
        data["id"] = hit.objectID;

        final UserFirestore user = UserFirestore.fromMap(data);

        _searchResultItemList.add(
          SearchResultItem(
            type: EnumSearchItemType.user,
            index: _searchResultItemList.length,
            id: user.id,
            name: user.name,
            imageUrl: user.getProfilePicture(),
          ),
        );
      }
    } catch (error) {
      Utilities.logger.e(error);
    }
  }

  Future<void> trySearchBooks() async {
    try {
      final AlgoliaQuery query = SearchUtilities.algolia
          .index("books")
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
        data["id"] = hit.objectID;

        final Book book = Book.fromMap(data);

        _searchResultItemList.add(
          SearchResultItem(
            type: EnumSearchItemType.book,
            index: _searchResultItemList.length,
            id: book.id,
            name: book.name,
            imageUrl: book.getCoverLink(),
          ),
        );
      }
    } catch (error) {
      Utilities.logger.e(error);
    }
  }

  Future<void> trySearchIllustrations() async {
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
        data["id"] = hit.objectID;

        final Illustration illustration = Illustration.fromMap(data);

        _searchResultItemList.add(
          SearchResultItem(
            type: EnumSearchItemType.illustration,
            index: _searchResultItemList.length,
            id: illustration.id,
            name: illustration.name,
            imageUrl: illustration.getThumbnail(),
          ),
        );
      }
    } catch (error) {
      Utilities.logger.e(error);
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
