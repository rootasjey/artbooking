import 'dart:async';

import 'package:artbooking/actions/books.dart';
import 'package:artbooking/components/application_bar/application_bar.dart';
import 'package:artbooking/components/bottom_sheet/delete_content_bottom_sheet.dart';
import 'package:artbooking/components/buttons/double_action_fab.dart';
import 'package:artbooking/components/buttons/visibility_button.dart';
import 'package:artbooking/components/custom_scroll_behavior.dart';
import 'package:artbooking/components/dialogs/delete_dialog.dart';
import 'package:artbooking/components/dialogs/input_dialog.dart';
import 'package:artbooking/components/buttons/dark_elevated_button.dart';
import 'package:artbooking/components/dialogs/share_dialog.dart';
import 'package:artbooking/components/popup_menu/popup_menu_icon.dart';
import 'package:artbooking/components/popup_menu/popup_menu_item_icon.dart';
import 'package:artbooking/components/dialogs/themed_dialog.dart';
import 'package:artbooking/components/dialogs/add_to_books_dialog.dart';
import 'package:artbooking/components/popup_progress_indicator.dart';
import 'package:artbooking/router/locations/atelier_location.dart';
import 'package:artbooking/router/locations/home_location.dart';
import 'package:artbooking/router/navigation_state_helper.dart';
import 'package:artbooking/screens/book/book_page_body.dart';
import 'package:artbooking/screens/book/book_page_header.dart';
import 'package:artbooking/types/book/book.dart';
import 'package:artbooking/types/book/book_illustration.dart';
import 'package:artbooking/types/book/popup_entry_book.dart';
import 'package:artbooking/types/cloud_functions/book_response.dart';
import 'package:artbooking/types/cloud_functions/illustrations_response.dart';
import 'package:artbooking/types/cloud_functions/upload_cover_response.dart';
import 'package:artbooking/types/enums/enum_book_item_action.dart';
import 'package:artbooking/types/enums/enum_content_visibility.dart';
import 'package:artbooking/types/enums/enum_illustration_item_action.dart';
import 'package:artbooking/globals/app_state.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/enums/enum_share_content_type.dart';
import 'package:artbooking/types/firestore/document_map.dart';
import 'package:artbooking/types/firestore/doc_snapshot_stream_subscription.dart';
import 'package:artbooking/types/firestore/document_snapshot_map.dart';
import 'package:artbooking/types/illustration/illustration.dart';
import 'package:artbooking/types/illustration/popup_entry_illustration.dart';
import 'package:artbooking/types/illustration_map.dart';
import 'package:artbooking/types/json_types.dart';
import 'package:beamer/beamer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flash/src/flash_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_improved_scrolling/flutter_improved_scrolling.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jiffy/jiffy.dart';
import 'package:supercharged/supercharged.dart';
import 'package:unicons/unicons.dart';

class BookPage extends ConsumerStatefulWidget {
  const BookPage({
    Key? key,
    required this.bookId,
    this.heroTag = "",
  }) : super(key: key);

  /// Book's id.
  final String bookId;

  /// Custom hero tag (if `book.id` default tag is not unique).
  final String heroTag;

  @override
  _MyBookPageState createState() => _MyBookPageState();
}

class _MyBookPageState extends ConsumerState<BookPage> {
  /// The book displayed on this page.
  Book _book = Book.empty();

  /// (Mobile specific) If true, long pressing a card will start a drag.
  /// Otherwise, long pressing a card will display a context menu.
  bool _draggingActive = false;

  /// True if the page is loading.
  bool _loading = false;

  /// True if there was an error while fetching data.
  bool _hasError = false;

  /// True if there's a next page to fetch for this book's illustrations.
  bool _hasNext = false;

  /// True if the view is in multiselect mode.
  bool _forceMultiSelect = false;

  /// True if there's a request to fetch the next illustration's batch.
  bool _loadingMore = false;

  /// True if the current authenticated user has liked this book.
  bool _liked = false;

  /// Show this page Floating Action Button if true.
  bool _showMainFab = true;

  /// Show FAB to scroll to the top of the page if true.
  bool _showFabToTop = false;

  /// Currently changing book's cover if true.
  /// It may be fast or takes more time if there's file upload + thumbnails
  /// generation.
  bool _updatingCover = false;

  /// Listens to book's updates.
  DocSnapshotStreamSubscription? _bookSubscription;

  /// Listent to changes for this book's like status.
  DocSnapshotStreamSubscription? _likeSubscription;

  /// /// Amount of offset to jump when dragging an element to the edge.
  final double _jumpOffset = 200.0;

  /// Distance to the edge where the scroll viewer starts to jump.
  final double _edgeDistance = 200.0;

  /// Last saved Y offset.
  /// Used while scrolling to know the direction.
  double _previousOffset = 0.0;

  /// Why a map and not just a list?
  ///
  /// -> faster access & because it's already done.
  ///
  /// -> for [_multiSelectedItems] allow instant access to know
  /// if an illustration is currently in multi-select.
  final IllustrationMap _illustrationMap = IllustrationMap();

  // final _illustrationList = <Illustration>[];
  final FocusNode _keyboardFocusNode = FocusNode();

  /// Illustrations' ids matching [book.illustrationMap].
  /// Generated keys instead of simple ids due to possible duplicates.
  List<String> _currentIllustrationKeys = [];

  /// Count limit when fetchig this book's illustrations.
  int _limit = 20;

  /// The first illustration to fetch in the array.
  int _startIndex = 0;

  /// The last illustration to fetch in the array.
  int _endIndex = 0;

  /// Listens to illustrations' updates.
  final Map<String, DocSnapshotStreamSubscription> _illustrationSubs = {};

  /// Currently selected illustrations.
  IllustrationMap _multiSelectedItems = Map();

  /// Items when opening the popup.
  final List<PopupEntryIllustration> _popupMenuEntries = [
    PopupMenuItemIcon(
      value: EnumIllustrationItemAction.addToBook,
      icon: PopupMenuIcon(UniconsLine.book_medical),
      textLabel: "add_to_book".tr(),
    ),
    PopupMenuItemIcon(
      value: EnumIllustrationItemAction.removeFromBook,
      icon: PopupMenuIcon(UniconsLine.image_minus),
      textLabel: "remove".tr(),
    ),
    PopupMenuItemIcon(
      value: EnumIllustrationItemAction.setAsCover,
      icon: PopupMenuIcon(UniconsLine.image_check),
      textLabel: "set_as_cover".tr(),
    ),
  ];

  final List<PopupEntryBook> _coverPopupMenuEntries = [
    PopupMenuItemIcon(
      icon: PopupMenuIcon(UniconsLine.history),
      textLabel: "book_reset_cover".tr(),
      value: EnumBookItemAction.resetCover,
    ),
    PopupMenuItemIcon(
      icon: PopupMenuIcon(UniconsLine.upload),
      textLabel: "book_upload_cover".tr(),
      value: EnumBookItemAction.uploadCover,
    ),
  ];

  /// Handles page's scroll.
  ScrollController _pageScrollController = ScrollController();

  /// String separator to generate unique key for illustrations.
  final String _keySeparator = "--";

  @override
  initState() {
    super.initState();
    loadPreferences();

    Book? bookFromNav = NavigationStateHelper.book;

    if (bookFromNav != null && bookFromNav.id == widget.bookId) {
      _book = bookFromNav;
      fetchIllustrationsAndListenToUpdates();
      fetchLike();
    } else {
      fetchBookAndIllustrations();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final bool isMobileSize = Utilities.size.isMobileSize(context);
    if (!isMobileSize) {
      _draggingActive = true;
    }
  }

  @override
  void dispose() {
    _bookSubscription?.cancel();
    _likeSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String? userId = ref.read(AppState.userProvider).firestoreUser?.id;
    final bool authenticated = userId != null && userId.isNotEmpty;
    final bool isOwner = (_book.userId == userId) && _book.userId.isNotEmpty;
    final bool isMobileSize = Utilities.size.isMobileSize(context);

    return Scaffold(
      floatingActionButton: DoubleActionFAB(
        icon: Icon(UniconsLine.upload),
        isMainActionAvailable: isOwner,
        labelValue: "upload".tr(),
        pageScrollController: _pageScrollController,
        showMainFab: _showMainFab,
        showFabToTop: _showFabToTop,
      ),
      body: Stack(
        children: [
          ImprovedScrolling(
            enableKeyboardScrolling: true,
            enableMMBScrolling: true,
            onScroll: onPageScroll,
            scrollController: _pageScrollController,
            child: ScrollConfiguration(
              behavior: CustomScrollBehavior(),
              child: CustomScrollView(
                controller: _pageScrollController,
                slivers: <Widget>[
                  ApplicationBar(
                    minimal: true,
                  ),
                  BookPageHeader(
                    book: _book,
                    draggingActive: _draggingActive,
                    forceMultiSelect: _forceMultiSelect,
                    isMobileSize: isMobileSize,
                    liked: _liked,
                    heroTag: widget.heroTag,
                    authenticated: authenticated,
                    coverPopupMenuEntries: _coverPopupMenuEntries,
                    multiSelectedItems: _multiSelectedItems,
                    onLike: onLike,
                    onAddToBook: showAddGroupToBook,
                    onClearMultiSelect: onClearMultiSelect,
                    onConfirmDeleteBook: onConfirmDeleteBook,
                    onConfirmRemoveGroup: onConfirmRemoveGroup,
                    onCoverPopupMenuItemSelected: onCoverPopupMenuItemSelected,
                    onMultiSelectAll: onMultiSelectAll,
                    onShareBook: showShareDialog,
                    onToggleDrag: onToggleDrag,
                    onToggleMultiSelect: onToggleMultiSelect,
                    onShowDatesDialog: onShowDatesDialog,
                    onShowRenameBookDialog: onShowRenameBookDialog,
                    onUploadToThisBook: onUploadToThisBook,
                    onUpdateVisibility: onUpdateVisibility,
                    isOwner: isOwner,
                  ),
                  BookPageBody(
                    draggingActive: _draggingActive,
                    hasError: _hasError,
                    isMobileSize: isMobileSize,
                    loading: _loading,
                    forceMultiSelect: _forceMultiSelect,
                    illustrationMap: _illustrationMap,
                    bookIllustrations: _book.illustrations,
                    multiSelectedItems: _multiSelectedItems,
                    popupMenuEntries: _popupMenuEntries,
                    onBrowseIllustrations: onBrowseIllustrations,
                    onDragUpdateBook: onDragUpdateBook,
                    onPopupMenuItemSelected: onPopupMenuItemSelected,
                    onTapIllustrationCard: onTapIllustrationCard,
                    onUploadToThisBook: onUploadToThisBook,
                    onDropIllustration: onDropIllustration,
                    isOwner: isOwner,
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.only(bottom: 100.0),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 100.0,
            right: 24.0,
            child: PopupProgressIndicator(
              show: _updatingCover,
              message: "book_updating_cover".tr() + "...",
            ),
          ),
        ],
      ),
    );
  }

  /// Failed illustrations' fetchs means that
  /// there may be deleted ones in this book.
  void checkFetchErrors(List<String> illustrationsErrors) {
    if (illustrationsErrors.isEmpty) {
      return;
    }

    Utilities.cloud.fun('books-removeDeletedIllustrations').call({
      'book_id': widget.bookId,
      'illustration_ids': illustrationsErrors,
    }).catchError((error, stack) {
      Utilities.logger.e(error);
      throw error;
    });
  }

  /// Show a dialog to confirm a single book deletion.
  void confirmRemoveIllustrationGroup(
    Illustration illustration,
    String illustrationKey,
  ) async {
    showDialog(
      context: context,
      builder: (context) {
        final int count = _multiSelectedItems.length;
        final String titleValue =
            "book_illustrations_remove_title".plural(count).toUpperCase();
        final String descriptionValue =
            "book_illustrations_remove_description".plural(count);

        final String textButtonValidation = "book_illustrations_remove".plural(
          count,
          args: [count.toString()],
        );

        return DeleteDialog(
          count: count,
          titleValue: titleValue,
          descriptionValue: descriptionValue,
          confirmButtonValue: textButtonValidation,
          onValidate: () {
            _multiSelectedItems.putIfAbsent(
              illustrationKey,
              () => illustration,
            );
            removeIllustrationGroup();
          },
        );
      },
    );
  }

  /// Get a differenciation of illustrations in this book
  /// and add or remove illustration accordingly.
  void diffIllustrations() {
    if (_book.id.isEmpty) {
      return;
    }

    handleAddedIllustrations();
    handleRemovedIllustrations();
  }

  void fetchBookAndIllustrations() async {
    await fetchBook();
    fetchLike();
    fetchIllustrations();
  }

  Future fetchBook() async {
    setState(() {
      _loading = true;
    });

    try {
      final query =
          FirebaseFirestore.instance.collection('books').doc(widget.bookId);

      final bookSnap = await query.get();
      final bookData = bookSnap.data();

      if (!bookSnap.exists || bookData == null) {
        setState(() {
          _hasError = true;
          _loading = false;
        });

        return;
      }

      bookData['id'] = bookSnap.id;
      listenBook(query);

      setState(() {
        _book = Book.fromMap(bookData);
        _currentIllustrationKeys = _book.illustrations
            .map((bookIllustration) =>
                Utilities.generateIllustrationKey(bookIllustration))
            .toList();
      });
    } catch (error) {
      Utilities.logger.e(error);
      setState(() => _hasError = true);
    } finally {
      setState(() => _loading = false);
    }
  }

  /// Fetch an range of illustrations of a book.
  void fetchIllustrations() async {
    if (_book.id.isEmpty) {
      return;
    }

    final List<BookIllustration> illustrationsBook = _book.illustrations;

    setState(() {
      _loading = true;
      _startIndex = 0;
      _endIndex = illustrationsBook.length >= _limit
          ? _limit
          : illustrationsBook.length;
    });

    if (illustrationsBook.isEmpty) {
      setState(() => _loading = false);
      return;
    }

    final Iterable<BookIllustration> range = illustrationsBook.getRange(
      _startIndex,
      _endIndex,
    );

    final List<String> illustrationsErrors = [];

    for (BookIllustration bookIllustration in range) {
      try {
        final DocumentSnapshotMap illustrationSnapshot = await FirebaseFirestore
            .instance
            .collection("illustrations")
            .doc(bookIllustration.id)
            .get();

        final Json? illustrationData = illustrationSnapshot.data();
        if (!illustrationSnapshot.exists || illustrationData == null) {
          continue;
        }

        illustrationData["id"] = illustrationSnapshot.id;

        final Illustration illustration = Illustration.fromMap(
          illustrationData,
        );

        _illustrationMap.putIfAbsent(
          Utilities.generateIllustrationKey(bookIllustration),
          () => illustration,
        );
      } catch (error) {
        Utilities.logger.e(error);
        illustrationsErrors.add(bookIllustration.id);

        final Illustration missingIllustration = Illustration.empty(
          id: bookIllustration.id,
          userId: _book.userId,
        );

        _illustrationMap.putIfAbsent(
          Utilities.generateIllustrationKey(bookIllustration),
          () => missingIllustration,
        );
      } finally {
        setState(() => _loading = false);
      }
    }

    // checkFetchErrors(illustrationsErrors);
  }

  void fetchIllustrationsAndListenToUpdates() {
    fetchIllustrations();

    final DocumentMap query =
        FirebaseFirestore.instance.collection("books").doc(widget.bookId);

    listenBook(query);
  }

  void fetchMoreIllustrations() async {
    if (!_hasNext || _book.id.isEmpty || _loadingMore) {
      return;
    }

    _startIndex = _endIndex;
    _endIndex = _endIndex + _limit;
    _loadingMore = true;

    final Iterable<BookIllustration> range =
        _book.illustrations.getRange(_startIndex, _endIndex);

    try {
      for (final BookIllustration bookIllustration in range) {
        final DocumentSnapshotMap illustrationSnap = await FirebaseFirestore
            .instance
            .collection("illustrations")
            .doc(bookIllustration.id)
            .get();

        if (!illustrationSnap.exists) {
          continue;
        }

        final Json illustrationData = illustrationSnap.data()!;
        illustrationData["id"] = illustrationSnap.id;

        final Illustration illustration = Illustration.fromMap(
          illustrationData,
        );

        _illustrationMap.putIfAbsent(
          Utilities.generateIllustrationKey(bookIllustration),
          () => illustration,
        );
      }
      setState(() {
        _hasNext = _endIndex < _book.count;
      });
    } catch (error) {
      Utilities.logger.e(error);
    } finally {
      setState(() => _loadingMore = false);
    }
  }

  void fetchLike() async {
    final String? userId = ref.read(AppState.userProvider).firestoreUser?.id;
    if (userId == null || userId.isEmpty) {
      return;
    }

    try {
      _likeSubscription = await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("user_likes")
          .doc(_book.id)
          .snapshots()
          .listen((snapshot) {
        setState(() {
          _liked = snapshot.exists;
        });
      }, onDone: () {
        _likeSubscription?.cancel();
      });
    } catch (error) {
      Utilities.logger.e(error);
    }
  }

  String getIllustratioinNavRoute(Illustration illustration) {
    final String? location = Beamer.of(context)
        .beamingHistory
        .last
        .history
        .last
        .routeInformation
        .location;

    if (location == null) {
      return HomeLocation.illustrationBookRoute
          .replaceFirst(":bookId", _book.id)
          .replaceFirst(":illustrationId", illustration.id);
    }

    if (location.contains("atelier") && location.contains("profile")) {
      return AtelierLocationContent.profileIllustrationBookRoute
          .replaceFirst(":bookId", _book.id)
          .replaceFirst(":illustrationId", illustration.id);
    }

    if (location.contains("atelier")) {
      return AtelierLocationContent.illustrationBookRoute
          .replaceFirst(":bookId", _book.id)
          .replaceFirst(":illustrationId", illustration.id);
    }

    return HomeLocation.illustrationBookRoute
        .replaceFirst(":bookId", _book.id)
        .replaceFirst(":illustrationId", illustration.id);
  }

  /// Find new values in [book.illustrationMap]
  /// that weren't there before the update.
  /// -------------------------------------------
  /// For each id in the new data:
  ///
  /// • if the value exists in [_illustrationMap] → nothing changed
  ///
  /// • if the value doesn't exist in [_illustrationMap] → new value.
  void handleAddedIllustrations() async {
    final List<String> added = _currentIllustrationKeys.filter(
      (String illustrationKey) {
        // final idAndCreatedAt = illustrationKey.split('--');
        // final illustrationId = idAndCreatedAt.elementAt(0);
        // final illustrationCreatedAt = idAndCreatedAt.elementAt(1);

        // final Illustration illustrationToFind = _illustrations.values
        //     .firstWhere((illustration) => illustration.id == illustrationId);

        // final String key = generateKey(illustrationToFind);

        // if (_illustrations.containsKey(key)) {
        //   return false;
        // }
        if (_illustrationMap.containsKey(illustrationKey)) {
          return false;
        }

        return true;
      },
    ).toList();

    for (String illustrationKey in added) {
      final idAndCreatedAt = illustrationKey.split(_keySeparator);
      final illustrationId = idAndCreatedAt.elementAt(0);

      final DocumentMap query = FirebaseFirestore.instance
          .collection("illustrations")
          .doc(illustrationId);

      final DocumentSnapshotMap illustrationSnap = await query.get();
      final Json? illustrationData = illustrationSnap.data();

      if (!illustrationSnap.exists || illustrationData == null) {
        continue;
      }

      illustrationData["id"] = illustrationSnap.id;
      final Illustration illustration = Illustration.fromMap(illustrationData);

      setState(() {
        _illustrationMap.putIfAbsent(
          illustrationKey,
          () => illustration,
        );
      });

      if (illustration.version < 1) {
        waitForThumbnail(illustrationKey, query);
      }
    }
  }

  /// We want values that were there before
  /// but has been removed in the update.
  /// -------------------------------------------
  /// For each id in new data:
  ///
  /// • if the value exist in [_currentIllustrationKeys] → nothing changed
  ///
  /// • if the value doesn't exist in [_currentIllustrationKeys] → removed value.
  void handleRemovedIllustrations() {
    final Iterable<String> customRemovedIds = _illustrationMap.filter(
      (MapEntry<String, Illustration> mapEntry) {
        // final Illustration illustration = mapEntry.value;

        // if (_currentIllusKeys.contains(illustration.id)) {
        //   return false;
        // }
        if (_currentIllustrationKeys.contains(mapEntry.key)) {
          return false;
        }

        return true;
      },
    ).map((mapEntry) => mapEntry.key);

    setState(() {
      for (String customId in customRemovedIds) {
        _illustrationMap.remove(customId);
      }
    });
  }

  void listenBook(DocumentReference<Map<String, dynamic>> query) {
    _bookSubscription = query.snapshots().skip(1).listen(
      (DocumentSnapshot<Map<String, dynamic>> snapshot) {
        final Json? bookData = snapshot.data();
        if (!snapshot.exists || bookData == null) {
          return;
        }

        setState(() {
          bookData["id"] = snapshot.id;
          _book = Book.fromMap(bookData);
          _currentIllustrationKeys = _book.illustrations
              .map((bookIllustration) =>
                  Utilities.generateIllustrationKey(bookIllustration))
              .toList();
        });

        diffIllustrations();
      },
      onError: (error) {
        Utilities.logger.e(error);
      },
    );
  }

  void loadPreferences() {
    _draggingActive = Utilities.storage.getMobileDraggingActive();
  }

  void maybeFetchMore(double offset) {
    if (_pageScrollController.position.atEdge &&
        offset > 50 &&
        _hasNext &&
        !_loadingMore) {
      fetchMoreIllustrations();
    }
  }

  void maybeShowFab(double offset) {
    final bool scrollingDown = offset - _previousOffset > 0;
    _previousOffset = offset;

    _showFabToTop = offset == 0.0 ? false : true;

    if (scrollingDown) {
      if (!_showMainFab) {
        return;
      }

      setState(() => _showMainFab = false);
      return;
    }

    if (offset == 0.0) {
      setState(() => _showFabToTop = false);
    }

    if (_showMainFab) {
      return;
    }

    setState(() => _showMainFab = true);
  }

  void multiSelectIllustration(
      String illustrationKey, Illustration illustration) {
    final bool selected = _multiSelectedItems.containsKey(illustrationKey);

    if (selected) {
      setState(() {
        _multiSelectedItems.remove(illustrationKey);
        _forceMultiSelect = _multiSelectedItems.length > 0;
      });

      return;
    }

    setState(() {
      _multiSelectedItems.putIfAbsent(
        illustrationKey,
        () => illustration,
      );
    });
  }

  void navigateToIllustrationPage(
    Illustration illustration,
    String illustrationKey,
  ) {
    NavigationStateHelper.illustration = illustration;
    final String route = getIllustratioinNavRoute(illustration);

    Beamer.of(context).beamToNamed(
      route,
      data: {
        "bookId": _book.id,
        "illustrationId": illustration.id,
      },
      routeState: {
        "heroTag": illustrationKey,
      },
    );
  }

  void onBrowseIllustrations() {
    context.beamToNamed(AtelierLocationContent.illustrationsRoute);
  }

  void onChangedVisibility(
    BuildContext context, {
    required Book book,
    required int index,
    required EnumContentVisibility visibility,
  }) {
    final Future<EnumContentVisibility?>? futureResult = tryUpdateVisibility(
      book,
      visibility,
      index,
    );

    Navigator.pop(context, futureResult);
  }

  void onClearMultiSelect() {
    setState(() {
      _multiSelectedItems.clear();
      _forceMultiSelect = _multiSelectedItems.length > 0;
    });
  }

  /// Show a dialog to confirm a single book deletion.
  void onConfirmDeleteBook() async {
    final bool isMobileSize = Utilities.size.isMobileSize(context);

    Utilities.ui.showAdaptiveDialog(
      context,
      isMobileSize: isMobileSize,
      builder: (BuildContext context) {
        final int count = 1;

        final String confirmButtonValue = "book_delete_count".plural(
          count,
          args: [count.toString()],
        );

        if (isMobileSize) {
          return DeleteContentBottomSheet(
            confirmButtonValue: confirmButtonValue,
            count: count,
            onConfirm: tryDeleteBook,
            subtitleValue: "book_delete_description".plural(count),
            titleValue: "book_delete".plural(count).toUpperCase(),
          );
        }

        return DeleteDialog(
          confirmButtonValue: confirmButtonValue,
          count: count,
          descriptionValue: "book_delete_description".plural(count),
          focusNode: _keyboardFocusNode,
          onValidate: tryDeleteBook,
          showCounter: _multiSelectedItems.isNotEmpty,
          titleValue: "book_delete".plural(count).toUpperCase(),
        );
      },
    );
  }

  /// Show a popup to confirm illustrations group deletion.
  void onConfirmRemoveGroup() {
    if (_multiSelectedItems.isEmpty) {
      context.showErrorBar(content: Text("multi_select_no_item".tr()));
      return;
    }

    final Illustration illustration = _multiSelectedItems.values.first;
    final String key = _multiSelectedItems.keys.first;
    confirmRemoveIllustrationGroup(illustration, key);
  }

  /// Callback when a cover popup menu item is selected.
  void onCoverPopupMenuItemSelected(
      EnumBookItemAction action, int index, Book book) {
    switch (action) {
      case EnumBookItemAction.resetCover:
        tryResetCover(book);
        break;
      case EnumBookItemAction.uploadCover:
        tryUploadCover(book);
        break;
      default:
    }
  }

  void onDragUpdateBook(DragUpdateDetails details) async {
    final position = details.globalPosition;

    if (position.dy < _edgeDistance) {
      if (_pageScrollController.offset <= 0) {
        return;
      }

      await _pageScrollController.animateTo(
        _pageScrollController.offset - _jumpOffset,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );

      return;
    }

    final windowHeight = MediaQuery.of(context).size.height;
    if (windowHeight - _edgeDistance < position.dy) {
      if (_pageScrollController.position.atEdge &&
          _pageScrollController.offset != 0) {
        return;
      }

      await _pageScrollController.animateTo(
        _pageScrollController.offset + _jumpOffset,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  /// When an illustration card is droped somewhere.
  void onDropIllustration(int dropIndex, List<int> dragIndexes) async {
    final illustrationList = _book.illustrations;
    final firstDragIndex = dragIndexes.first;

    if (dropIndex == firstDragIndex) {
      return;
    }

    final dropIllustration = illustrationList.elementAt(dropIndex);
    final dragIllustration = illustrationList.elementAt(firstDragIndex);

    illustrationList[dropIndex] = dragIllustration;
    illustrationList[firstDragIndex] = dropIllustration;

    setState(() {
      _book = _book.copyWith(
        illustrations: illustrationList,
      );
    });

    try {
      final response = await BooksActions.reorderIllustrations(
        bookId: _book.id,
        dropIndex: dropIndex,
        dragIndexes: dragIndexes,
      );

      if (response.hasErrors) {
        throw ErrorDescription(response.error?.details ?? "");
      }
    } catch (error) {
      Utilities.logger.e(error);
    }
  }

  /// Toggle a book existence in user's favourites.
  void onLike() {
    if (_liked) {
      return tryUnLike();
    }

    return tryLike();
  }

  void onLongPressIllustration(
    String illustrationKey,
    Illustration illustration,
    bool selected,
  ) {
    if (selected) {
      setState(() {
        _multiSelectedItems.remove(illustrationKey);
      });
      return;
    }

    setState(() {
      _multiSelectedItems.putIfAbsent(
        illustrationKey,
        () => illustration,
      );
    });
  }

  void onMultiSelectAll() {
    _illustrationMap.forEach((String key, Illustration illustration) {
      _multiSelectedItems.putIfAbsent(
        key,
        () => illustration,
      );
    });

    setState(() {});
  }

  /// Callback when the page scrolls up and down.
  void onPageScroll(double offset) {
    maybeShowFab(offset);
    maybeFetchMore(offset);
  }

  void onPopupMenuItemSelected(
    EnumIllustrationItemAction action,
    int index,
    Illustration illustration,
    String illustrationKey,
  ) {
    switch (action) {
      case EnumIllustrationItemAction.addToBook:
        showAddToBook(illustrationKey, illustration);
        break;
      case EnumIllustrationItemAction.removeFromBook:
        if (_multiSelectedItems.isEmpty) {
          removeIllustration(
            index: index,
            illustration: illustration,
            illustrationKey: illustrationKey,
          );
          return;
        }

        confirmRemoveIllustrationGroup(illustration, illustrationKey);
        break;
      case EnumIllustrationItemAction.setAsCover:
        trySetIllustrationAsCover(illustration);
        break;
      default:
    }
  }

  void onShowDatesDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String createdAtStr = "";

        if (DateTime.now().difference(_book.createdAt).inDays > 60) {
          createdAtStr = "date_created_on".tr(
            args: [
              Jiffy(_book.createdAt).yMMMMEEEEd,
            ],
          );
        } else {
          createdAtStr = "date_created_ago".tr(
            args: [Jiffy(_book.createdAt).fromNow()],
          );
        }

        String updatedAtStr = "";

        if (DateTime.now().difference(_book.updatedAt).inDays > 60) {
          updatedAtStr = "date_updated_on".tr(
            args: [
              Jiffy(_book.updatedAt).yMMMMEEEEd,
            ],
          );
        } else {
          updatedAtStr = "date_updated_ago".tr(
            args: [Jiffy(_book.updatedAt).fromNow()],
          );
        }

        return SimpleDialog(
          titlePadding: EdgeInsets.zero,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  top: 24.0,
                  left: 24.0,
                  right: 24.0,
                  bottom: 12.0,
                ),
                child: Text(
                  "Dates".toUpperCase(),
                  style: Utilities.fonts.body(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Divider(
                thickness: 1.5,
                color: Theme.of(context).secondaryHeaderColor,
              ),
            ],
          ),
          contentPadding: const EdgeInsets.all(24.0),
          children: [
            Row(
              children: [
                Opacity(
                  opacity: 0.3,
                  child: Text(
                    "• ",
                    style: Utilities.fonts.body(
                      color: Theme.of(context).primaryColor,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Expanded(
                  child: Opacity(
                    opacity: 0.6,
                    child: Text(
                      createdAtStr.toLowerCase(),
                      style: Utilities.fonts.body(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Opacity(
                  opacity: 0.3,
                  child: Text(
                    "• ",
                    style: Utilities.fonts.body(
                      color: Theme.of(context).secondaryHeaderColor,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Expanded(
                  child: Opacity(
                    opacity: 0.6,
                    child: Text(
                      updatedAtStr.toLowerCase(),
                      style: Utilities.fonts.body(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: DarkElevatedButton.large(
                onPressed: Beamer.of(context).popRoute,
                child: Text(
                  "close".tr(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void onShowRenameBookDialog() {
    var _nameController = TextEditingController();
    var _descriptionController = TextEditingController();

    _nameController.text = _book.name;
    _descriptionController.text = _book.description;

    final bool isMobileSize = Utilities.size.isMobileSize(context);

    Utilities.ui.showAdaptiveDialog(
      context,
      isMobileSize: isMobileSize,
      builder: (context) => InputDialog(
        asBottomSheet: isMobileSize,
        descriptionController: _descriptionController,
        nameController: _nameController,
        submitButtonValue: "rename".tr(),
        titleValue: "book_rename".tr().toUpperCase(),
        subtitleValue: "book_rename_description".tr(),
        onCancel: Beamer.of(context).popRoute,
        onSubmitted: (value) {
          tryRenameBook(
            _nameController.text,
            _descriptionController.text,
          );
          Beamer.of(context).popRoute();
        },
      ),
    );
  }

  void onTapIllustrationCard(
    String illustrationKey,
    Illustration illustration,
  ) {
    if (_multiSelectedItems.isEmpty && !_forceMultiSelect) {
      navigateToIllustrationPage(illustration, illustrationKey);
      return;
    }

    multiSelectIllustration(illustrationKey, illustration);
  }

  void onToggleDrag() {
    setState(() => _draggingActive = !_draggingActive);
    Utilities.storage.saveMobileDraggingActive(_draggingActive);
  }

  void onToggleMultiSelect() {
    setState(() {
      _forceMultiSelect = !_forceMultiSelect;
    });
  }

  void onUpdateVisibility(EnumContentVisibility visibility) async {
    final prevVisibility = _book.visibility;

    setState(() {
      _book = _book.copyWith(visibility: visibility);
    });

    try {
      final response =
          await Utilities.cloud.fun("books-updateVisibility").call({
        "book_id": _book.id,
        "visibility": visibility.name,
      });

      final bool success = response.data["success"];
      if (!success) {
        throw Error();
      }
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));

      setState(() {
        _book = _book.copyWith(visibility: prevVisibility);
      });
    }
  }

  void onUploadToThisBook() async {
    await ref
        .read(AppState.uploadTaskListProvider.notifier)
        .pickImageAndAddToBook(bookId: widget.bookId);
  }

  void removeIllustrationGroup() async {
    if (_book.id.isEmpty) {
      return;
    }

    _multiSelectedItems.entries.forEach(
      (MapEntry<String, Illustration> multiSelectItem) {
        _illustrationMap.removeWhere(
          (String key, Illustration value) => key == multiSelectItem.key,
        );
      },
    );

    final IllustrationMap duplicatedItems = Map.from(_multiSelectedItems);
    final List<String> illustrationIds = _multiSelectedItems.values
        .map((illustration) => illustration.id)
        .toList();

    setState(() {
      _multiSelectedItems.clear();
      _forceMultiSelect = false;
    });

    final response = await BooksActions.removeIllustrations(
      bookId: _book.id,
      illustrationIds: illustrationIds,
    );

    if (response.hasErrors) {
      context.showErrorBar(
        content: Text("illustrations_delete_error".tr()),
      );

      _illustrationMap.addAll(duplicatedItems);
    }
  }

  void removeIllustration({
    required int index,
    required Illustration illustration,
    required String illustrationKey,
  }) async {
    Illustration? removedIllustration;

    setState(() {
      removedIllustration = _illustrationMap.remove(illustrationKey);
    });

    if (removedIllustration == null) {
      return;
    }

    final IllustrationsResponse response =
        await BooksActions.removeIllustrations(
      bookId: _book.id,
      illustrationIds: [illustration.id],
    );

    if (response.hasErrors) {
      context.showErrorBar(
        content: Text("illustrations_remove_error".tr()),
      );

      setState(() {
        _illustrationMap.putIfAbsent(
          illustrationKey,
          () => illustration,
        );
      });

      context.showErrorBar(
        content: Text("illustrations_remove_error".tr()),
      );

      return;
    }
  }

  void showAddGroupToBook() {
    if (_multiSelectedItems.isEmpty) {
      context.showErrorBar(content: Text("multi_select_no_item".tr()));
      return;
    }

    final mapEntry = _multiSelectedItems.entries.first;
    showAddToBook(mapEntry.key, mapEntry.value);
  }

  void showAddToBook(String illustrationKey, Illustration illustration) {
    _multiSelectedItems.putIfAbsent(illustrationKey, () => illustration);

    showDialog(
      context: context,
      builder: (context) {
        return AddToBooksDialog(
          illustrations: _multiSelectedItems.values.toList(),
        );
      },
    );
  }

  void showShareDialog() {
    final bool isMobileSize = Utilities.size.isMobileSize(context);

    Utilities.ui.showAdaptiveDialog(
      context,
      isMobileSize: isMobileSize,
      builder: (BuildContext context) => ShareDialog(
        asBottomSheet: isMobileSize,
        extension: "",
        itemId: _book.id,
        imageProvider: NetworkImage(_book.getCoverLink()),
        name: _book.name,
        imageUrl: _book.getCoverLink(),
        shareContentType: EnumShareContentType.book,
        userId: _book.userId,
        username: "",
        visibility: _book.visibility,
        onShowVisibilityDialog: () => showVisibilityDialog(_book, 0),
      ),
    );
  }

  Future<EnumContentVisibility?>? showVisibilityDialog(
    Book book,
    int index,
  ) async {
    final double width = 310.0;

    return await showDialog<Future<EnumContentVisibility?>?>(
      context: context,
      builder: (context) => ThemedDialog(
        showDivider: true,
        titleValue: "book_visibility_change".plural(
          _multiSelectedItems.length,
        ),
        textButtonValidation: "close".tr(),
        onValidate: Beamer.of(context).popRoute,
        onCancel: Beamer.of(context).popRoute,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.only(left: 16.0),
                  width: width,
                  child: Opacity(
                    opacity: 0.6,
                    child: Text(
                      "book_visibility_choose".plural(
                        _multiSelectedItems.length,
                      ),
                      style: Utilities.fonts.body(
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ),
                VisibilityButton(
                  maxWidth: width,
                  visibility: book.visibility,
                  onChangedVisibility: (EnumContentVisibility visibility) =>
                      onChangedVisibility(
                    context,
                    visibility: visibility,
                    book: book,
                    index: index,
                  ),
                  padding: const EdgeInsets.only(
                    left: 16.0,
                    top: 12.0,
                    bottom: 32.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Delete the currevent viewing book
  /// and navigate back to the preview location or MyBooksPage.
  void tryDeleteBook() async {
    if (_book.id.isEmpty) {
      return;
    }

    // Will delete the book in background.
    BooksActions.deleteOne(
      bookId: _book.id,
    );

    _bookSubscription?.cancel();

    Beamer.of(context).beamToNamed(
      AtelierLocationContent.booksRoute,
      routeState: {"deletingBookId": _book.id},
    );
  }

  /// Add a book to a user's favourites.
  void tryLike() async {
    try {
      final String? userId = ref.read(AppState.userProvider).firestoreUser?.id;

      await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("user_likes")
          .doc(_book.id)
          .set({
        "type": "book",
        "target_id": _book.id,
        "user_id": userId,
      });
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    }
  }

  /// Rename one book.
  void tryRenameBook(String name, String description) async {
    final String prevName = _book.name;
    final String prevDescription = _book.description;

    setState(() {
      _book = _book.copyWith(
        name: name,
        description: description,
      );
    });

    try {
      final BookResponse response = await BooksActions.renameOne(
        name: name,
        description: description,
        bookId: _book.id,
      );

      if (response.success) {
        return;
      }

      setState(() {
        _book = _book.copyWith(
          name: prevName,
          description: prevDescription,
        );
      });

      context.showErrorBar(
        content: Text(response.error.details),
      );
    } catch (error) {
      Utilities.logger.e(error);
    }
  }

  /// Set back the book's cover mode as `last_illustration`.
  /// Delete any uploaded cover if any.
  void tryResetCover(Book book) async {
    setState(() => _updatingCover = true);

    try {
      final HttpsCallableResult response =
          await Utilities.cloud.fun("books-setCover").call({
        "book_id": _book.id,
        "cover_type": "last_illustration_added",
      });

      if (response.data["success"]) {
        return;
      }

      context.showErrorBar(content: Text("book_set_cover_error".tr()));
    } catch (error) {
      Utilities.logger.i(error);
      context.showErrorBar(content: Text(error.toString()));
    } finally {
      setState(() => _updatingCover = false);
    }
  }

  /// Set the passed illustration as the book's cover.
  /// This will also update the cover mode to `chosen_illustration`.
  void trySetIllustrationAsCover(Illustration illustration) async {
    setState(() => _updatingCover = true);

    try {
      final HttpsCallableResult response =
          await Utilities.cloud.fun("books-setCover").call({
        "book_id": _book.id,
        "illustration_id": illustration.id,
        "cover_type": "chosen_illustration",
      });

      if (response.data["success"]) {
        return;
      }

      context.showErrorBar(content: Text("book_set_cover_error".tr()));
    } catch (error) {
      Utilities.logger.i(error);
      context.showErrorBar(content: Text(error.toString()));
    } finally {
      setState(() => _updatingCover = false);
    }
  }

  /// Remove a book to a user's favourites.
  void tryUnLike() async {
    try {
      final String? userId = ref.read(AppState.userProvider).firestoreUser?.id;

      await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("user_likes")
          .doc(_book.id)
          .delete();
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    }
  }

  Future<EnumContentVisibility?> tryUpdateVisibility(
    Book book,
    EnumContentVisibility visibility,
    int index,
  ) async {
    try {
      final HttpsCallableResult response =
          await Utilities.cloud.fun("books-updateVisibility").call({
        "book_id": book.id,
        "visibility": visibility.name,
      });

      if (response.data["success"] as bool) {
        return visibility;
      }

      throw Error();
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
      return null;
    }
  }

  /// Pick a file, set book cover mode as `uploaded_cover`,
  /// and upload the file to Firebase Storage.
  /// Cloud functions will take the process from there, and changes will be
  /// automatically updated back into the app.
  void tryUploadCover(Book book) async {
    setState(() => _updatingCover = true);

    try {
      final UploadCoverResponse operationResult = await ref
          .read(AppState.uploadTaskListProvider.notifier)
          .pickImageAndSetAsBookCover(bookId: book.id);

      if (operationResult.success || operationResult.ignore) {
        return;
      }

      context.showErrorBar(content: Text(operationResult.errorMessage));
    } catch (error) {
      Utilities.logger.i(error);
      context.showErrorBar(content: Text(error.toString()));
    } finally {
      setState(() => _updatingCover = false);
    }
  }

  /// If the target illustration has [version] < 1,
  /// this method will listen to Firestore events in order to update
  /// the associated data in the map [_illustrationMap].
  void waitForThumbnail(String illustrationKey, DocumentMap query) {
    final DocSnapshotStreamSubscription illustrationSub =
        query.snapshots().listen(
      (snapshot) {
        final Map<String, dynamic>? data = snapshot.data();

        if (!snapshot.exists || data == null) {
          return;
        }

        data['id'] = snapshot.id;
        final illustration = Illustration.fromMap(data);

        if (illustration.version < 1) {
          return;
        }

        setState(() {
          _illustrationMap.update(
            illustrationKey,
            (value) => illustration,
            ifAbsent: () => illustration,
          );
        });

        if (_illustrationSubs.containsKey(illustration.id)) {
          final DocSnapshotStreamSubscription? targetSub =
              _illustrationSubs[illustration.id];

          targetSub?.cancel();
          _illustrationSubs.remove(illustration.id);
        }
      },
    );

    _illustrationSubs.putIfAbsent(query.id, () => illustrationSub);
  }
}
