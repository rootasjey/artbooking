import 'package:artbooking/components/application_bar/application_bar.dart';
import 'package:artbooking/components/popup_menu/popup_menu_item_icon.dart';
import 'package:artbooking/components/texts/page_title.dart';
import 'package:artbooking/globals/app_state.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/router/navigation_state_helper.dart';
import 'package:artbooking/screens/book/books_page_body.dart';
import 'package:artbooking/screens/book/books_page_fab.dart';
import 'package:artbooking/types/book/book.dart';
import 'package:artbooking/types/enums/enum_book_item_action.dart';
import 'package:artbooking/types/firestore/doc_snap_map.dart';
import 'package:artbooking/types/firestore/document_change_map.dart';
import 'package:artbooking/types/firestore/query_map.dart';
import 'package:artbooking/types/firestore/query_snapshot_stream_subscription.dart';
import 'package:beamer/beamer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicons/unicons.dart';

class BooksPage extends ConsumerStatefulWidget {
  const BooksPage({Key? key}) : super(key: key);

  @override
  _BooksPageState createState() => _BooksPageState();
}

class _BooksPageState extends ConsumerState<BooksPage> {
  bool _loading = false;
  bool _hasNext = false;
  bool _descending = true;
  bool _isLoadingMore = true;
  bool _showFab = false;

  DocumentSnapshot? _lastDocument;

  final int _limit = 50;

  final List<Book> _books = [];

  /// Listens to book's updates.
  QuerySnapshotStreamSubscription? _bookSubscription;

  /// Items when opening the popup.
  final List<PopupMenuEntry<EnumBookItemAction>> _likePopupMenuEntries = [
    PopupMenuItemIcon(
      value: EnumBookItemAction.like,
      icon: Icon(UniconsLine.heart),
      textLabel: "like".tr(),
    ),
  ];

  /// Items when opening the popup.
  final List<PopupMenuEntry<EnumBookItemAction>> _unlikePopupMenuEntries = [
    PopupMenuItemIcon(
      value: EnumBookItemAction.unlike,
      icon: Icon(UniconsLine.heart_break),
      textLabel: "unlike".tr(),
    ),
  ];

  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchManyBooks();
  }

  @override
  void dispose() {
    _bookSubscription?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: BooksPageFab(
        show: _showFab,
        onPressed: onPressedFab,
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: onNotification,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: <Widget>[
            ApplicationBar(),
            PageTitle(
              showBackButton: true,
              titleValue: "books".tr(),
              subtitleValue: "books_browse".tr(),
              padding: const EdgeInsets.only(top: 70.0, bottom: 24.0),
            ),
            BooksPageBody(
              loading: _loading,
              books: _books,
              onTap: navigateToBook,
              onDoubleTap: onDoubleTapBookItem,
              likePopupMenuEntries: _likePopupMenuEntries,
              unlikePopupMenuEntries: _unlikePopupMenuEntries,
              onPopupMenuItemSelected: onPopupMenuItemSelected,
            ),
            SliverPadding(
              padding: const EdgeInsets.only(bottom: 100.0),
            ),
          ],
        ),
      ),
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

  void fetchManyBooks() async {
    setState(() {
      _loading = true;
      _hasNext = true;
      _books.clear();
    });

    try {
      final query = FirebaseFirestore.instance
          .collection("books")
          .where("visibility", isEqualTo: "public")
          .orderBy("updated_at", descending: _descending)
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
        data['liked'] = await fetchLike(document.id);

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
    final lastDocument = _lastDocument;

    if (!_hasNext || lastDocument == null || _isLoadingMore) {
      return;
    }

    _isLoadingMore = true;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("books")
          .where("visibility", isEqualTo: "public")
          .orderBy("updated_at", descending: _descending)
          .limit(_limit)
          .startAfterDocument(lastDocument)
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

  void navigateToBook(Book book) {
    NavigationStateHelper.book = book;
    Beamer.of(context).beamToNamed(
      "/books/${book.id}",
      data: {
        "bookId": book.id,
      },
    );
  }

  void onPressedFab() {
    _scrollController.animateTo(
      0.0,
      duration: Duration(seconds: 1),
      curve: Curves.easeOut,
    );
  }

  void onLike(Book book, int index) {
    if (book.liked) {
      return tryUnLike(book, index);
    }

    return tryLike(book, index);
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
      fetchManyBooksMore();
    }

    return false;
  }

  void onPopupMenuItemSelected(
    EnumBookItemAction action,
    int index,
    Book book,
  ) {
    switch (action) {
      case EnumBookItemAction.like:
      case EnumBookItemAction.unlike:
        onLike(book, index);
        break;
      default:
    }
  }

  /// Fire when a new document has been delete from Firestore.
  /// Delete the corresponding document from the UI.
  void removeStreamingDoc(DocumentChangeMap documentChange) {
    setState(() {
      _books.removeWhere((book) => book.id == documentChange.doc.id);
    });
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

  void tryLike(Book book, int index) async {
    setState(() {
      _books.replaceRange(
        index,
        index + 1,
        [book.copyWith(liked: true)],
      );
    });

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
      setState(() {
        _books.replaceRange(
          index,
          index + 1,
          [book.copyWith(liked: false)],
        );
      });
    }
  }

  void tryUnLike(Book book, int index) async {
    setState(() {
      _books.replaceRange(
        index,
        index + 1,
        [book.copyWith(liked: false)],
      );
    });

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
      setState(() {
        _books.replaceRange(
          index,
          index + 1,
          [book.copyWith(liked: true)],
        );
      });
    }
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

  Future<bool> fetchLike(String bookId) async {
    try {
      final String? userId = ref.read(AppState.userProvider).firestoreUser?.id;
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

  void onDoubleTapBookItem(Book book, int index) {
    onLike(book, index);
  }
}
