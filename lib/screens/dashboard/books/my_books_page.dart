import 'package:artbooking/actions/books.dart';
import 'package:artbooking/components/dialogs/delete_dialog.dart';
import 'package:artbooking/components/dialogs/input_dialog.dart';
import 'package:artbooking/components/application_bar/application_bar.dart';
import 'package:artbooking/components/popup_menu/popup_menu_item_icon.dart';
import 'package:artbooking/components/dialogs/themed_dialog.dart';
import 'package:artbooking/components/popup_progress_indicator.dart';
import 'package:artbooking/globals/app_state.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/router/navigation_state_helper.dart';
import 'package:artbooking/screens/dashboard/books/my_books_page_body.dart';
import 'package:artbooking/screens/dashboard/books/my_books_page_fab.dart';
import 'package:artbooking/screens/dashboard/books/my_books_page_header.dart';
import 'package:artbooking/types/book/book.dart';
import 'package:artbooking/types/enums/enum_book_item_action.dart';
import 'package:artbooking/types/enums/enum_visibility_tab.dart';
import 'package:artbooking/types/firestore/doc_snap_map.dart';
import 'package:artbooking/types/firestore/document_change_map.dart';
import 'package:artbooking/types/firestore/query_map.dart';
import 'package:artbooking/types/firestore/query_snapshot_stream_subscription.dart';
import 'package:artbooking/types/cloud_functions/book_response.dart';
import 'package:beamer/beamer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flash/src/flash_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicons/unicons.dart';

class MyBooksPage extends ConsumerStatefulWidget {
  @override
  _MyBooksPageState createState() => _MyBooksPageState();
}

class _MyBooksPageState extends ConsumerState<MyBooksPage> {
  bool _loading = false;
  bool _hasNext = true;
  bool _isFabVisible = false;
  bool _isLoadingMore = false;
  bool _forceMultiSelect = false;
  bool _creating = false;

  DocumentSnapshot? _lastDocument;

  final _books = <Book>[];
  final _focusNode = FocusNode();

  final _popupMenuEntries = <PopupMenuEntry<EnumBookItemAction>>[
    PopupMenuItemIcon(
      icon: Icon(UniconsLine.edit_alt),
      textLabel: "rename".tr(),
      value: EnumBookItemAction.rename,
    ),
    PopupMenuItemIcon(
      icon: Icon(UniconsLine.trash),
      textLabel: "delete".tr(),
      value: EnumBookItemAction.delete,
    ),
  ];

  int _limit = 20;

  Map<String?, Book> _multiSelectedItems = Map();

  ScrollController _scrollController = ScrollController();

  QuerySnapshotStreamSubscription? _bookSubscription;

  EnumVisibilityTab _selectedTab = EnumVisibilityTab.active;

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: MyBooksPageFab(
        scrollController: _scrollController,
        show: _isFabVisible,
        onShowCreateBookDialog: onShowCreateBookDialog,
      ),
      body: Stack(
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: onScrollNotification,
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
                  onClearSelection: onClearSelection,
                  onTriggerMultiSelect: onTriggerMultiSelect,
                  onShowCreateBookDialog: onShowCreateBookDialog,
                ),
                MyBooksPageBody(
                  books: _books,
                  loading: _loading,
                  onShowCreateBookDialog: onShowCreateBookDialog,
                  popupMenuEntries: _popupMenuEntries,
                  onLongPressBook: onLongPressBook,
                  forceMultiSelect: _forceMultiSelect,
                  multiSelectedItems: _multiSelectedItems,
                  onPopupMenuItemSelected: onPopupMenuItemSelected,
                  onTapBook: onTapBook,
                ),
                SliverPadding(
                  padding: const EdgeInsets.only(bottom: 100.0),
                ),
              ],
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
    );
  }

  /// Fire when a new document has been created in Firestore.
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

  /// Show a dialog to confirm multiple books deletion.
  void confirmDeleteManyBooks() async {
    showDialog(
      context: context,
      builder: (context) {
        return ThemedDialog(
          focusNode: _focusNode,
          title: Column(
            children: [
              Opacity(
                opacity: 0.8,
                child: Text(
                  "books_delete".tr().toUpperCase(),
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
                    "books_delete_description".tr(),
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
            deleteSelection();
            Beamer.of(context).popRoute();
          },
        );
      },
    );
  }

  /// Show a dialog to confirm a single book deletion.
  void confirmDeleteOneBook(Book book, int index) async {
    showDialog(
      context: context,
      builder: (context) {
        return DeleteDialog(
          titleValue: "book_delete".tr().toUpperCase(),
          descriptionValue: "book_delete_description".tr(),
          onValidate: () => onDeleteBook(book, index),
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

  void deleteSelection() async {
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
          .where("visibility", isNotEqualTo: "archived")
          .limit(_limit);
    }
    return FirebaseFirestore.instance
        .collection("books")
        .where("user_id", isEqualTo: userId)
        .where("visibility", isEqualTo: "archived")
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
          .where("visibility", isNotEqualTo: "archived")
          .limit(_limit)
          .startAfterDocument(lastDocument);
    }
    return FirebaseFirestore.instance
        .collection("books")
        .where("user_id", isEqualTo: userId)
        .where("visibility", isNotEqualTo: "archived")
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

      for (DocSnapMap document in snapshot.docs) {
        final data = document.data();
        data['id'] = document.id;
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

  void fetchMoreBooks() async {
    if (!_hasNext || _lastDocument == null) {
      return;
    }

    _isLoadingMore = true;

    try {
      final QueryMap? query = getFetchMoreQuery();
      if (query == null) {
        return;
      }

      final snapshot = await query.get();
      if (snapshot.docs.isEmpty) {
        setState(() {
          _hasNext = false;
          _isLoadingMore = false;
        });

        return;
      }

      for (DocSnapMap document in snapshot.docs) {
        final data = document.data();
        data['id'] = document.id;

        _books.add(Book.fromMap(data));
      }

      setState(() {
        _isLoadingMore = false;
        _lastDocument = snapshot.docs.last;
        _hasNext = snapshot.docs.length == _limit;
      });
    } catch (error) {
      Utilities.logger.e(error);
    } finally {
      setState(() => _loading = false);
    }
  }

  void loadPreferences() {
    _selectedTab = Utilities.storage.getBooksTab();
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

  /// On scroll notifications.
  bool onScrollNotification(ScrollNotification notification) {
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
      fetchMoreBooks();
    }

    return false;
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

  void onChangedTab(EnumVisibilityTab selectedTab) {
    setState(() {
      _selectedTab = selectedTab;
    });

    fetchBooks();
    Utilities.storage.saveBooksTab(selectedTab);
  }

  void onClearSelection() {
    setState(() {
      _multiSelectedItems.clear();
      _forceMultiSelect = _multiSelectedItems.length > 0;
    });
  }

  void onTriggerMultiSelect() {
    setState(() {
      _forceMultiSelect = !_forceMultiSelect;
    });
  }

  /// Fire when a new document has been delete from Firestore.
  /// Delete the corresponding document from the UI.
  void onRemoveStreamingBook(DocumentChangeMap documentChange) {
    setState(() {
      _books.removeWhere((book) => book.id == documentChange.doc.id);
    });
  }

  void onShowCreateBookDialog() {
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

  void onShowRenameBookDialog(Book book) {
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
          onRenameBook(
            book,
            _nameController.text,
            _descriptionController.text,
          );
          Beamer.of(context).popRoute();
        },
      ),
    );
  }

  /// Rename one book.
  void onRenameBook(Book book, String name, String description) async {
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

  /// Listen to the last Firestore query of this page.
  void listenBooksEvents(QueryMap query) {
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

  void onDeleteBook(Book book, int index) async {
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

  void onMultiSelectBook(book) {
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

  void onNavigateToBook(Book book) {
    NavigationStateHelper.book = book;
    Beamer.of(context).beamToNamed(
      "dashboard/books/${book.id}",
      data: {
        "bookId": book.id,
      },
    );
  }

  /// When [onTapBook] event fires on a book.
  void onTapBook(Book book) {
    if (_multiSelectedItems.isEmpty && !_forceMultiSelect) {
      onNavigateToBook(book);
      return;
    }

    onMultiSelectBook(book);
  }

  void onPopupMenuItemSelected(
    EnumBookItemAction action,
    int index,
    Book book,
  ) {
    switch (action) {
      case EnumBookItemAction.rename:
        onShowRenameBookDialog(book);
        break;
      case EnumBookItemAction.delete:
        confirmDeleteOneBook(book, index);
        break;
      default:
    }
  }
}
