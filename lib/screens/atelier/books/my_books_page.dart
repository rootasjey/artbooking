import 'dart:async';

import 'package:artbooking/actions/books.dart';
import 'package:artbooking/components/custom_scroll_behavior.dart';
import 'package:artbooking/components/dialogs/add_to_books_dialog.dart';
import 'package:artbooking/components/buttons/visibility_button.dart';
import 'package:artbooking/components/dialogs/delete_dialog.dart';
import 'package:artbooking/components/dialogs/input_dialog.dart';
import 'package:artbooking/components/application_bar/application_bar.dart';
import 'package:artbooking/components/popup_menu/popup_menu_icon.dart';
import 'package:artbooking/components/popup_menu/popup_menu_item_icon.dart';
import 'package:artbooking/components/dialogs/themed_dialog.dart';
import 'package:artbooking/components/popup_progress_indicator.dart';
import 'package:artbooking/globals/app_state.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/router/locations/atelier_location.dart';
import 'package:artbooking/router/navigation_state_helper.dart';
import 'package:artbooking/screens/atelier/books/my_books_page_body.dart';
import 'package:artbooking/screens/atelier/books/my_books_page_fab.dart';
import 'package:artbooking/screens/atelier/books/my_books_page_header.dart';
import 'package:artbooking/types/book/book.dart';
import 'package:artbooking/types/enums/enum_book_item_action.dart';
import 'package:artbooking/types/enums/enum_content_visibility.dart';
import 'package:artbooking/types/enums/enum_visibility_tab.dart';
import 'package:artbooking/types/firestore/query_doc_snap_map.dart';
import 'package:artbooking/types/firestore/document_change_map.dart';
import 'package:artbooking/types/firestore/query_map.dart';
import 'package:artbooking/types/firestore/query_snapshot_stream_subscription.dart';
import 'package:artbooking/types/cloud_functions/book_response.dart';
import 'package:beamer/beamer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flash/src/flash_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_improved_scrolling/flutter_improved_scrolling.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicons/unicons.dart';

class MyBooksPage extends ConsumerStatefulWidget {
  @override
  _MyBooksPageState createState() => _MyBooksPageState();
}

class _MyBooksPageState extends ConsumerState<MyBooksPage> {
  bool _creating = false;
  bool _forceMultiSelect = false;
  bool _hasNext = true;
  bool _isDraggingSection = false;
  bool _loading = false;
  bool _loadingMore = false;
  bool _showFab = false;

  /// Last fetched book document.
  DocumentSnapshot? _lastDocument;

  final _books = <Book>[];
  final _focusNode = FocusNode();

  final _popupMenuEntries = <PopupMenuEntry<EnumBookItemAction>>[
    PopupMenuItemIcon(
      icon: PopupMenuIcon(UniconsLine.edit_alt),
      textLabel: "rename".tr(),
      value: EnumBookItemAction.rename,
    ),
    PopupMenuItemIcon(
      icon: PopupMenuIcon(UniconsLine.trash),
      textLabel: "delete".tr(),
      value: EnumBookItemAction.delete,
    ),
    PopupMenuItemIcon(
      icon: PopupMenuIcon(UniconsLine.eye),
      textLabel: "visibility_change".tr(),
      value: EnumBookItemAction.updateVisibility,
    ),
  ];

  int _limit = 20;

  Map<String?, Book> _multiSelectedItems = Map();

  ScrollController _scrollController = ScrollController();

  QuerySnapshotStreamSubscription? _bookSubscription;

  EnumVisibilityTab _selectedTab = EnumVisibilityTab.active;

  /// Monitors periodically scroll when dragging book card on edges.
  Timer? _scrollTimer;

  @override
  initState() {
    super.initState();
    loadPreferences();
    fetchBooks();
  }

  @override
  void dispose() {
    _bookSubscription?.cancel();
    _focusNode.dispose();
    _scrollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: MyBooksPageFab(
        scrollController: _scrollController,
        show: _showFab,
        onShowCreateBookDialog: showCreateBookDialog,
      ),
      body: Listener(
        onPointerMove: onPointerMove,
        child: Stack(
          children: [
            ImprovedScrolling(
              scrollController: _scrollController,
              enableKeyboardScrolling: true,
              onScroll: onScroll,
              child: ScrollConfiguration(
                behavior: CustomScrollBehavior(),
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: <Widget>[
                    ApplicationBar(),
                    MyBooksPageHeader(
                      selectedTab: _selectedTab,
                      onChangedTab: onChangedTab,
                      multiSelectActive: _forceMultiSelect,
                      multiSelectedItems: _multiSelectedItems,
                      onSelectAll: onSelectAll,
                      onClearSelection: clearSelection,
                      onTriggerMultiSelect: triggerMultiSelect,
                      onShowCreateBookDialog: showCreateBookDialog,
                      onAddToBook: showAddGroupToBookDialog,
                      onChangeGroupVisibility: showGroupVisibilityDialog,
                      onConfirmDeleteGroup: onConfirmDeleteGroup,
                    ),
                    MyBooksPageBody(
                      books: _books,
                      loading: _loading,
                      onDropBook: onDropBook,
                      onShowCreateBookDialog: showCreateBookDialog,
                      popupMenuEntries: _popupMenuEntries,
                      onLongPressBook: onLongPressBook,
                      forceMultiSelect: _forceMultiSelect,
                      multiSelectedItems: _multiSelectedItems,
                      onPopupMenuItemSelected: onPopupMenuItemSelected,
                      onTapBook: onTapBook,
                      onGoToActiveBooks: onGoToActiveBooks,
                      selectedTab: _selectedTab,
                      onDragBookCompleted: onDragBookCompleted,
                      onDragBookEnd: onDragBookEnd,
                      onDragBookStarted: onDragBookStarted,
                      onLike: onLike,
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
                show: _creating,
                message: "book_creating".tr() + "...",
              ),
            ),
          ],
        ),
      ),
    );
  }

  void clearSelection() {
    setState(() {
      _multiSelectedItems.clear();
      _forceMultiSelect = _multiSelectedItems.length > 0;
    });
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

  /// Show a dialog to confirm a single book deletion.
  void confirmDeleteBook(Book book, int index) async {
    showDialog(
      context: context,
      builder: (context) {
        final int count = _multiSelectedItems.length;
        return DeleteDialog(
          titleValue: "book_delete".plural(count).toUpperCase(),
          descriptionValue: "book_delete_description".plural(count),
          onValidate: () {
            if (_multiSelectedItems.isEmpty) {
              deleteBook(book, index);
            } else {
              _multiSelectedItems.putIfAbsent(book.id, () => book);
              deleteGroup();
            }
          },
          showCounter: _multiSelectedItems.isNotEmpty,
          count: count,
        );
      },
    );
  }

  void createBook(String name, String description) async {
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

      return;
    }

    context.showSuccessBar(
      content: Text("book_creation_success".tr()),
    );
  }

  void deleteBook(Book book, int index) async {
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

  void deleteGroup() async {
    _multiSelectedItems.entries.forEach((multiSelectItem) {
      _books.removeWhere((item) => item.id == multiSelectItem.key);
    });

    final copyItems = _multiSelectedItems.values.toList();
    final booksIds = _multiSelectedItems.keys.toList();

    setState(() {
      _multiSelectedItems.clear();
      _forceMultiSelect = false;
    });

    final response = await BooksActions.deleteMany(
      bookIds: booksIds,
    );

    if (response.hasErrors) {
      context.showErrorBar(
        content: Text("illustrations_delete_error".tr()),
      );

      _books.addAll(copyItems);
    }
  }

  QueryMap getFetchQuery() {
    final String? userId = ref.read(AppState.userProvider).firestoreUser?.id;

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

    final String? userId = ref.read(AppState.userProvider).firestoreUser?.id;

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

  void fetchBooks() async {
    setState(() {
      _loading = true;
      _hasNext = true;
      _books.clear();
    });

    try {
      final query = getFetchQuery();

      listenBooksEvents(query);
      final snapshot = await query.get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          _loading = false;
          _hasNext = false;
        });

        return;
      }

      for (QueryDocSnapMap document in snapshot.docs) {
        final data = document.data();
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
      final snapshot = await FirebaseFirestore.instance
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

      final snapshot = await query.get();
      if (snapshot.docs.isEmpty) {
        setState(() {
          _hasNext = false;
          _loadingMore = false;
        });

        return;
      }

      for (QueryDocSnapMap document in snapshot.docs) {
        final data = document.data();
        data['id'] = document.id;

        _books.add(Book.fromMap(data));
      }

      setState(() {
        _loadingMore = false;
        _lastDocument = snapshot.docs.last;
        _hasNext = snapshot.docs.length == _limit;
      });
    } catch (error) {
      Utilities.logger.e(error);
    } finally {
      setState(() => _loading = false);
    }
  }

  /// Listen to the last Firestore query of this page.
  void listenBooksEvents(QueryMap query) {
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

  void onDragBookCompleted() {
    _isDraggingSection = false;
  }

  void onDragBookEnd(DraggableDetails p1) {
    _isDraggingSection = false;
  }

  void onDragBookStarted() {
    _isDraggingSection = true;
  }

  void onDraggableBookCanceled(Velocity velocity, Offset offset) {
    _isDraggingSection = false;
  }

  void onDropBook(int dropIndex, List<int> dragIndexes) async {
    final firstDragIndex = dragIndexes.first;
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
    if (!_isDraggingSection) {
      _scrollTimer?.cancel();
      return;
    }

    final int duration = 50;

    /// Amount of offset to jump when dragging an element to the edge.
    final double jumpOffset = 42.0;
    final double dy = pointerMoveEvent.position.dy;

    /// Distance to the edge where the scroll viewer starts to jump.
    final double scrollTreshold = 100.0;

    if (dy < scrollTreshold && _scrollController.offset > 0) {
      _scrollTimer?.cancel();
      _scrollTimer = Timer.periodic(
        Duration(milliseconds: duration),
        (Timer timer) {
          _scrollController.animateTo(
            _scrollController.offset - jumpOffset,
            duration: Duration(milliseconds: duration),
            curve: Curves.easeIn,
          );

          if (_scrollController.position.outOfRange) {
            _scrollTimer?.cancel();
          }
        },
      );

      return;
    }

    final double windowHeight = MediaQuery.of(context).size.height;
    final bool pointerIsAtBottom = dy >= windowHeight - scrollTreshold;
    final bool scrollIsAtBottomEdge =
        _scrollController.offset >= _scrollController.position.maxScrollExtent;

    if (pointerIsAtBottom && !scrollIsAtBottomEdge) {
      _scrollTimer?.cancel();
      _scrollTimer = Timer.periodic(
        Duration(milliseconds: duration),
        (Timer timer) {
          _scrollController.animateTo(
            _scrollController.offset + jumpOffset,
            duration: Duration(milliseconds: duration),
            curve: Curves.easeIn,
          );

          if (_scrollController.position.outOfRange) {
            _scrollTimer?.cancel();
          }
        },
      );
      return;
    }

    _scrollTimer?.cancel();
  }

  void onNavigateToBook(Book book) {
    NavigationStateHelper.book = book;
    Beamer.of(context).beamToNamed(
      AtelierLocationContent.bookRoute.replaceFirst(":bookId", book.id),
      data: {
        "bookId": book.id,
      },
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
        showVisibilityDialog(book, index);
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

  /// Callback when the page scrolls up and down.
  void onScroll(double scrollOffset) {
    if (scrollOffset < 50 && _showFab) {
      setState(() => _showFab = false);
      return;
    }

    if (scrollOffset > 50 && !_showFab) {
      setState(() => _showFab = true);
    }

    if (_scrollController.position.atEdge &&
        scrollOffset > 50 &&
        _hasNext &&
        !_loadingMore) {
      fetchMoreBooks();
    }
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
      onNavigateToBook(book);
      return;
    }

    multiSelectBook(book);
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
      final prevName = book.name;
      final prevDescription = book.description;

      setState(() {
        book = book.copyWith(
          name: name,
          description: description,
        );
      });

      final response = await BooksActions.renameOne(
        name: name,
        description: description,
        bookId: book.id,
      );

      if (response.success) {
        return;
      }

      setState(() {
        book = book.copyWith(
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

  void showCreateBookDialog() {
    final _nameController = TextEditingController();
    final _descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => InputDialog(
        titleValue: "book_create".tr().toUpperCase(),
        subtitleValue: "book_create_description".tr(),
        nameController: _nameController,
        descriptionController: _descriptionController,
        onCancel: Beamer.of(context).popRoute,
        onSubmitted: (value) {
          createBook(
            _nameController.text,
            _descriptionController.text,
          );
          Beamer.of(context).popRoute();
        },
      ),
    );
  }

  void showRenameBookDialog(Book book) {
    final _nameController = TextEditingController();
    final _descriptionController = TextEditingController();

    _nameController.text = book.name;
    _descriptionController.text = book.description;

    showDialog(
      context: context,
      builder: (context) => InputDialog(
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

  void showVisibilityDialog(Book book, int index) {
    final width = 310.0;

    showDialog(
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
                if (_multiSelectedItems.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.only(left: 18.0),
                    width: 300.0,
                    child: Opacity(
                      opacity: 0.6,
                      child: Text(
                        "multi_items_selected".plural(
                          _multiSelectedItems.length,
                        ),
                        style: Utilities.fonts.body(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
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
                  onChangedVisibility: (visibility) {
                    if (_multiSelectedItems.isEmpty) {
                      updateVisibility(book, visibility, index);
                    } else {
                      _multiSelectedItems.putIfAbsent(book.id, () => book);
                      updateGroupVisibility(visibility);
                    }

                    Beamer.of(context).popRoute();
                    clearSelection();
                  },
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

  void updateGroupVisibility(EnumContentVisibility visibility) {
    for (Book book in _multiSelectedItems.values) {
      final int index = _books.indexWhere(
        (x) => x.id == book.id,
      );

      updateVisibility(book, visibility, index);
    }
  }

  void updateVisibility(
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
      final response =
          await Utilities.cloud.fun("books-updateVisibility").call({
        "book_id": book.id,
        "visibility": visibility.name,
      });

      if (response.data['success'] as bool) {
        return;
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
    }
  }
}
