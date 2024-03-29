import 'dart:async';

import 'package:artbooking/actions/books.dart';
import 'package:artbooking/components/bottom_sheet/book_visibility_sheet.dart';
import 'package:artbooking/components/bottom_sheet/delete_content_bottom_sheet.dart';
import 'package:artbooking/components/custom_scroll_behavior.dart';
import 'package:artbooking/components/dialogs/add_to_books_dialog.dart';
import 'package:artbooking/components/dialogs/delete_dialog.dart';
import 'package:artbooking/components/dialogs/input_dialog.dart';
import 'package:artbooking/components/application_bar/application_bar.dart';
import 'package:artbooking/components/dialogs/share_dialog.dart';
import 'package:artbooking/components/dialogs/visibility_dialog.dart';
import 'package:artbooking/components/popup_menu/popup_menu_icon.dart';
import 'package:artbooking/components/popup_menu/popup_menu_item_icon.dart';
import 'package:artbooking/components/popup_progress_indicator.dart';
import 'package:artbooking/globals/app_state.dart';
import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/router/locations/atelier_location.dart';
import 'package:artbooking/router/locations/home_location.dart';
import 'package:artbooking/router/navigation_state_helper.dart';
import 'package:artbooking/screens/atelier/books/my_books_page_body.dart';
import 'package:artbooking/screens/atelier/books/my_books_page_fab.dart';
import 'package:artbooking/screens/atelier/books/my_books_page_header.dart';
import 'package:artbooking/types/book/book.dart';
import 'package:artbooking/types/book/popup_entry_book.dart';
import 'package:artbooking/types/cloud_functions/books_response.dart';
import 'package:artbooking/types/enums/enum_book_item_action.dart';
import 'package:artbooking/types/enums/enum_content_visibility.dart';
import 'package:artbooking/types/enums/enum_share_content_type.dart';
import 'package:artbooking/types/enums/enum_visibility_tab.dart';
import 'package:artbooking/types/firestore/document_snapshot_map.dart';
import 'package:artbooking/types/firestore/query_doc_snap_map.dart';
import 'package:artbooking/types/firestore/document_change_map.dart';
import 'package:artbooking/types/firestore/query_map.dart';
import 'package:artbooking/types/firestore/query_snap_map.dart';
import 'package:artbooking/types/firestore/query_snapshot_stream_subscription.dart';
import 'package:artbooking/types/cloud_functions/book_response.dart';
import 'package:artbooking/types/json_types.dart';
import 'package:beamer/beamer.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:desktop_drop/src/drop_target.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flash/src/flash_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_improved_scrolling/flutter_improved_scrolling.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:unicons/unicons.dart';

/// A page showing an user's books.
class MyBooksPage extends ConsumerStatefulWidget {
  MyBooksPage({this.userId = ""});

  /// User's books page, if provided.
  /// If [userId] is empty, the app will use the current authenticated user's id.
  final String userId;

  @override
  _MyBooksPageState createState() => _MyBooksPageState();
}

class _MyBooksPageState extends ConsumerState<MyBooksPage> {
  /// Listen to route to deaactivate file drop on this page
  /// (see `DropTarget.enable` property for more information).
  BeamerDelegate? _beamer;

  /// When true, avoid starting auto scroll periodic timer multiple times
  /// (fix auto-scroll issue when dropping files on window's edges).
  /// (PS: this variable is set to true on dragging file).
  bool _activateAutoScrollOnce = false;

  /// Creating a new book if true.
  bool _creating = false;

  /// (Mobile specific) If true, long pressing a card will start a drag.
  /// Otherwise, long pressing a card will display a context menu.
  bool _draggingActive = false;

  /// Disable file drop when navigating to a new page.
  bool _enableFileDrop = true;

  /// If true, multiple books can be select for group actions.
  bool _forceMultiSelect = false;

  /// If true, there are more books to fetch.
  bool _hasNext = true;

  /// True if the page scroller is currently moving up or down.
  /// Avoid starting auto scroll periodic timer multiple times.
  bool _isAutoScrolling = false;

  /// If true, a book is being dragged and we can auto-scroll on edges.
  bool _isDraggingBook = false;

  /// True if files are being dragged over this page.
  bool _isDraggingFile = false;

  /// True if files is being dragged over a book on this page.
  bool _isDraggingFileOverBook = false;

  /// Loading the current page if true.
  bool _loading = false;

  /// Loading the next page if true.
  bool _loadingMore = false;

  /// Show create floating action button if true.
  bool _showFabCreate = true;

  /// Show 'scroll to top' floating action button if true.
  bool _showFabToTop = false;

  /// If true, show a list of visibility items.
  bool _showVisibilityChooser = false;

  /// Last fetched book document.
  DocumentSnapshot? _lastDocument;

  /// Last saved Y offset.
  /// Used while scrolling to know the direction.
  double _previousOffset = 0.0;

  /// Page active tab.
  EnumVisibilityTab _selectedTab = EnumVisibilityTab.active;

  /// Book list.
  final List<Book> _books = [];

  /// Maximum books fetched in a page.
  int _limit = 20;

  /// Available items for authenticated user and the book is not liked yet.
  final List<PopupEntryBook> _likePopupMenuEntries = [
    PopupMenuItemIcon(
      delay: Duration(milliseconds: 0),
      value: EnumBookItemAction.like,
      icon: PopupMenuIcon(UniconsLine.heart),
      textLabel: "like".tr(),
    ),
    PopupMenuItemIcon(
      delay: Duration(milliseconds: 25),
      icon: PopupMenuIcon(UniconsLine.share),
      textLabel: "share".tr(),
      value: EnumBookItemAction.share,
    ),
  ];

  /// Items when the current authenticated user own these books.
  final List<PopupEntryBook> _ownerPopupMenuEntries = [
    PopupMenuItemIcon(
      delay: Duration(milliseconds: 0),
      icon: PopupMenuIcon(UniconsLine.share),
      textLabel: "share".tr(),
      value: EnumBookItemAction.share,
    ),
    PopupMenuItemIcon(
      delay: Duration(milliseconds: 25),
      icon: PopupMenuIcon(UniconsLine.edit_alt),
      textLabel: "rename".tr(),
      value: EnumBookItemAction.rename,
    ),
    PopupMenuItemIcon(
      delay: Duration(milliseconds: 50),
      icon: PopupMenuIcon(UniconsLine.trash),
      textLabel: "delete".tr(),
      value: EnumBookItemAction.delete,
    ),
    PopupMenuItemIcon(
      delay: Duration(milliseconds: 75),
      icon: PopupMenuIcon(UniconsLine.eye),
      textLabel: "visibility_change".tr(),
      value: EnumBookItemAction.updateVisibility,
    ),
    PopupMenuItemIcon(
      delay: Duration(milliseconds: 100),
      icon: PopupMenuIcon(UniconsLine.upload),
      textLabel: "illustration_upload".tr(),
      value: EnumBookItemAction.uploadIllustrations,
    ),
  ];

  /// Available items for authenticated user and the book is already liked.
  final List<PopupEntryBook> _unlikePopupMenuEntries = [
    PopupMenuItemIcon(
      delay: Duration(milliseconds: 0),
      value: EnumBookItemAction.unlike,
      icon: PopupMenuIcon(UniconsLine.heart_break),
      textLabel: "unlike".tr(),
    ),
    PopupMenuItemIcon(
      delay: Duration(milliseconds: 25),
      icon: PopupMenuIcon(UniconsLine.share),
      textLabel: "share".tr(),
      value: EnumBookItemAction.share,
    ),
  ];

  /// Group of selected books.
  final Map<String?, Book> _multiSelectedItems = Map();

  /// Subscribe to book collection updates.
  QuerySnapshotStreamSubscription? _bookSubscription;

  /// Page scroll controller.
  final ScrollController _pageScrollController = ScrollController();

  /// This books page owner's name.
  /// Used when the current authenticated user is different
  /// from the owner of this illustrations page. We can then dispay the artist.
  String _username = "";

  /// Monitors periodically scroll when dragging book card on edges.
  Timer? _scrollTimer;

  @override
  initState() {
    super.initState();
    loadPreferences();
    fetchData();

    // NOTE: Beamer state isn't ready on 1st frame.
    // So we use [addPostFrameCallback] to access the state in the next frame.
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      _beamer = Beamer.of(context);
      Beamer.of(context).addListener(onRouteUpdate);
    });
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
    _scrollTimer?.cancel();
    _beamer?.removeListener(onRouteUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String authUserId =
        ref.watch(AppState.userProvider).firestoreUser?.id ?? "";

    final bool isOwner = (widget.userId == authUserId) ||
        (widget.userId.isEmpty && authUserId.isNotEmpty);

    final List<PopupEntryBook> popupMenuEntries =
        isOwner ? _ownerPopupMenuEntries : [];

    final bool authenticated = authUserId.isNotEmpty;

    final bool showPageDropDecoration =
        _isDraggingFile && !_isDraggingFileOverBook;

    final bool isMobileSize = Utilities.size.isMobileSize(context);

    return Scaffold(
      floatingActionButton: MyBooksPageFab(
        pageScrollController: _pageScrollController,
        showFabCreate: _showFabCreate,
        showFabToTop: _showFabToTop,
        isOwner: isOwner,
        onShowCreateBookDialog: showCreateBookDialog,
      ),
      body: Listener(
        onPointerMove: onPointerMove,
        child: DropTarget(
          enable: _enableFileDrop && isOwner,
          onDragDone: onDragFileDone,
          onDragEntered: onDragFileEntered,
          onDragExited: onDragFileExited,
          onDragUpdated: onDragFileUpdated,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Constants.colors.tertiary,
                    width: 4.0,
                    style: showPageDropDecoration
                        ? BorderStyle.solid
                        : BorderStyle.none,
                  ),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: ImprovedScrolling(
                  scrollController: _pageScrollController,
                  enableKeyboardScrolling: true,
                  onScroll: onPageScroll,
                  child: ScrollConfiguration(
                    behavior: CustomScrollBehavior(),
                    child: CustomScrollView(
                      controller: _pageScrollController,
                      slivers: <Widget>[
                        ApplicationBar(
                          bottom: PreferredSize(
                            child: MyBooksPageHeader(
                              draggingActive: _draggingActive,
                              isMobileSize: isMobileSize,
                              isOwner: isOwner,
                              multiSelectActive: _forceMultiSelect,
                              multiSelectedItems: _multiSelectedItems,
                              onAddToBook: showAddGroupToBookDialog,
                              onChangedTab: onChangedTab,
                              onChangeGroupVisibility:
                                  showGroupVisibilityDialog,
                              onClearSelection: clearSelection,
                              onConfirmDeleteGroup: onConfirmDeleteGroup,
                              onGoToUserProfile: onGoToUserProfile,
                              onSelectAll: onSelectAll,
                              onShowCreateBookDialog: showCreateBookDialog,
                              onToggleDrag: onToggleDrag,
                              onTriggerMultiSelect: triggerMultiSelect,
                              selectedTab: _selectedTab,
                              username: _username,
                            ),
                            preferredSize: Size.fromHeight(160.0),
                          ),
                          minimal: true,
                          pinned: false,
                        ),
                        MyBooksPageBody(
                          authenticated: authenticated,
                          books: _books,
                          draggingActive: _draggingActive,
                          forceMultiSelect: _forceMultiSelect,
                          isMobileSize: isMobileSize,
                          isOwner: isOwner,
                          loading: _loading,
                          multiSelectedItems: _multiSelectedItems,
                          onDragBookCompleted: onDragBookCompleted,
                          onDragBookEnd: onDragBookEnd,
                          onDragBookStarted: onDragBookStarted,
                          onDragFileDone: onDragFileOnBookDone,
                          onDragFileEntered: onDragFileOnBookEntered,
                          onDragFileExited: onDragFileOnBookExited,
                          onDropBook: onDropBook,
                          onGoToActiveBooks: onGoToActiveBooks,
                          onLike: onLike,
                          onPopupMenuItemSelected: onPopupMenuItemSelected,
                          onShowCreateBookDialog: showCreateBookDialog,
                          onTapBook: onTapBook,
                          onTapBookCaption: onTapBookCaption,
                          popupMenuEntries: popupMenuEntries,
                          selectedTab: _selectedTab,
                          likePopupMenuEntries: _likePopupMenuEntries,
                          unlikePopupMenuEntries: _unlikePopupMenuEntries,
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.only(bottom: 100.0),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 100.0,
                right: 24.0,
                child: PopupProgressIndicator(
                  show: _creating,
                  message: "book_creating".tr() + "...",
                ),
              ),
              dropHint(),
            ],
          ),
        ),
      ),
    );
  }

  void autoScrollOnEdges({
    /// Current pointer y position.
    required double dy,

    /// Distance to the edge where the scroll viewer starts to jump.
    double scrollTreshold = 100.0,
  }) {
    final int duration = 50;

    /// Amount of offset to jump when dragging an element to the edge.
    final double jumpOffset = 42.0;

    if (dy < scrollTreshold && _pageScrollController.offset > 0) {
      if (_activateAutoScrollOnce && _isAutoScrolling) {
        return;
      }

      _scrollTimer?.cancel();
      _scrollTimer = Timer.periodic(
        Duration(milliseconds: duration),
        (Timer timer) {
          _pageScrollController.animateTo(
            _pageScrollController.offset - jumpOffset,
            duration: Duration(milliseconds: duration),
            curve: Curves.easeIn,
          );

          if (_pageScrollController.position.outOfRange) {
            _scrollTimer?.cancel();
            _isAutoScrolling = false;
          }
        },
      );

      _isAutoScrolling = true;
      return;
    }

    final double windowHeight = MediaQuery.of(context).size.height;
    final bool pointerIsAtBottom = dy >= windowHeight - scrollTreshold;
    final bool scrollIsAtBottomEdge = _pageScrollController.offset >=
        _pageScrollController.position.maxScrollExtent;

    if (pointerIsAtBottom && !scrollIsAtBottomEdge) {
      if (_activateAutoScrollOnce && _isAutoScrolling) {
        return;
      }

      _scrollTimer?.cancel();
      _scrollTimer = Timer.periodic(
        Duration(milliseconds: duration),
        (Timer timer) {
          _pageScrollController.animateTo(
            _pageScrollController.offset + jumpOffset,
            duration: Duration(milliseconds: duration),
            curve: Curves.easeIn,
          );

          if (_pageScrollController.position.outOfRange) {
            _scrollTimer?.cancel();
            _isAutoScrolling = false;
          }
        },
      );

      _isAutoScrolling = true;
      return;
    }

    _scrollTimer?.cancel();
    _isAutoScrolling = false;
  }

  Widget dropHint() {
    if (!_isDraggingFile || _isDraggingFileOverBook) {
      return Container();
    }

    return Positioned(
      bottom: 24.0,
      left: 0.0,
      right: 0.0,
      child: Align(
        alignment: Alignment.center,
        child: SizedBox(
          width: 500.0,
          child: Card(
            elevation: 6.0,
            color: Constants.colors.tertiary,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "illustration_upload_file_to_new_book".tr(),
                      style: Utilities.fonts.body(
                        color: Colors.black,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    UniconsLine.tear,
                    color: Colors.black,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Check if there's a book being deleted to eagerly remove it from UI.
  /// This method is called on route update (navgiation back from BookPage).
  void checkDeletingBookFromNavigation() {
    final Object? routeState =
        context.currentBeamLocation.state.routeInformation.state;

    if (routeState == null) {
      return;
    }

    final mapState = routeState as Map<String, dynamic>;
    final String deletingBookId = mapState["deletingBookId"] ?? "";

    if (deletingBookId.isEmpty) {
      return;
    }

    if (deletingBookId.isNotEmpty) {
      setState(() {
        _books.removeWhere((Book b) => b.id == deletingBookId);
      });
    }
  }

  void clearSelection() {
    setState(() {
      _multiSelectedItems.clear();
      _forceMultiSelect = _multiSelectedItems.length > 0;
    });
  }

  /// Show a dialog to confirm a single book deletion.
  void confirmDeleteBook(Book book, int index) async {
    final bool isMobileSize = Utilities.size.isMobileSize(context);

    Utilities.ui.showAdaptiveDialog(
      context,
      isMobileSize: isMobileSize,
      builder: (context) {
        final int count =
            _multiSelectedItems.isEmpty ? 1 : _multiSelectedItems.length;

        final void Function()? onConfirm = () {
          if (_multiSelectedItems.isEmpty) {
            tryDeleteBook(book, index);
          } else {
            _multiSelectedItems.putIfAbsent(book.id, () => book);
            tryDeleteGroup();
          }
        };

        final String confirmButtonValue = "book_delete_count".plural(
          count,
          args: [count.toString()],
        );

        if (isMobileSize) {
          return DeleteContentBottomSheet(
            confirmButtonValue: confirmButtonValue,
            count: count,
            onConfirm: onConfirm,
            subtitleValue: "book_delete_description".plural(count),
            titleValue: "book_delete".plural(count).toUpperCase(),
          );
        }

        return DeleteDialog(
          confirmButtonValue: confirmButtonValue,
          count: count,
          descriptionValue: "book_delete_description".plural(count),
          onValidate: onConfirm,
          showCounter: _multiSelectedItems.isNotEmpty,
          titleValue: "book_delete".plural(count).toUpperCase(),
        );
      },
    );
  }

  /// Create a new book and return the created book's id.
  Future<String> createBook(String name, String description) async {
    setState(() => _creating = true);

    final BookResponse response = await BooksActions.createOne(
      name: name,
      description: description,
    );

    setState(() => _creating = false);

    if (!response.success) {
      context.showErrorBar(
        content: Text("book_creation_error".tr()),
      );

      return "";
    }

    context.showSuccessBar(
      content: Text("book_creation_success".tr()),
    );

    return response.book.id;
  }

  void tryDeleteBook(Book book, int index) async {
    setState(() => _books.removeAt(index));

    final response = await BooksActions.deleteOne(
      bookId: book.id,
    );

    if (response.success) {
      return;
    }

    setState(() => _books.insert(index, book));

    context.showErrorBar(
      content: Text(response.error.details),
    );
  }

  void tryDeleteGroup() async {
    _multiSelectedItems.entries.forEach((multiSelectItem) {
      _books.removeWhere((item) => item.id == multiSelectItem.key);
    });

    final List<Book> copyItems = _multiSelectedItems.values.toList();
    final List<String?> booksIds = _multiSelectedItems.keys.toList();

    setState(() {
      _multiSelectedItems.clear();
      _forceMultiSelect = false;
    });

    final BooksResponse response = await BooksActions.deleteMany(
      bookIds: booksIds,
    );

    if (response.hasErrors) {
      context.showErrorBar(
        content: Text("illustrations_delete_error".tr()),
      );

      _books.addAll(copyItems);
    }
  }

  void fetchData() {
    Future.wait([
      fetchUser(),
      fetchBooks(),
    ]);
  }

  Future<void> fetchBooks() async {
    setState(() {
      _loading = true;
      _hasNext = true;
      _books.clear();
    });

    try {
      final QueryMap query = getFetchQuery();
      final QuerySnapMap snapshot = await query.get();

      listenBooksEvents(getListenQuery());

      if (snapshot.docs.isEmpty) {
        setState(() {
          _loading = false;
          _hasNext = false;
        });

        return;
      }

      for (final QueryDocSnapMap document in snapshot.docs) {
        final Json data = document.data();
        data["id"] = document.id;
        data["liked"] = await fetchLike(document.id);
        _books.add(Book.fromMap(data));
      }

      setState(() {
        _lastDocument = snapshot.docs.last;
        _hasNext = snapshot.docs.length == _limit;
      });
    } catch (error) {
      Utilities.logger.e(error);
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<bool> fetchLike(String bookId) async {
    final String? userId = ref.read(AppState.userProvider).firestoreUser?.id;
    if (userId == null || userId.isEmpty) {
      return false;
    }

    try {
      final DocumentSnapshotMap snapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("user_likes")
          .doc(bookId)
          .get();

      if (snapshot.exists) {
        return true;
      }

      return false;
    } catch (error) {
      Utilities.logger.e(error);
      return false;
    }
  }

  void fetchMoreBooks() async {
    if (!_hasNext || _lastDocument == null) {
      return;
    }

    _loadingMore = true;

    try {
      final QueryMap? query = getFetchMoreQuery();
      if (query == null) {
        return;
      }

      final QuerySnapMap snapshot = await query.get();
      if (snapshot.docs.isEmpty) {
        setState(() {
          _hasNext = false;
          _loadingMore = false;
        });

        return;
      }

      for (QueryDocSnapMap document in snapshot.docs) {
        final Json data = document.data();
        data["id"] = document.id;

        _books.add(Book.fromMap(data));
      }

      setState(() {
        _loadingMore = false;
        _lastDocument = snapshot.docs.last;
        _hasNext = snapshot.docs.length == _limit;
      });

      listenBooksEvents(getListenQuery());
    } catch (error) {
      Utilities.logger.e(error);
    } finally {
      setState(() => _loading = false);
    }
  }

  /// Fetch user's data. This illustrations page owner.
  /// (Launched if the the page is not owned by the current user)
  Future<void> fetchUser() async {
    if (widget.userId.isEmpty) {
      return;
    }

    if (getIsOwner()) {
      return;
    }

    try {
      final DocumentSnapshotMap snapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.userId)
          .collection("user_public_fields")
          .doc("base")
          .get();

      final Json? map = snapshot.data();
      if (!snapshot.exists || map == null) {
        return;
      }

      _username = map["name"];
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    }
  }

  QueryMap getFetchQuery() {
    final String userId = getUserId();

    if (!getIsOwner()) {
      return FirebaseFirestore.instance
          .collection("books")
          .where("user_id", isEqualTo: userId)
          .where("visibility", isEqualTo: "public")
          .orderBy("user_custom_index", descending: true)
          .limit(_limit);
    }

    if (_selectedTab == EnumVisibilityTab.active) {
      return FirebaseFirestore.instance
          .collection("books")
          .where("user_id", isEqualTo: userId)
          .where("visibility", whereIn: ["public", "private"])
          .orderBy("user_custom_index", descending: true)
          .limit(_limit);
    }

    return FirebaseFirestore.instance
        .collection("books")
        .where("user_id", isEqualTo: userId)
        .where("visibility", isEqualTo: "archived")
        .orderBy("user_custom_index", descending: true)
        .limit(_limit);
  }

  QueryMap? getFetchMoreQuery() {
    final lastDocument = _lastDocument;
    if (lastDocument == null) {
      return null;
    }

    final String userId = getUserId();

    if (!getIsOwner()) {
      return FirebaseFirestore.instance
          .collection("books")
          .where("user_id", isEqualTo: userId)
          .where("visibility", isEqualTo: "public")
          .orderBy("user_custom_index", descending: true)
          .limit(_limit)
          .startAfterDocument(lastDocument);
    }

    if (_selectedTab == EnumVisibilityTab.active) {
      return FirebaseFirestore.instance
          .collection("books")
          .where("user_id", isEqualTo: userId)
          .where("visibility", whereIn: ["public", "private"])
          .orderBy("user_custom_index", descending: true)
          .limit(_limit)
          .startAfterDocument(lastDocument);
    }

    return FirebaseFirestore.instance
        .collection("books")
        .where("user_id", isEqualTo: userId)
        .where("visibility", isEqualTo: "archived")
        .orderBy("user_custom_index", descending: true)
        .limit(_limit)
        .startAfterDocument(lastDocument);
  }

  /// Return the query without an initial document for pagination.
  /// This query can be used to listen to documents.
  QueryMap? getInitialListenQuery() {
    final String userId = getUserId();

    if (!getIsOwner()) {
      return FirebaseFirestore.instance
          .collection("books")
          .where("user_id", isEqualTo: userId)
          .where("visibility", isEqualTo: "public")
          .orderBy("user_custom_index", descending: true);
    }

    if (_selectedTab == EnumVisibilityTab.active) {
      return FirebaseFirestore.instance
          .collection("books")
          .where("user_id", isEqualTo: userId)
          .where("visibility", whereIn: ["public", "private"]).orderBy(
              "user_custom_index",
              descending: true);
    }

    return FirebaseFirestore.instance
        .collection("books")
        .where("user_id", isEqualTo: userId)
        .where("visibility", isEqualTo: "archived")
        .orderBy("user_custom_index", descending: true);
  }

  /// Return true if the current authenticated user is the owner
  /// of this illustrations page.
  bool getIsOwner() {
    final authUserId = ref.read(AppState.userProvider).firestoreUser?.id ?? "";

    if (widget.userId.isEmpty && authUserId.isNotEmpty) {
      return true;
    }

    return authUserId == widget.userId;
  }

  /// Return the query to listen changes to.
  QueryMap? getListenQuery() {
    final DocumentSnapshot? lastDocument = _lastDocument;

    if (lastDocument == null) {
      return getInitialListenQuery();
    }

    final String userId = getUserId();

    if (!getIsOwner()) {
      return FirebaseFirestore.instance
          .collection("books")
          .where("user_id", isEqualTo: userId)
          .where("visibility", isEqualTo: "public")
          .orderBy("user_custom_index", descending: true)
          .endAtDocument(lastDocument);
    }

    if (_selectedTab == EnumVisibilityTab.active) {
      return FirebaseFirestore.instance
          .collection("books")
          .where("user_id", isEqualTo: userId)
          .where("visibility", whereIn: ["public", "private"])
          .orderBy("user_custom_index", descending: true)
          .endAtDocument(lastDocument);
    }

    return FirebaseFirestore.instance
        .collection("books")
        .where("user_id", isEqualTo: userId)
        .where("visibility", isEqualTo: "archived")
        .orderBy("user_custom_index", descending: true)
        .endAtDocument(lastDocument);
  }

  /// Return either the user's id page parameter
  /// or the current authenticated user's id.
  String getUserId() {
    if (widget.userId.isNotEmpty) {
      return widget.userId;
    }

    return ref.read(AppState.userProvider).firestoreUser?.id ?? "";
  }

  String getUsername() {
    if (getIsOwner()) {
      return ref.read(AppState.userProvider).firestoreUser?.name ?? "";
    }

    return _username;
  }

  /// Listen to the last Firestore query of this page.
  void listenBooksEvents(QueryMap? query) {
    if (query == null) {
      return;
    }

    _bookSubscription?.cancel();
    _bookSubscription = query.snapshots().skip(1).listen(
      (snapshot) {
        for (DocumentChangeMap documentChange in snapshot.docChanges) {
          switch (documentChange.type) {
            case DocumentChangeType.added:
              onAddStreamingBook(documentChange);
              break;
            case DocumentChangeType.modified:
              onUpdateStreamingBook(documentChange);
              break;
            case DocumentChangeType.removed:
              onRemoveStreamingBook(documentChange);
              break;
          }
        }
      },
      onError: (error) {
        Utilities.logger.e(error);
      },
    );
  }

  void loadPreferences() {
    _draggingActive = Utilities.storage.getMobileDraggingActive();
    _selectedTab = Utilities.storage.getBooksTab();
  }

  void multiSelectBook(book) {
    final selected = _multiSelectedItems.containsKey(book.id);

    if (selected) {
      setState(() {
        _multiSelectedItems.remove(book.id);
        _forceMultiSelect = _multiSelectedItems.length > 0;
      });

      return;
    }

    setState(() {
      _multiSelectedItems.putIfAbsent(book.id, () => book);
    });
  }

  void navigateToBookPage(Book book) {
    NavigationStateHelper.book = book;

    String route = HomeLocation.userBookRoute
        .replaceFirst(":userId", getUserId())
        .replaceFirst(":bookId", book.id);

    final String? location = Beamer.of(context)
        .beamingHistory
        .last
        .history
        .last
        .routeInformation
        .location;

    if (location != null && location.contains("atelier")) {
      route = AtelierLocationContent.bookRoute.replaceFirst(
        ":bookId",
        book.id,
      );
    }

    Beamer.of(context).beamToNamed(
      route,
      data: {
        "bookId": book.id,
      },
    );
  }

  /// Fire when a new book is created in collection.
  /// Add the corresponding document in the UI.
  void onAddStreamingBook(DocumentChangeMap documentChange) {
    final data = documentChange.doc.data();

    if (data == null) {
      return;
    }

    setState(() {
      data['id'] = documentChange.doc.id;
      final book = Book.fromMap(data);
      _books.insert(0, book);
    });
  }

  void onChangedTab(EnumVisibilityTab selectedTab) {
    setState(() {
      _selectedTab = selectedTab;
    });

    fetchBooks();
    Utilities.storage.saveBooksTab(selectedTab);
  }

  void onChangedVisibility(
    BuildContext context, {
    required Book book,
    required int index,
    required EnumContentVisibility visibility,
  }) {
    Future<EnumContentVisibility?>? futureResult;

    if (_multiSelectedItems.isEmpty) {
      futureResult = tryUpdateVisibility(book, visibility, index);
    } else {
      _multiSelectedItems.putIfAbsent(book.id, () => book);
      tryUpdateGroupVisibility(visibility);
    }

    clearSelection();
    Navigator.pop(context, futureResult);
  }

  /// Show a dialog to confirm multiple books deletion.
  void onConfirmDeleteGroup() async {
    if (_multiSelectedItems.isEmpty) {
      context.showErrorBar(content: Text("multi_select_no_item".tr()));
      return;
    }

    final Book book = _multiSelectedItems.values.first;
    final int index = _books.indexWhere((x) => x.id == book.id);
    confirmDeleteBook(book, index);
  }

  void onDragBookCompleted() {
    _isDraggingBook = false;
  }

  void onDragBookEnd(DraggableDetails p1) {
    _isDraggingBook = false;
  }

  void onDragBookStarted() {
    _isDraggingBook = true;
  }

  void onDraggableBookCanceled(Velocity velocity, Offset offset) {
    _isDraggingBook = false;
  }

  /// Callback event fired when files are dropped on this page.
  /// Ask to create a book and, upload the illustration,
  /// and then add this illuqtration to the created book.
  void onDragFileDone(DropDoneDetails dropDoneDetails) async {
    if (_isDraggingFileOverBook) {
      return;
    }

    final List<PlatformFile> files = [];

    for (final file in dropDoneDetails.files) {
      final int length = await file.length();

      if (length > Constants.maxFileSize) {
        context.showErrorBar(
          content: Text(
            "illustration_upload_size_limit".tr(
              args: [file.name, length.toString(), "25"],
            ),
          ),
        );
        continue;
      }

      final int dotIndex = file.path.lastIndexOf(".");
      final String extension = file.path.substring(dotIndex + 1);

      if (!Constants.allowedImageExt.contains(extension)) {
        context.showErrorBar(
          content: Text(
            "illustration_upload_invalid_extension".tr(
              args: [file.name, Constants.allowedImageExt.join(", ")],
            ),
          ),
        );
        continue;
      }

      final PlatformFile platformFile = PlatformFile(
        name: file.name,
        size: await file.length(),
        path: file.path,
        bytes: await file.readAsBytes(),
        readStream: file.openRead(),
      );

      files.add(platformFile);
    }

    showCreateBookDialog(files: files);
  }

  /// Callback event fired when a pointer enters this page with files.
  void onDragFileEntered(DropEventDetails dropEventDetails) {
    setState(() => _isDraggingFile = true);
  }

  /// Callback event fired when a pointer exits this page with files.
  void onDragFileExited(DropEventDetails dropEventDetails) {
    setState(() => _isDraggingFile = false);
  }

  /// Callback fired when one or severals files are dropped on a book.
  /// An illustration will be created for each image file,
  /// and then will be added to the target book.
  void onDragFileOnBookDone(Book book, DropDoneDetails dropDoneDetails) async {
    final List<PlatformFile> files = [];

    for (final file in dropDoneDetails.files) {
      final int length = await file.length();

      if (length > Constants.maxFileSize) {
        context.showErrorBar(
          content: Text(
            "illustration_upload_size_limit".tr(
              args: [file.name, length.toString(), "25"],
            ),
          ),
        );
        continue;
      }

      final int dotIndex = file.path.lastIndexOf(".");
      final String extension = file.path.substring(dotIndex + 1);

      if (!Constants.allowedImageExt.contains(extension)) {
        context.showErrorBar(
          content: Text(
            "illustration_upload_invalid_extension".tr(
              args: [file.name, Constants.allowedImageExt.join(", ")],
            ),
          ),
        );
        continue;
      }

      final PlatformFile platformFile = PlatformFile(
        name: file.name,
        size: await file.length(),
        path: file.path,
        bytes: await file.readAsBytes(),
        readStream: file.openRead(),
      );

      files.add(platformFile);
    }

    ref
        .read(AppState.uploadTaskListProvider.notifier)
        .handleDropFilesToBook(files: files, bookId: book.id);
  }

  void onDragFileOnBookEntered(DropEventDetails details) {
    Future.delayed(Duration(milliseconds: 12), () {
      setState(() {
        _isDraggingFileOverBook = true;
      });
    });
  }

  void onDragFileOnBookExited(DropEventDetails details) {
    setState(() => _isDraggingFileOverBook = false);
  }

  /// Called when dragging files over the window.
  void onDragFileUpdated(DropEventDetails details) {
    _activateAutoScrollOnce = true;
    autoScrollOnEdges(
      dy: details.globalPosition.dy,
    );
  }

  void onDropBook(int dropIndex, List<int> dragIndexes) async {
    final int firstDragIndex = dragIndexes.first;
    if (dropIndex == firstDragIndex) {
      return;
    }

    if (dropIndex < 0 ||
        firstDragIndex < 0 ||
        dropIndex >= _books.length ||
        firstDragIndex > _books.length) {
      return;
    }

    final Book dropBook = _books.elementAt(dropIndex);
    final Book dragBook = _books.elementAt(firstDragIndex);

    final int dropUserCustomIndex = dropBook.userCustomIndex;
    final int dragUserCustomIndex = dragBook.userCustomIndex;

    final Book newDropBook = dropBook.copyWith(
      userCustomIndex: dragUserCustomIndex,
    );

    final Book newDragBook = dragBook.copyWith(
      userCustomIndex: dropUserCustomIndex,
    );

    setState(() {
      _books[firstDragIndex] = newDropBook;
      _books[dropIndex] = newDragBook;
    });

    try {
      await FirebaseFirestore.instance
          .collection("books")
          .doc(newDragBook.id)
          .update({
        "user_custom_index": newDragBook.userCustomIndex,
      });

      await FirebaseFirestore.instance
          .collection("books")
          .doc(newDropBook.id)
          .update({
        "user_custom_index": newDropBook.userCustomIndex,
      });
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    }
  }

  void onGoToActiveBooks() {
    onChangedTab(EnumVisibilityTab.active);
  }

  void onGoToUserProfile() {
    Beamer.of(context).beamToNamed(
      HomeLocation.profileRoute.replaceFirst(":userId", widget.userId),
      routeState: {
        "userId": widget.userId,
      },
    );
  }

  /// Toggle a book existence in user's favourites.
  void onLike(Book book) {
    if (book.liked) {
      return tryUnLike(book);
    }

    return tryLike(book);
  }

  void onLongPressBook(Book book, bool selected) {
    if (selected) {
      setState(() {
        _multiSelectedItems.remove(book.id);
      });

      return;
    }

    setState(() {
      _multiSelectedItems.putIfAbsent(book.id, () => book);
    });
  }

  /// Callback fired when a pointer is down and moves.
  void onPointerMove(PointerMoveEvent pointerMoveEvent) {
    if (!_isDraggingBook) {
      _scrollTimer?.cancel();
      return;
    }

    autoScrollOnEdges(
      dy: pointerMoveEvent.position.dy,
    );
  }

  void onPopupMenuItemSelected(
    EnumBookItemAction action,
    int index,
    Book book,
  ) {
    switch (action) {
      case EnumBookItemAction.rename:
        showRenameBookDialog(book);
        break;
      case EnumBookItemAction.delete:
        confirmDeleteBook(book, index);
        break;
      case EnumBookItemAction.updateVisibility:
        showVisibilityDialogOrBottomSheet(book, index);
        break;
      case EnumBookItemAction.uploadIllustrations:
        ref
            .read(AppState.uploadTaskListProvider.notifier)
            .pickImageAndAddToBook(bookId: book.id);
        break;
      case EnumBookItemAction.share:
        showShareDialog(book, index);
        break;
      default:
    }
  }

  /// When a book has been delete from Firestore.
  /// Delete the corresponding document from the UI.
  void onRemoveStreamingBook(DocumentChangeMap documentChange) {
    setState(() {
      _books.removeWhere((book) => book.id == documentChange.doc.id);
    });
  }

  /// Callback fired when route changes.
  void onRouteUpdate() {
    final String? stringLocation = Beamer.of(context)
        .beamingHistory
        .last
        .history
        .last
        .routeInformation
        .location;

    _enableFileDrop = stringLocation == AtelierLocationContent.booksRoute;

    checkDeletingBookFromNavigation();
  }

  /// Callback when the page scrolls up and down.
  void onPageScroll(double offset) {
    // if (offset < 50 && _showFabCreate) {
    //   setState(() => _showFabCreate = false);
    //   return;
    // }

    // if (offset > 50 && !_showFabCreate) {
    //   setState(() => _showFabCreate = true);
    // }

    // if (_pageScrollController.position.atEdge &&
    //     offset > 50 &&
    //     _hasNext &&
    //     !_loadingMore) {
    //   fetchMoreBooks();
    // }
    maybeShowFab(offset);
    maybeFetchMore(offset);
  }

  void maybeFetchMore(double offset) {
    if (_pageScrollController.position.atEdge &&
        offset > 50 &&
        _hasNext &&
        !_loadingMore) {
      fetchMoreBooks();
    }
  }

  void maybeShowFab(double offset) {
    final bool scrollingDown = offset - _previousOffset > 0;
    _previousOffset = offset;

    _showFabToTop = offset == 0.0 ? false : true;

    if (scrollingDown) {
      if (!_showFabCreate) {
        return;
      }

      setState(() => _showFabCreate = false);
      return;
    }

    if (offset == 0.0) {
      setState(() => _showFabToTop = false);
    }

    if (_showFabCreate) {
      return;
    }

    setState(() => _showFabCreate = true);
  }

  void onSelectAll() {
    _books.forEach((illustration) {
      _multiSelectedItems.putIfAbsent(
        illustration.id,
        () => illustration,
      );
    });

    setState(() {});
  }

  /// When a book card receives onTap event.
  void onTapBook(Book book) {
    if (_multiSelectedItems.isEmpty && !_forceMultiSelect) {
      navigateToBookPage(book);
      return;
    }

    multiSelectBook(book);
  }

  void onTapBookCaption(Book book) {
    showRenameBookDialog(book);
  }

  /// Callback when a tile about content visibility is tapped.
  void onTapVisibilityTile(
    Book book,
    EnumContentVisibility visibility,
    int index,
  ) {
    onChangedVisibility(
      context,
      book: book,
      index: index,
      visibility: visibility,
    );
  }

  void onToggleDrag() {
    setState(() => _draggingActive = !_draggingActive);
    Utilities.storage.saveMobileDraggingActive(_draggingActive);
  }

  /// Callback fired to show or hide visibility choices.
  void onToggleVisibilityChoice(void Function(void Function()) childSetState) {
    childSetState(() => _showVisibilityChooser = !_showVisibilityChooser);
  }

  /// Fire when a new document has been updated in Firestore.
  /// Update the corresponding document in the UI.
  void onUpdateStreamingBook(DocumentChangeMap documentChange) {
    try {
      final data = documentChange.doc.data();
      if (data == null) {
        return;
      }

      final int index = _books.indexWhere(
        (book) => book.id == documentChange.doc.id,
      );

      data['id'] = documentChange.doc.id;
      final updatedBook = Book.fromMap(data);

      setState(() {
        _books.removeAt(index);
        _books.insert(index, updatedBook);
      });
    } on Exception catch (error) {
      Utilities.logger.e(
        "The document with the id ${documentChange.doc.id} "
        "doesn't exist in the books list.",
      );

      Utilities.logger.e(error);
    }
  }

  /// Rename one book.
  void renameBook(Book book, String name, String description) async {
    try {
      final int bookIndex = _books.indexWhere((x) => x.id == book.id);

      setState(() {
        final Book renamedBook = book.copyWith(
          name: name,
          description: description,
        );

        if (bookIndex < 0) {
          return;
        }

        _books.replaceRange(bookIndex, bookIndex + 1, [renamedBook]);
      });

      final BookResponse response = await BooksActions.renameOne(
        name: name,
        description: description,
        bookId: book.id,
      );

      if (response.success) {
        return;
      }

      setState(() {
        _books.replaceRange(bookIndex, bookIndex + 1, [book]);
      });

      context.showErrorBar(
        content: Text(response.error.details),
      );
    } catch (error) {
      Utilities.logger.e(error);
    }
  }

  void showAddGroupToBookDialog() {
    if (_multiSelectedItems.isEmpty) {
      context.showErrorBar(content: Text("multi_select_no_item".tr()));
      return;
    }

    showAddToBookDialog(_multiSelectedItems.values.first);
  }

  void showAddToBookDialog(Book book) {
    showDialog(
      context: context,
      builder: (context) {
        return AddToBooksDialog(
          illustrations: [],
          books: [book] + _multiSelectedItems.values.toList(),
          onComplete: clearSelection,
        );
      },
    );
  }

  void showGroupVisibilityDialog() {
    if (_multiSelectedItems.isEmpty) {
      context.showErrorBar(content: Text("multi_select_no_item".tr()));
      return;
    }

    final Book book = _multiSelectedItems.values.first;
    final int index = _books.indexWhere((x) => x.id == book.id);
    showVisibilityDialog(book, index);
  }

  void showCreateBookDialog({List<PlatformFile> files = const []}) {
    final _nameController = TextEditingController();
    final _descriptionController = TextEditingController();

    final bool isMobileSize = Utilities.size.isMobileSize(context);

    Utilities.ui.showAdaptiveDialog(
      context,
      isMobileSize: isMobileSize,
      builder: (context) => InputDialog(
        asBottomSheet: isMobileSize,
        titleValue: "book_create".tr().toUpperCase(),
        subtitleValue: "book_create_description".tr(),
        nameController: _nameController,
        descriptionController: _descriptionController,
        onCancel: Beamer.of(context).popRoute,
        onSubmitted: (_) async {
          Beamer.of(context).popRoute();
          final String createdBookId = await createBook(
            _nameController.text,
            _descriptionController.text,
          );

          if (createdBookId.isEmpty || files.isEmpty) {
            return;
          }

          ref
              .read(AppState.uploadTaskListProvider.notifier)
              .handleDropFilesToBook(
                files: files,
                bookId: createdBookId,
              );
        },
      ),
    );
  }

  void showRenameBookDialog(Book book) {
    final _nameController = TextEditingController();
    final _descriptionController = TextEditingController();

    _nameController.text = book.name;
    _descriptionController.text = book.description;

    final bool isMobileSize = Utilities.size.isMobileSize(context);

    Utilities.ui.showAdaptiveDialog(
      context,
      isMobileSize: isMobileSize,
      builder: (context) => InputDialog(
        asBottomSheet: isMobileSize,
        submitButtonValue: "rename".tr(),
        nameController: _nameController,
        descriptionController: _descriptionController,
        titleValue: "book_rename".tr().toUpperCase(),
        subtitleValue: "book_rename_description".tr(),
        onCancel: Beamer.of(context).popRoute,
        onSubmitted: (value) {
          renameBook(
            book,
            _nameController.text,
            _descriptionController.text,
          );
          Beamer.of(context).popRoute();
        },
      ),
    );
  }

  void showShareDialog(Book book, int index) {
    final bool isMobileSize = Utilities.size.isMobileSize(context);

    Utilities.ui.showAdaptiveDialog(
      context,
      isMobileSize: isMobileSize,
      builder: (BuildContext context) => ShareDialog(
        asBottomSheet: isMobileSize,
        extension: "",
        itemId: book.id,
        imageProvider: NetworkImage(book.getCoverLink()),
        name: book.name,
        imageUrl: book.getCoverLink(),
        shareContentType: EnumShareContentType.book,
        username: getUsername(),
        visibility: book.visibility,
        onShowVisibilityDialog: () => showVisibilityDialog(book, index),
      ),
    );
  }

  Future<EnumContentVisibility?>? showVisibilityBottomSheet(
    Book book,
    int index,
  ) async {
    return await showCupertinoModalBottomSheet<Future<EnumContentVisibility?>?>(
      context: context,
      expand: false,
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (
          BuildContext context,
          void Function(void Function()) childSetState,
        ) {
          return BookVisibilitySheet(
            multiSelectedItemLength: _multiSelectedItems.length,
            onTapVisibilityTile: (EnumContentVisibility visibility) {
              onTapVisibilityTile(
                book,
                visibility,
                index,
              );
            },
            onToggleVisibilityChoice: () => onToggleVisibilityChoice(
              childSetState,
            ),
            showVisibilityChooser: _showVisibilityChooser,
            visibilityString:
                "visibility_${book.visibility.name}".tr().toUpperCase(),
          );
        });
      },
    );
  }

  Future<EnumContentVisibility?>? showVisibilityDialogOrBottomSheet(
    Book book,
    int index,
  ) {
    final bool isMobileSize = Utilities.size.isMobileSize(context);

    if (isMobileSize) {
      return showVisibilityBottomSheet(book, index);
    }

    return showVisibilityDialog(book, index);
  }

  Future<EnumContentVisibility?>? showVisibilityDialog(
    Book book,
    int index,
  ) async {
    return await showDialog<Future<EnumContentVisibility?>?>(
      context: context,
      builder: (BuildContext context) => VisibilityDialog(
        textBodyValue: "book_visibility_choose".plural(
          _multiSelectedItems.length,
        ),
        titleValue: "book_visibility_change".plural(
          _multiSelectedItems.length,
        ),
        visibility: book.visibility,
        onChangedVisibility: (
          BuildContext context,
          EnumContentVisibility visibility,
        ) {
          onChangedVisibility(
            context,
            visibility: visibility,
            book: book,
            index: index,
          );
        },
      ),
    );
  }

  void triggerMultiSelect() {
    setState(() {
      _forceMultiSelect = !_forceMultiSelect;
    });
  }

  /// Add a book to a user's favourites.
  void tryLike(Book book) async {
    try {
      final String? userId = ref.read(AppState.userProvider).firestoreUser?.id;

      await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("user_likes")
          .doc(book.id)
          .set({
        "type": "book",
        "target_id": book.id,
        "user_id": userId,
      });
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    }
  }

  /// Remove a book to a user's favourites.
  void tryUnLike(Book book) async {
    try {
      final String? userId = ref.read(AppState.userProvider).firestoreUser?.id;

      await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("user_likes")
          .doc(book.id)
          .delete();
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    }
  }

  void tryUpdateGroupVisibility(EnumContentVisibility visibility) {
    for (Book book in _multiSelectedItems.values) {
      final int index = _books.indexWhere(
        (x) => x.id == book.id,
      );

      tryUpdateVisibility(book, visibility, index);
    }
  }

  Future<EnumContentVisibility?> tryUpdateVisibility(
    Book book,
    EnumContentVisibility visibility,
    int index,
  ) async {
    bool removedBook = false;

    if (_selectedTab == EnumVisibilityTab.active &&
        visibility == EnumContentVisibility.archived) {
      _books.removeAt(index);
      removedBook = true;
    }

    if (_selectedTab == EnumVisibilityTab.archived &&
        visibility != EnumContentVisibility.archived) {
      _books.removeAt(index);
      removedBook = true;
    }

    setState(() {});

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

      if (removedBook) {
        setState(() {
          _books.insert(index, book);
        });
      }

      return null;
    }
  }
}
