import 'dart:async';

import 'package:artbooking/actions/books.dart';
import 'package:artbooking/components/dialogs/input_dialog.dart';
import 'package:artbooking/components/buttons/dark_elevated_button.dart';
import 'package:artbooking/components/application_bar/application_bar.dart';
import 'package:artbooking/components/popup_menu/popup_menu_item_icon.dart';
import 'package:artbooking/components/dialogs/themed_dialog.dart';
import 'package:artbooking/components/add_to_book_panel.dart';
import 'package:artbooking/router/locations/dashboard_location.dart';
import 'package:artbooking/router/navigation_state_helper.dart';
import 'package:artbooking/screens/book/book_page_body.dart';
import 'package:artbooking/screens/book/book_page_fab.dart';
import 'package:artbooking/screens/book/book_page_header.dart';
import 'package:artbooking/types/book/book.dart';
import 'package:artbooking/types/book/book_illustration.dart';
import 'package:artbooking/types/enums/enum_content_visibility.dart';
import 'package:artbooking/types/enums/enum_illustration_item_action.dart';
import 'package:artbooking/globals/app_state.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/firestore/document_map.dart';
import 'package:artbooking/types/firestore/doc_snapshot_stream_subscription.dart';
import 'package:artbooking/types/illustration/illustration.dart';
import 'package:beamer/beamer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flash/src/flash_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jiffy/jiffy.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:supercharged/supercharged.dart';
import 'package:unicons/unicons.dart';

/// A Map with [String] as key and [Illustration] as value.
typedef MapStringIllustration = Map<String, Illustration>;

class BookPage extends ConsumerStatefulWidget {
  const BookPage({
    Key? key,
    required this.bookId,
  }) : super(key: key);

  /// Book's id.
  final String bookId;

  @override
  _MyBookPageState createState() => _MyBookPageState();
}

class _MyBookPageState extends ConsumerState<BookPage> {
  /// The book displayed on this page.
  Book _book = Book.empty();

  /// True if the page is loading.
  bool _loading = false;

  /// True if there was an error while fetching data.
  bool _hasError = false;

  /// True if there's a next page to fetch for this book's illustrations.
  bool _hasNext = false;

  /// True if the floating action button is visible.
  bool _showFab = false;

  /// True if the view is in multiselect mode.
  bool _forceMultiSelect = false;

  /// True if there's a request to fetch the next illustration's batch.
  bool _isLoadingMore = false;

  /// True if the current authenticated user has liked this book.
  bool _liked = false;

  /// Why a map and not just a list?
  ///
  /// -> faster access & because it's already done.
  ///
  /// -> for [_multiSelectedItems] allow instant access to know
  /// if an illustration is currently in multi-select.
  final _illustrations = MapStringIllustration();
  final _keyboardFocusNode = FocusNode();

  /// Illustrations' ids matching [book.illustrations].
  /// Generated keys instead of simple ids due to possible duplicates.
  List<String> _currentIllustrationKeys = [];

  /// Count limit when fetchig this book's illustrations.
  int _limit = 20;

  /// The first illustration to fetch in the array.
  int _startIndex = 0;

  /// The last illustration to fetch in the array.
  int _endIndex = 0;

  /// Currently selected illustrations.
  MapStringIllustration _multiSelectedItems = Map();

  /// Handles page's scroll.
  ScrollController _scrollController = ScrollController();

  /// Items when opening the popup.
  final List<PopupMenuEntry<EnumIllustrationItemAction>> _popupMenuEntries = [
    PopupMenuItemIcon(
      value: EnumIllustrationItemAction.addToBook,
      icon: Icon(UniconsLine.book_medical),
      textLabel: "add_to_book".tr(),
    ),
    PopupMenuItemIcon(
      value: EnumIllustrationItemAction.removeFromBook,
      icon: Icon(UniconsLine.image_minus),
      textLabel: "remove".tr(),
    ),
  ];

  /// Listens to book's updates.
  DocSnapshotStreamSubscription? _bookSubscription;

  /// Listens to illustrations' updates.
  final Map<String, DocSnapshotStreamSubscription> _illustrationSubs = {};

  /// String separator to generate unique key for illustrations.
  final String _keySeparator = '--';

  /// Listent to changes for this book's like status.
  DocSnapshotStreamSubscription? _likeSubscription;

  @override
  initState() {
    super.initState();

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
  void dispose() {
    _bookSubscription?.cancel();
    _likeSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool owner =
        _book.userId == ref.read(AppState.userProvider).firestoreUser?.id;

    return Scaffold(
      floatingActionButton: BookPageFab(
        show: _showFab,
        scrollController: _scrollController,
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: onNotification,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: <Widget>[
            ApplicationBar(),
            BookPageHeader(
              book: _book,
              forceMultiSelect: _forceMultiSelect,
              liked: _liked,
              multiSelectedItems: _multiSelectedItems,
              onLike: onLike,
              onClearMultiSelect: onClearMultiSelect,
              onConfirmDeleteBook: onConfirmDeleteBook,
              onConfirmDeleteManyIllustrations:
                  onConfirmDeleteManyIllustrations,
              onMultiSelectAll: onMultiSelectAll,
              onToggleMultiSelect: onToggleMultiSelect,
              onShowDatesDialog: onShowDatesDialog,
              onShowRenameBookDialog: onShowRenameBookDialog,
              onUploadToThisBook: onUploadToThisBook,
              onUpdateVisibility: onUpdateVisibility,
              owner: owner,
            ),
            BookPageBody(
              loading: _loading,
              hasError: _hasError,
              forceMultiSelect: _forceMultiSelect,
              illustrations: _illustrations,
              multiSelectedItems: _multiSelectedItems,
              popupMenuEntries: _popupMenuEntries,
              onLongPressIllustration: onLongPressIllustration,
              onPopupMenuItemSelected: onPopupMenuItemSelected,
              onTapIllustrationCard: onTapIllustrationCard,
              owner: owner,
            ),
            SliverPadding(
              padding: const EdgeInsets.only(bottom: 100.0),
            ),
          ],
        ),
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
  void onConfirmDeleteBook() async {
    showDialog(
      context: context,
      builder: (context) {
        return ThemedDialog(
          focusNode: _keyboardFocusNode,
          title: Column(
            children: [
              Opacity(
                opacity: 0.8,
                child: Text(
                  "book_delete".tr().toUpperCase(),
                  style: Utilities.fonts.style(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                width: 300.0,
                padding: const EdgeInsets.only(top: 8.0),
                child: Opacity(
                  opacity: 0.4,
                  child: Text(
                    "book_delete_description".tr(),
                    textAlign: TextAlign.center,
                    style: Utilities.fonts.style(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(),
          textButtonValidation: "delete".tr(),
          onCancel: Beamer.of(context).popRoute,
          onValidate: () {
            deleteBook();
            Beamer.of(context).popRoute();
          },
        );
      },
    );
  }

  void onConfirmDeleteManyIllustrations() async {
    showCustomModalBottomSheet(
      context: context,
      builder: (context) {
        return Material(
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text(
                    'confirm'.tr(),
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  trailing: Icon(
                    Icons.check,
                    color: Colors.white,
                  ),
                  tileColor: Color(0xfff55c5c),
                  onTap: () {
                    Navigator.of(context).pop();
                    deleteManyIllustrations();
                  },
                ),
                ListTile(
                  title: Text('Cancel'.tr()),
                  trailing: Icon(Icons.close),
                  onTap: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        );
      },
      containerWidget: (context, animation, child) {
        return RawKeyboardListener(
          autofocus: true,
          focusNode: _keyboardFocusNode,
          onKey: (keyEvent) {
            if (keyEvent.isKeyPressed(LogicalKeyboardKey.enter)) {
              Navigator.of(context).pop();
              deleteManyIllustrations();
            }
          },
          child: SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 500.0,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 40.0,
                  ),
                  child: Material(
                    clipBehavior: Clip.antiAlias,
                    borderRadius: BorderRadius.circular(12.0),
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Delete the currevent viewing book
  /// and navigate back to the preview location or MyBooksPage.
  void deleteBook() async {
    if (_book.id.isEmpty) {
      return;
    }

    // Will delete the book in background.
    BooksActions.deleteOne(
      bookId: _book.id,
    );

    Beamer.of(context).beamToNamed(
      DashboardLocationContent.booksRoute,
    );
  }

  void deleteManyIllustrations() async {
    if (_book.id.isEmpty) {
      return;
    }

    _multiSelectedItems.entries.forEach(
      (MapEntry<String, Illustration> multiSelectItem) {
        _illustrations.removeWhere(
          (String key, Illustration value) => key == multiSelectItem.key,
        );
      },
    );

    final MapStringIllustration duplicatedItems = Map.from(_multiSelectedItems);
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

      _illustrations.addAll(duplicatedItems);
    }
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
      startListenningToData(query);

      setState(() {
        _book = Book.fromMap(bookData);
        _currentIllustrationKeys = _book.illustrations
            .map((bookIllustration) => generateKey(bookIllustration))
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

    final illustrationsBook = _book.illustrations;

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
        final illustrationSnap = await FirebaseFirestore.instance
            .collection('illustrations')
            .doc(bookIllustration.id)
            .get();

        if (!illustrationSnap.exists) {
          continue;
        }

        final illustrationData = illustrationSnap.data()!;
        illustrationData['id'] = illustrationSnap.id;

        final illustration = Illustration.fromMap(illustrationData);
        _illustrations.putIfAbsent(
          generateKey(bookIllustration),
          () => illustration,
        );

        setState(() => _loading = false);
      } catch (error) {
        Utilities.logger.e(error);
        illustrationsErrors.add(bookIllustration.id);
      }
    }

    checkFetchErrors(illustrationsErrors);
  }

  void fetchIllustrationsAndListenToUpdates() {
    fetchIllustrations();

    final query =
        FirebaseFirestore.instance.collection('books').doc(widget.bookId);

    startListenningToData(query);
  }

  void fetchIllustrationsMore() async {
    if (!_hasNext || _book.id.isEmpty || _isLoadingMore) {
      return;
    }

    _startIndex = _endIndex;
    _endIndex = _endIndex + _limit;
    _isLoadingMore = true;

    final range = _book.illustrations.getRange(_startIndex, _endIndex);

    try {
      for (var bookIllustration in range) {
        final illustrationSnap = await FirebaseFirestore.instance
            .collection('illustrations')
            .doc(bookIllustration.id)
            .get();

        if (!illustrationSnap.exists) {
          continue;
        }

        final illustrationData = illustrationSnap.data()!;
        illustrationData['id'] = illustrationSnap.id;

        final illustration = Illustration.fromMap(illustrationData);
        _illustrations.putIfAbsent(
          generateKey(bookIllustration),
          () => illustration,
        );
      }
      setState(() {
        _hasNext = _endIndex < _book.count;
      });
    } catch (error) {
      Utilities.logger.e(error);
    } finally {
      setState(() => _isLoadingMore = false);
    }
  }

  void fetchLike() async {
    try {
      final String? userId = ref.read(AppState.userProvider).firestoreUser?.id;

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

  /// Generate an unique key for illustrations in book (frontend).
  String generateKey(BookIllustration bookIllustration) {
    final String id = bookIllustration.id;
    DateTime createdAt = bookIllustration.createdAt;

    return "$id$_keySeparator${createdAt.millisecondsSinceEpoch}";
  }

  /// Find new values in [book.illustrations]
  /// that weren't there before the update.
  /// -------------------------------------------
  /// For each id in the new data:
  ///
  /// • if the value exists in [_illustrations] → nothing changed
  ///
  /// • if the value doesn't exist in [_illustrations] → new value.
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
        if (_illustrations.containsKey(illustrationKey)) {
          return false;
        }

        return true;
      },
    ).toList();

    for (String illustrationKey in added) {
      final idAndCreatedAt = illustrationKey.split(_keySeparator);
      final illustrationId = idAndCreatedAt.elementAt(0);

      final DocumentMap query = FirebaseFirestore.instance
          .collection('illustrations')
          .doc(illustrationId);

      final illustrationSnap = await query.get();
      final illustrationData = illustrationSnap.data();

      if (!illustrationSnap.exists || illustrationData == null) {
        continue;
      }

      illustrationData['id'] = illustrationSnap.id;

      final illustration = Illustration.fromMap(illustrationData);

      setState(() {
        _illustrations.putIfAbsent(
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
    final Iterable<String> customRemovedIds = _illustrations.filter(
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
        _illustrations.remove(customId);
      }
    });
  }

  void multiSelectIllustration(
      String illustrationKey, Illustration illustration) {
    final selected = _multiSelectedItems.containsKey(illustrationKey);

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

  void navigateToIllustrationPage(Illustration illustration) {
    NavigationStateHelper.illustration = illustration;
    final String route = DashboardLocationContent.illustrationBookRoute
        .replaceFirst(":bookId", _book.id)
        .replaceFirst(":illustrationId", illustration.id);

    Beamer.of(context).beamToNamed(
      route,
      data: {
        "bookId": _book.id,
        "illustrationId": illustration.id,
      },
    );
  }

  void onClearMultiSelect() {
    setState(() {
      _multiSelectedItems.clear();
      _forceMultiSelect = _multiSelectedItems.length > 0;
    });
  }

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
    _illustrations.forEach((String key, Illustration illustration) {
      _multiSelectedItems.putIfAbsent(
        key,
        () => illustration,
      );
    });

    setState(() {});
  }

  /// On scroll notifications.
  bool onNotification(ScrollNotification notification) {
    // FAB visibility
    if (notification.metrics.pixels < 50 && _showFab) {
      setState(() {
        _showFab = false;
      });
    } else if (notification.metrics.pixels > 50 && !_showFab) {
      setState(() {
        _showFab = true;
      });
    }

    if (notification.metrics.pixels < notification.metrics.maxScrollExtent) {
      return false;
    }

    if (_hasNext && !_isLoadingMore) {
      fetchIllustrationsMore();
    }

    return false;
  }

  void onPopupMenuItemSelected(EnumIllustrationItemAction action, int index,
      Illustration illustration, String illustrationKey) {
    switch (action) {
      case EnumIllustrationItemAction.addToBook:
        showAddToBook(illustration);
        break;
      case EnumIllustrationItemAction.removeFromBook:
        onRemoveIllustrationFromBook(
          index: index,
          illustration: illustration,
          illustrationKey: illustrationKey,
        );
        break;
      default:
    }
  }

  void onRemoveIllustrationFromBook({
    required int index,
    required Illustration illustration,
    required String illustrationKey,
  }) async {
    Illustration? removedIllustration;

    setState(() {
      removedIllustration = _illustrations.remove(illustrationKey);
    });

    if (removedIllustration == null) {
      return;
    }

    final response = await BooksActions.removeIllustrations(
      bookId: _book.id,
      illustrationIds: [illustration.id],
    );

    if (response.hasErrors) {
      context.showErrorBar(
        content: Text("illustrations_remove_error".tr()),
      );

      setState(() {
        _illustrations.putIfAbsent(
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

  void onTapIllustrationCard(
    String illustrationKey,
    Illustration illustration,
  ) {
    if (_multiSelectedItems.isEmpty && !_forceMultiSelect) {
      navigateToIllustrationPage(illustration);
      return;
    }

    multiSelectIllustration(illustrationKey, illustration);
  }

  void onToggleMultiSelect() {
    setState(() {
      _forceMultiSelect = !_forceMultiSelect;
    });
  }

  /// Rename one book.
  void renameBook(String name, String description) async {
    final prevName = _book.name;
    final prevDescription = _book.description;

    setState(() {
      _book = _book.copyWith(
        name: name,
        description: description,
      );
    });

    try {
      final response = await BooksActions.renameOne(
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

  void showAddToBook(Illustration illustration) {
    int flex = Utilities.size.isMobileSize(context) ? 5 : 3;

    showCustomModalBottomSheet(
      context: context,
      builder: (context) => AddToBookPanel(
        scrollController: ModalScrollController.of(context),
        illustrations: [illustration],
      ),
      containerWidget: (context, animation, child) {
        return SafeArea(
          child: Row(
            children: [
              Spacer(),
              Expanded(
                flex: flex,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Material(
                    clipBehavior: Clip.antiAlias,
                    borderRadius: BorderRadius.circular(12.0),
                    child: child,
                  ),
                ),
              ),
              Spacer(),
            ],
          ),
        );
      },
    );
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
                  style: Utilities.fonts.style(
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
                Text("• "),
                Opacity(
                  opacity: 0.6,
                  child: Text(
                    createdAtStr,
                    style: Utilities.fonts.style(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text("• "),
                Opacity(
                  opacity: 0.6,
                  child: Text(
                    updatedAtStr,
                    style: Utilities.fonts.style(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
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

    showDialog(
      context: context,
      builder: (context) => InputDialog(
        descriptionController: _descriptionController,
        nameController: _nameController,
        submitButtonValue: "rename".tr(),
        titleValue: "book_rename".tr().toUpperCase(),
        subtitleValue: "book_rename_description".tr(),
        onCancel: Beamer.of(context).popRoute,
        onSubmitted: (value) {
          renameBook(
            _nameController.text,
            _descriptionController.text,
          );
          Beamer.of(context).popRoute();
        },
      ),
    );
  }

  void startListenningToData(DocumentReference<Map<String, dynamic>> query) {
    _bookSubscription = query.snapshots().skip(1).listen(
      (DocumentSnapshot<Map<String, dynamic>> snapshot) {
        final bookData = snapshot.data();
        if (!snapshot.exists || bookData == null) {
          return;
        }

        setState(() {
          bookData['id'] = snapshot.id;
          _book = Book.fromMap(bookData);
          _currentIllustrationKeys = _book.illustrations
              .map((bookIllustration) => generateKey(bookIllustration))
              .toList();
        });

        diffIllustrations();
      },
      onError: (error) {
        Utilities.logger.e(error);
      },
    );
  }

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

  void onUploadToThisBook() async {
    await ref
        .read(AppState.uploadTaskListProvider.notifier)
        .pickImageAndAddToBook(bookId: widget.bookId);
  }

  /// If the target illustration has [version] < 1,
  /// this method will listen to Firestore events in order to update
  /// the associated data in the map [_illustrations].
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
          _illustrations.update(
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
}
