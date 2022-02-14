import 'package:artbooking/actions/books.dart';
import 'package:artbooking/components/dialogs/delete_dialog.dart';
import 'package:artbooking/components/dialogs/input_dialog.dart';
import 'package:artbooking/components/application_bar/application_bar.dart';
import 'package:artbooking/components/popup_menu/popup_menu_item_icon.dart';
import 'package:artbooking/components/dialogs/themed_dialog.dart';
import 'package:artbooking/components/popup_progress_indicator.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/router/navigation_state_helper.dart';
import 'package:artbooking/screens/dashboard/books/dashboard_page_books_body.dart';
import 'package:artbooking/screens/dashboard/books/dashboard_page_books_header.dart';
import 'package:artbooking/types/book/book.dart';
import 'package:artbooking/types/enums/enum_book_item_action.dart';
import 'package:artbooking/types/firestore/doc_snap_map.dart';
import 'package:artbooking/types/firestore/document_change_map.dart';
import 'package:artbooking/types/firestore/query_map.dart';
import 'package:artbooking/types/firestore/query_snapshot_stream_subscription.dart';
import 'package:artbooking/types/cloud_functions/book_response.dart';
import 'package:beamer/beamer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash/src/flash_helper.dart';
import 'package:flutter/material.dart';
import 'package:supercharged/supercharged.dart';
import 'package:unicons/unicons.dart';

class MyBooksPage extends StatefulWidget {
  @override
  _MyBooksPageState createState() => _MyBooksPageState();
}

class _MyBooksPageState extends State<MyBooksPage> {
  bool _loading = false;
  bool _descending = true;
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

  @override
  initState() {
    super.initState();
    fetchManyBooks();
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
      floatingActionButton: fab(),
      body: Stack(
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: onNotification,
            child: CustomScrollView(
              controller: _scrollController,
              slivers: <Widget>[
                ApplicationBar(),
                DashboardPageBooksHeader(
                  multiSelectActive: _forceMultiSelect,
                  multiSelectedItems: _multiSelectedItems,
                  onSelectAll: onSelectAll,
                  onClearSelection: onClearSelection,
                  onTriggerMultiSelect: onTriggerMultiSelect,
                  onShowCreateBookDialog: onShowCreateBookDialog,
                ),
                DashboardPageBooksBody(
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

  Widget fab() {
    if (!_isFabVisible) {
      return FloatingActionButton(
        onPressed: onShowCreateBookDialog,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        child: Icon(UniconsLine.plus),
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
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      child: Icon(UniconsLine.arrow_up),
    );
  }

  /// Fire when a new document has been created in Firestore.
  /// Add the corresponding document in the UI.
  void addStreamingDoc(DocumentChangeMap documentChange) {
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
          onValidate: () => deleteBook(book, index),
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

  void fetchManyBooks() async {
    setState(() {
      _loading = true;
      _hasNext = true;
      _books.clear();
    });

    try {
      final query = FirebaseFirestore.instance
          .collection('books')
          .where('user_id', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
          .orderBy('created_at', descending: _descending)
          .limit(_limit);

      startListenningToData(query);
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

  void fetchManyBooksMore() async {
    if (!_hasNext || _lastDocument == null) {
      return;
    }

    _isLoadingMore = true;

    try {
      final userAuth = FirebaseAuth.instance.currentUser;

      if (userAuth == null) {
        throw Exception("User is not authenticated.");
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('books')
          .where('user_id', isEqualTo: userAuth.uid)
          .orderBy('created_at', descending: _descending)
          .limit(_limit)
          .startAfterDocument(_lastDocument!)
          .get();

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
      fetchManyBooksMore();
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
  void removeStreamingDoc(DocumentChangeMap documentChange) {
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

  /// Listen to the last Firestore query of this page.
  void startListenningToData(QueryMap query) {
    _bookSubscription = query.snapshots().skip(1).listen(
      (snapshot) {
        for (DocumentChangeMap documentChange in snapshot.docChanges) {
          switch (documentChange.type) {
            case DocumentChangeType.added:
              addStreamingDoc(documentChange);
              break;
            case DocumentChangeType.modified:
              updateStreamingDoc(documentChange);
              break;
            case DocumentChangeType.removed:
              removeStreamingDoc(documentChange);
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
  void updateStreamingDoc(DocumentChangeMap documentChange) {
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

  void navigateToBook(Book book) {
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
      navigateToBook(book);
      return;
    }

    multiSelectBook(book);
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
        confirmDeleteOneBook(book, index);
        break;
      default:
    }
  }
}
