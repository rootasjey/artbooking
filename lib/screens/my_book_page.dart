import 'dart:async';

import 'package:artbooking/actions/books.dart';
import 'package:artbooking/components/animated_app_icon.dart';
import 'package:artbooking/components/dark_elevated_button.dart';
import 'package:artbooking/components/illustration_card.dart';
import 'package:artbooking/components/main_app_bar.dart';
import 'package:artbooking/components/popup_menu_item_icon.dart';
import 'package:artbooking/components/sliver_edge_padding.dart';
import 'package:artbooking/components/text_divider.dart';
import 'package:artbooking/components/text_rectangle_button.dart';
import 'package:artbooking/components/underlined_button.dart';
import 'package:artbooking/components/user_books.dart';
import 'package:artbooking/router/locations/dashboard_location.dart';
import 'package:artbooking/router/navigation_state_helper.dart';
import 'package:artbooking/state/colors.dart';
import 'package:artbooking/state/upload_manager.dart';
import 'package:artbooking/types/book.dart';
import 'package:artbooking/types/book_illustration.dart';
import 'package:artbooking/types/enums.dart';
import 'package:artbooking/types/illustration/illustration.dart';
import 'package:artbooking/utils/app_logger.dart';
import 'package:artbooking/utils/cloud_helper.dart';
import 'package:artbooking/utils/constants.dart';
import 'package:artbooking/utils/fonts.dart';
import 'package:artbooking/utils/snack.dart';
import 'package:beamer/beamer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jiffy/jiffy.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:supercharged/supercharged.dart';
import 'package:unicons/unicons.dart';

/// A Firestore document query reference.
typedef DocumentMap = DocumentReference<Map<String, dynamic>>;

/// A stream subscription returning a map withing a query snapshot.
typedef SnapshotStreamSubscription
    = StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>;

/// A Map with [String] as key and [Illustration] as value.
typedef MapStringIllustration = Map<String, Illustration>;

class MyBookPage extends StatefulWidget {
  final String bookId;
  final Book? book;

  const MyBookPage({
    Key? key,
    required this.bookId,
    this.book,
  }) : super(key: key);
  @override
  _MyBookPageState createState() => _MyBookPageState();
}

class _MyBookPageState extends State<MyBookPage> {
  /// The viewing book.
  Book? _bookPage;

  bool _isLoading = false;
  bool _hasError = false;
  bool _hasNext = false;
  bool _isFabVisible = false;
  bool _forceMultiSelect = false;
  bool _isLoadingMore = false;

  // Why a map and not just a list?
  // -> faster access & because it's already done.
  // -> for [_multiSelectedItems] allow instant access to know
  // if an illustration is currently in multi-select.
  final _illustrations = MapStringIllustration();
  final _keyboardFocusNode = FocusNode();

  /// Illustrations' ids matching [_bookPage.illustrations].
  /// Generated keys instead of simple ids due to possible duplicates.
  List<String> _currentIllusKeys = [];

  int _limit = 20;
  int _startIndex = 0;
  int _endIndex = 0;

  MapStringIllustration _multiSelectedItems = Map();
  Map<int, Illustration> _processingIllustrations = Map();

  ScrollController _scrollController = ScrollController();

  final List<PopupMenuEntry<IllustrationItemAction>> _popupMenuEntries = [
    PopupMenuItemIcon(
      value: IllustrationItemAction.addToBook,
      icon: Icon(UniconsLine.book_medical),
      textLabel: "add_to_book".tr(),
    ),
    PopupMenuItemIcon(
      value: IllustrationItemAction.removeFromBook,
      icon: Icon(UniconsLine.image_minus),
      textLabel: "remove".tr(),
    ),
  ];

  SnapshotStreamSubscription? _streamSubscription;

  final Map<String, SnapshotStreamSubscription> _illustrationSubs = {};

  final String _keySeparator = '--';

  @override
  initState() {
    super.initState();

    if (widget.book == null) {
      fetchBookAndIllustrations();
    } else {
      fetchIllustrationsAndListenToUpdates();
    }
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: fab(),
      body: NotificationListener<ScrollNotification>(
        onNotification: onNotification,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: <Widget>[
            SliverEdgePadding(),
            MainAppBar(),
            header(),
            body(),
            SliverPadding(
              padding: const EdgeInsets.only(bottom: 100.0),
            ),
          ],
        ),
      ),
    );
  }

  Widget bookCoverCard() {
    if (_bookPage == null) {
      return SizedBox(
        height: 260.0,
        width: 200.0,
        child: Card(
          elevation: 2.0,
          color: stateColors.clairPink,
        ),
      );
    }

    return Hero(
      tag: _bookPage!.id,
      child: SizedBox(
        height: 260.0,
        width: 200.0,
        child: Card(
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          clipBehavior: Clip.antiAlias,
          child: Ink.image(
            image: NetworkImage(_bookPage!.getCoverUrl()),
            height: 260.0,
            width: 200.0,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget body() {
    if (_isLoading) {
      return SliverList(
        delegate: SliverChildListDelegate.fixed([
          Padding(
            padding: const EdgeInsets.only(top: 100.0),
            child: AnimatedAppIcon(
              textTitle: "illustrations_loading".tr(),
            ),
          ),
        ]),
      );
    }

    if (_hasError) {
      return errorView();
    }

    if (_illustrations.isEmpty) {
      return emptyView();
    }

    return gridView();
  }

  Widget createdAt() {
    if (_bookPage == null) {
      return Container();
    }

    final DateTime? createdAt = _bookPage!.createdAt;

    if (createdAt == null) {
      return Container();
    }

    String createdAtStr = "";

    if (DateTime.now().difference(createdAt).inDays > 60) {
      createdAtStr = "date_created_at".tr(
        args: [
          Jiffy(_bookPage!.createdAt).yMMMMEEEEd,
        ],
      );
    } else {
      createdAtStr = "date_created_ago".tr(
        args: [Jiffy(_bookPage!.createdAt).fromNow()],
      );
    }

    return Opacity(
      opacity: 0.6,
      child: Text(
        createdAtStr,
        style: FontsUtils.mainStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget description() {
    if (_bookPage == null) {
      return Container();
    }

    return Opacity(
      opacity: 0.6,
      child: Text(
        _bookPage!.description,
        style: FontsUtils.mainStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget defaultActionsToolbar() {
    if (_multiSelectedItems.isNotEmpty) {
      return Container();
    }

    return Wrap(
      spacing: 12.0,
      runSpacing: 12.0,
      children: [
        uploadToBookButton(),
        multiSelectButton(),
      ],
    );
  }

  Widget emptyView() {
    return SliverPadding(
      padding: const EdgeInsets.only(
        top: 40.0,
        left: 50.0,
      ),
      sliver: SliverList(
        delegate: SliverChildListDelegate.fixed([
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Opacity(
                  opacity: 0.8,
                  child: Icon(
                    UniconsLine.trees,
                    size: 80.0,
                    color: Colors.lightGreen,
                  ),
                ),
              ),
              Opacity(
                opacity: 0.6,
                child: Text(
                  "new_start_sentence".tr().toUpperCase(),
                  style: FontsUtils.mainStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                width: 400.0,
                padding: const EdgeInsets.only(
                  bottom: 16.0,
                ),
                child: Opacity(
                  opacity: 0.4,
                  child: Text(
                    "book_no_illustrations".tr(),
                    textAlign: TextAlign.center,
                    style: FontsUtils.mainStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ),
              emptyViewActions(),
            ],
          ),
        ]),
      ),
    );
  }

  Widget emptyViewActions() {
    return Container(
      width: 400.0,
      padding: const EdgeInsets.only(top: 24.0),
      child: Column(
        children: [
          IconButton(
            tooltip: "book_upload_illustration".tr(),
            onPressed: uploadToThisBook,
            icon: Icon(UniconsLine.upload),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: TextDivider(
              text: Opacity(
                opacity: 0.6,
                child: Text(
                  "or".tr().toUpperCase(),
                  style: FontsUtils.mainStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          UnderlinedButton(
            onTap: () {
              context.beamToNamed(DashboardContentLocation.illustrationsRoute);
            },
            child: Text("illustrations_yours_browse".tr()),
          ),
        ],
      ),
    );
  }

  Widget errorView() {
    return SliverPadding(
      padding: const EdgeInsets.only(
        top: 40.0,
        left: 50.0,
      ),
      sliver: SliverList(
        delegate: SliverChildListDelegate.fixed([
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 12.0,
                ),
                child: Text(
                  "issue_unexpected".tr(),
                  style: TextStyle(
                    fontSize: 32.0,
                    color: stateColors.primary,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 16.0,
                  // top: 24.0,
                ),
                child: Opacity(
                  opacity: 0.4,
                  child: Text(
                    "issue_data_retry".tr(),
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: fetchBookAndIllustrations,
                icon: Icon(UniconsLine.refresh),
                label: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    "retry".tr(),
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ]),
      ),
    );
  }

  Widget fab() {
    if (!_isFabVisible) {
      return FloatingActionButton(
        onPressed: fetchIllustrations,
        backgroundColor: stateColors.primary,
        foregroundColor: Colors.white,
        child: Icon(UniconsLine.refresh),
      );
    }

    return FloatingActionButton(
      onPressed: () {
        _scrollController.animateTo(
          0.0,
          duration: 1.seconds,
          curve: Curves.easeOut,
        );
      },
      backgroundColor: stateColors.primary,
      foregroundColor: Colors.white,
      child: Icon(UniconsLine.arrow_up),
    );
  }

  Widget gridView() {
    final selectionMode = _forceMultiSelect || _multiSelectedItems.isNotEmpty;

    return SliverPadding(
      padding: const EdgeInsets.all(40.0),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 300.0,
          mainAxisSpacing: 20.0,
          crossAxisSpacing: 20.0,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final illustration = _illustrations.values.elementAt(index);
            final illustrationKey = _illustrations.keys.elementAt(index);
            final selected = _multiSelectedItems.containsKey(illustrationKey);

            return IllustrationCard(
              index: index,
              heroTag: illustrationKey,
              illustration: illustration,
              key: ValueKey(illustrationKey),
              selected: selected,
              selectionMode: selectionMode,
              onPopupMenuItemSelected: onPopupMenuItemSelected,
              popupMenuEntries: _popupMenuEntries,
              onLongPress: (selected) {
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
              },
            );
          },
          childCount: _illustrations.length,
        ),
      ),
    );
  }

  Widget header() {
    return SliverPadding(
      padding: const EdgeInsets.only(
        top: 60.0,
        left: 50.0,
        bottom: 24.0,
      ),
      sliver: SliverList(
        delegate: SliverChildListDelegate.fixed([
          headerTop(),
          headerBottom(),
        ]),
      ),
    );
  }

  Widget headerBottom() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 32.0,
        left: 8.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          defaultActionsToolbar(),
          multiSelectToolbar(),
        ],
      ),
    );
  }

  Widget headerTop() {
    return Wrap(
      spacing: 24.0,
      runSpacing: 24.0,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        bookCoverCard(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Opacity(
              opacity: 0.6,
              child: IconButton(
                tooltip: "back".tr(),
                onPressed: Beamer.of(context).popRoute,
                icon: Icon(UniconsLine.arrow_left),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  title(),
                  description(),
                  updatedAt(),
                  stats(),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget multiSelectButton() {
    if (_illustrations.isEmpty) {
      return Container();
    }

    return TextRectangleButton(
      onPressed: () {
        setState(() {
          _forceMultiSelect = !_forceMultiSelect;
        });
      },
      icon: Icon(UniconsLine.layers_alt),
      label: Text('multi_select'.tr()),
      primary: _forceMultiSelect ? Colors.lightGreen : Colors.black38,
    );
  }

  Widget multiSelectToolbar() {
    if (_multiSelectedItems.isEmpty) {
      return Container();
    }

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Opacity(
          opacity: 0.6,
          child: Text(
            "multi_items_selected"
                .tr(args: [_multiSelectedItems.length.toString()]),
            style: TextStyle(
              fontSize: 30.0,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Container(
            height: 25.0,
            width: 2.0,
            color: Colors.black12,
          ),
        ),
        TextButton.icon(
          onPressed: () {
            setState(() {
              _multiSelectedItems.clear();
            });
          },
          icon: Icon(Icons.border_clear),
          label: Text('clear_selection'.tr()),
        ),
        TextButton.icon(
          onPressed: () {
            // _illustrations.values.forEach((illustration) {
            //   _multiSelectedItems.putIfAbsent(
            //     generateKey(illustration),
            //     () => illustration,
            //   );
            // });
            _illustrations.forEach((String key, Illustration illustration) {
              _multiSelectedItems.putIfAbsent(
                key,
                () => illustration,
              );
            });

            setState(() {});
          },
          icon: Icon(Icons.select_all),
          label: Text('select_all'.tr()),
        ),
        TextButton.icon(
          onPressed: confirmSelectionDeletion,
          style: TextButton.styleFrom(
            primary: Colors.red,
          ),
          icon: Icon(Icons.delete_outline),
          label: Text('delete'.tr()),
        ),
      ],
    );
  }

  Widget stats() {
    if (_bookPage == null) {
      return Container();
    }

    final Color color = _bookPage!.illustrations.isEmpty
        ? stateColors.secondary
        : stateColors.primary;

    return Opacity(
      opacity: 0.8,
      child: Text(
        "illustrations_count".plural(_bookPage!.illustrations.length),
        style: FontsUtils.mainStyle(
          color: color,
          fontSize: 16.0,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget title() {
    final bookName = _bookPage != null ? _bookPage!.name : 'My book';

    return Opacity(
      opacity: 0.8,
      child: Text(
        bookName,
        style: FontsUtils.mainStyle(
          fontSize: 40.0,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget updatedAt({bool clickable = true}) {
    if (_bookPage == null) {
      return Container();
    }

    final DateTime? updatedAt = _bookPage!.updatedAt;

    if (updatedAt == null) {
      return Container();
    }

    String updatedAtStr = "";

    if (DateTime.now().difference(updatedAt).inDays > 60) {
      updatedAtStr = "date_updated_at".tr(
        args: [
          Jiffy(_bookPage!.updatedAt).yMMMMEEEEd,
        ],
      );
    } else {
      updatedAtStr = "date_updated_ago".tr(
        args: [Jiffy(_bookPage!.updatedAt).fromNow()],
      );
    }

    return InkWell(
      onTap: clickable ? showDatesDialog : null,
      child: Opacity(
        opacity: 0.6,
        child: Text(
          updatedAtStr,
          style: FontsUtils.mainStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget uploadToBookButton() {
    return Tooltip(
      message: "book_upload_illustration".tr(),
      child: InkWell(
        onTap: uploadToThisBook,
        child: Opacity(
          opacity: 0.4,
          child: Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              border: Border.all(
                width: 2.0,
                color: Colors.black54,
              ),
            ),
            child: Icon(UniconsLine.upload),
          ),
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

    Cloud.fun('books-removeDeletedIllustrations').call({
      'bookId': widget.bookId,
      'illustrationIds': illustrationsErrors,
    }).catchError((error, stack) {
      appLogger.e(error);
      throw error;
    });
  }

  void confirmBookDeletion(Illustration illustration, int index) async {
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
                    "delete".tr(),
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  trailing: Icon(
                    UniconsLine.check,
                    color: Colors.white,
                  ),
                  tileColor: Color(0xfff55c5c),
                  onTap: () {
                    Beamer.of(context).popRoute();
                    deleteBook(illustration, index);
                  },
                ),
                ListTile(
                  title: Text("cancel".tr()),
                  trailing: Icon(UniconsLine.times),
                  onTap: Beamer.of(context).popRoute,
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
              deleteBook(illustration, index);
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

  void confirmSelectionDeletion() async {
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
                    deleteSelection();
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
              deleteSelection();
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

  // TODO: Populate.
  // Only allow remove from book o this view.
  void deleteBook(Illustration illustration, int index) async {}

  // TODO: Use another variable to remove multiple illustrations.
  void deleteSelection() async {
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
      bookId: _bookPage!.id,
      illustrationIds: illustrationIds,
    );

    if (response.hasErrors) {
      Snack.e(
        context: context,
        message: "illustrations_delete_error".tr(),
      );

      _illustrations.addAll(duplicatedItems);
    }
  }

  /// Get a differenciation of illustrations in this book
  /// and add or remove illustration accordingly.
  void diffIllustrations() {
    if (_bookPage == null) {
      return;
    }

    handleAddedIllustrations();
    handleRemovedIllustrations();
  }

  void fetchBookAndIllustrations() async {
    await fetchBook();
    fetchIllustrations();
  }

  Future fetchBook() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final query =
          FirebaseFirestore.instance.collection('books').doc(widget.bookId);

      final bookSnap = await query.get();
      final bookData = bookSnap.data();

      if (!bookSnap.exists || bookData == null) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });

        return;
      }

      bookData['id'] = bookSnap.id;
      startListenningToData(query);

      setState(() {
        _bookPage = Book.fromJSON(bookData);
        _currentIllusKeys = _bookPage!.illustrations
            .map((bookIllustration) => generateKey(bookIllustration))
            .toList();
      });
    } catch (error) {
      appLogger.e(error);

      setState(() => _hasError = true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Fetch an range of illustrations of a book.
  void fetchIllustrations() async {
    if (_bookPage == null) {
      return;
    }

    final illustrationsBook = _bookPage!.illustrations;

    setState(() {
      _isLoading = true;
      _startIndex = 0;
      _endIndex = illustrationsBook.length >= _limit
          ? _limit
          : illustrationsBook.length;
    });

    if (illustrationsBook.isEmpty) {
      setState(() => _isLoading = false);
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

        final illustration = Illustration.fromJSON(illustrationData);
        _illustrations.putIfAbsent(
          generateKey(bookIllustration),
          () => illustration,
        );

        setState(() => _isLoading = false);
      } catch (error) {
        appLogger.e(error);
        illustrationsErrors.add(bookIllustration.id);
      }
    }

    checkFetchErrors(illustrationsErrors);
  }

  void fetchIllustrationsAndListenToUpdates() {
    _bookPage = widget.book;
    fetchIllustrations();

    final query =
        FirebaseFirestore.instance.collection('books').doc(widget.bookId);

    startListenningToData(query);
  }

  void fetchIllustrationsMore() async {
    if (!_hasNext || _bookPage == null || _isLoadingMore) {
      return;
    }

    _startIndex = _endIndex;
    _endIndex = _endIndex + _limit;
    _isLoadingMore = true;

    final range = _bookPage!.illustrations.getRange(_startIndex, _endIndex);

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

        final illustration = Illustration.fromJSON(illustrationData);
        _illustrations.putIfAbsent(
          generateKey(bookIllustration),
          () => illustration,
        );
      }
      setState(() {
        _hasNext = _endIndex < _bookPage!.count;
      });
    } catch (error) {
      appLogger.e(error);
    } finally {
      setState(() => _isLoadingMore = false);
    }
  }

  /// Generate an unique key for illustrations in book (frontend).
  String generateKey(BookIllustration bookIllustration) {
    final String id = bookIllustration.id;
    DateTime createdAt = bookIllustration.createdAt;

    return "$id$_keySeparator${createdAt.millisecondsSinceEpoch}";
  }

  /// Find new values in [_bookPage.illustrations]
  /// that weren't there before the update.
  /// -------------------------------------------
  /// For each id in the new data:
  ///
  /// • if the value exists in [_illustrations] → nothing changed
  ///
  /// • if the value doesn't exist in [_illustrations] → new value.
  void handleAddedIllustrations() async {
    final List<String> added = _currentIllusKeys.filter(
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

      final illustration = Illustration.fromJSON(illustrationData);

      setState(() {
        _illustrations.putIfAbsent(
          illustrationKey,
          () => illustration,
        );
      });

      if (illustration.hasPendingCreates) {
        waitForThumbnail(illustrationKey, query);
      }
    }
  }

  /// We want values that were there before
  /// but has been removed in the update.
  /// -------------------------------------------
  /// For each id in new data:
  ///
  /// • if the value exist in [_currentIllusKeys] → nothing changed
  ///
  /// • if the value doesn't exist in [_currentIllusKeys] → removed value.
  void handleRemovedIllustrations() {
    final Iterable<String> customRemovedIds = _illustrations.filter(
      (MapEntry<String, Illustration> mapEntry) {
        // final Illustration illustration = mapEntry.value;

        // if (_currentIllusKeys.contains(illustration.id)) {
        //   return false;
        // }
        if (_currentIllusKeys.contains(mapEntry.key)) {
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

  /// On scroll notifications.
  bool onNotification(ScrollNotification notification) {
    // FAB visibility
    if (notification.metrics.pixels < 50 && _isFabVisible) {
      setState(() {
        _isFabVisible = false;
      });
    } else if (notification.metrics.pixels > 50 && !_isFabVisible) {
      setState(() {
        _isFabVisible = true;
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

  void onRemoveFromBook({
    required int index,
    required Illustration illustration,
    required String illustrationKey,
  }) async {
    setState(() {
      _processingIllustrations.putIfAbsent(index, () => illustration);
      _illustrations.remove(illustrationKey);
    });

    final response = await BooksActions.removeIllustrations(
      bookId: _bookPage!.id,
      illustrationIds: [illustration.id],
    );

    if (response.hasErrors) {
      Snack.e(
        context: context,
        message: "illustrations_remove_error".tr(),
      );

      _processingIllustrations.forEach((pIndex, pIllustration) {
        _illustrations.putIfAbsent(illustrationKey, () => pIllustration);
      });

      setState(() {
        _processingIllustrations.clear();
      });

      return;
    }

    Snack.s(
      context: context,
      message: "illustrations_remove_success".tr(),
    );

    setState(() {
      _processingIllustrations.clear();
    });
  }

  void onTapIllustrationCard(
      String illustrationKey, Illustration illustration) {
    if (_multiSelectedItems.isEmpty && !_forceMultiSelect) {
      navigateToIllustrationPage(illustration);
      return;
    }

    multiSelectIllustration(illustrationKey, illustration);
  }

  void navigateToIllustrationPage(Illustration illustration) {
    NavigationStateHelper.illustration = illustration;

    context.currentBeamLocation.update(
      (state) => state.copyWith(
        pathBlueprintSegments: [
          'dashboard',
          'illustrations',
          ':illustrationId',
        ],
        pathParameters: {
          'illustrationId': illustration.id,
        },
      ),
    );
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

  void onPopupMenuItemSelected(IllustrationItemAction action, int index,
      Illustration illustration, String illustrationKey) {
    switch (action) {
      case IllustrationItemAction.delete:
        confirmBookDeletion(illustration, index);
        break;
      case IllustrationItemAction.addToBook:
        showAddToBook(illustration);
        break;
      case IllustrationItemAction.removeFromBook:
        onRemoveFromBook(
          index: index,
          illustration: illustration,
          illustrationKey: illustrationKey,
        );
        break;
      default:
    }
  }

  void showAddToBook(Illustration illustration) {
    int flex =
        MediaQuery.of(context).size.width < Constants.maxMobileWidth ? 5 : 3;

    showCustomModalBottomSheet(
      context: context,
      builder: (context) => UserBooks(
        scrollController: ModalScrollController.of(context),
        illustration: illustration,
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

  void showDatesDialog() {
    showDialog(
      context: context,
      builder: (context) {
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
                  style: FontsUtils.mainStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Divider(
                thickness: 1.5,
                color: stateColors.secondary,
              ),
            ],
          ),
          contentPadding: const EdgeInsets.all(24.0),
          children: [
            Row(
              children: [
                Text("• "),
                createdAt(),
              ],
            ),
            Row(
              children: [
                Text("• "),
                updatedAt(clickable: false),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: DarkElevatedButton(
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

  void uploadToThisBook() async {
    await appUploadManager.pickImageAndAddToBook(
      context,
      bookId: widget.bookId,
    );
  }

  void startListenningToData(DocumentReference<Map<String, dynamic>> query) {
    _streamSubscription = query.snapshots().skip(1).listen(
      (DocumentSnapshot<Map<String, dynamic>> snapshot) {
        final bookData = snapshot.data();
        if (!snapshot.exists || bookData == null) {
          return;
        }

        setState(() {
          bookData['id'] = snapshot.id;
          _bookPage = Book.fromJSON(bookData);
          _currentIllusKeys = _bookPage!.illustrations
              .map((bookIllustration) => generateKey(bookIllustration))
              .toList();
        });

        diffIllustrations();
      },
      onError: (error) {
        appLogger.e(error);
      },
    );
  }

  /// If the target illustration has [hasPendingCreates] set to true,
  /// this method will listen to Firestore events in order to update
  /// the associated data in the map [_illustrations].
  void waitForThumbnail(String illustrationKey, DocumentMap query) {
    final SnapshotStreamSubscription illustrationSub = query.snapshots().listen(
      (snapshot) {
        final Map<String, dynamic>? data = snapshot.data();

        if (!snapshot.exists || data == null) {
          return;
        }

        data['id'] = snapshot.id;
        final illustration = Illustration.fromJSON(data);

        if (illustration.hasPendingCreates) {
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
          final SnapshotStreamSubscription? targetSub =
              _illustrationSubs[illustration.id];

          targetSub?.cancel();
          _illustrationSubs.remove(illustration.id);
        }
      },
    );

    _illustrationSubs.putIfAbsent(query.id, () => illustrationSub);
  }
}
