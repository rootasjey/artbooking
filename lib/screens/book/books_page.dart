import 'package:artbooking/components/application_bar/application_bar.dart';
import 'package:artbooking/components/dialogs/share_dialog.dart';
import 'package:artbooking/components/popup_menu/popup_menu_icon.dart';
import 'package:artbooking/components/popup_menu/popup_menu_item_icon.dart';
import 'package:artbooking/components/texts/page_title.dart';
import 'package:artbooking/globals/app_state.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/router/navigation_state_helper.dart';
import 'package:artbooking/screens/book/books_page_body.dart';
import 'package:artbooking/screens/book/books_page_fab.dart';
import 'package:artbooking/types/book/book.dart';
import 'package:artbooking/types/book/popup_entry_book.dart';
import 'package:artbooking/types/enums/enum_book_item_action.dart';
import 'package:artbooking/types/enums/enum_share_content_type.dart';
import 'package:artbooking/types/firestore/document_snapshot_map.dart';
import 'package:artbooking/types/firestore/query_doc_snap_map.dart';
import 'package:artbooking/types/firestore/document_change_map.dart';
import 'package:artbooking/types/firestore/query_map.dart';
import 'package:artbooking/types/firestore/query_snap_map.dart';
import 'package:artbooking/types/firestore/query_snapshot_stream_subscription.dart';
import 'package:artbooking/types/json_types.dart';
import 'package:beamer/beamer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_improved_scrolling/flutter_improved_scrolling.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicons/unicons.dart';

class BooksPage extends ConsumerStatefulWidget {
  const BooksPage({Key? key}) : super(key: key);

  @override
  _BooksPageState createState() => _BooksPageState();
}

class _BooksPageState extends ConsumerState<BooksPage> {
  /// Start from the most recent.
  bool _descending = true;

  /// If true, there are more books to fetch.
  bool _hasNext = false;

  /// Loading the current page if true.
  bool _loading = false;

  /// Loading the next page if true.
  bool _loadingMore = true;

  /// Show the page floating action button if true.
  bool _showFabToTop = false;

  /// Last fetched book document.
  DocumentSnapshot? _lastDocument;

  /// Last saved Y offset.
  /// Used while scrolling to know the direction.
  double _previousOffset = 0.0;

  /// Maximum books fetched in a page.
  final int _limit = 50;

  /// Book list.
  final List<Book> _books = [];

  /// Listens to book's updates.
  QuerySnapshotStreamSubscription? _bookSubscription;

  /// Listens to user like's updates.
  QuerySnapshotStreamSubscription? _likeSubscription;

  /// Available items for authenticated user and book is not liked yet.
  final List<PopupEntryBook> _likePopupMenuEntries = [
    PopupMenuItemIcon(
      value: EnumBookItemAction.like,
      icon: PopupMenuIcon(UniconsLine.heart),
      textLabel: "like".tr(),
    ),
    PopupMenuItemIcon(
      icon: PopupMenuIcon(UniconsLine.share),
      textLabel: "share".tr(),
      value: EnumBookItemAction.share,
    ),
  ];

  /// Available items for authenticated user and book is already liked.
  final List<PopupEntryBook> _unlikePopupMenuEntries = [
    PopupMenuItemIcon(
      value: EnumBookItemAction.unlike,
      icon: PopupMenuIcon(UniconsLine.heart_break),
      textLabel: "unlike".tr(),
    ),
    PopupMenuItemIcon(
      icon: PopupMenuIcon(UniconsLine.share),
      textLabel: "share".tr(),
      value: EnumBookItemAction.share,
    ),
  ];

  /// Page scroll controller.
  final _pageScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchBooks();
    listenLikeEvents();
  }

  @override
  void dispose() {
    _bookSubscription?.cancel();
    _likeSubscription?.cancel();
    _pageScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String? userId = ref.watch(AppState.userProvider).firestoreUser?.id;
    final bool isAuth = userId != null && userId.isNotEmpty;
    final onDoubleTapOrNull = isAuth ? onDoubleTapBookItem : null;
    final likeEntries = isAuth ? _likePopupMenuEntries : <PopupEntryBook>[];
    final unlikeEntries = isAuth ? _unlikePopupMenuEntries : <PopupEntryBook>[];

    final bool isMobileSize = Utilities.size.isMobileSize(context);

    return Scaffold(
      floatingActionButton: BooksPageFab(
        show: _showFabToTop,
        onPressed: onPressedFab,
      ),
      body: ImprovedScrolling(
        enableKeyboardScrolling: true,
        enableMMBScrolling: true,
        onScroll: onPageScroll,
        scrollController: _pageScrollController,
        child: CustomScrollView(
          controller: _pageScrollController,
          slivers: <Widget>[
            ApplicationBar(
              bottom: PreferredSize(
                child: PageTitle(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  padding: EdgeInsets.only(
                    left: isMobileSize ? 12.0 : 36.0,
                    bottom: 8.0,
                  ),
                  showBackButton: false,
                  subtitleValue: "books_browse".tr(),
                  titleValue: "books".tr(),
                  renderSliver: false,
                ),
                preferredSize: Size.fromHeight(100.0),
              ),
              pinned: false,
            ),
            BooksPageBody(
              isMobileSize: isMobileSize,
              loading: _loading,
              books: _books,
              onTap: onTapBook,
              onDoubleTap: onDoubleTapOrNull,
              likePopupMenuEntries: likeEntries,
              unlikePopupMenuEntries: unlikeEntries,
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

  void fetchBooks() async {
    setState(() {
      _loading = true;
      _hasNext = true;
      _books.clear();
    });

    try {
      final QuerySnapMap snapshot = await FirebaseFirestore.instance
          .collection("books")
          .where("visibility", isEqualTo: "public")
          .where("staff_review.approved", isEqualTo: true)
          .orderBy("updated_at", descending: _descending)
          .limit(_limit)
          .get();

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

      listenBookEvents(getListenQuery());
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    } finally {
      setState(() => _loading = false);
    }
  }

  void fetchMoreBooks() async {
    final lastDocument = _lastDocument;

    if (!_hasNext || lastDocument == null || _loadingMore) {
      return;
    }

    _loadingMore = true;

    try {
      final QuerySnapMap snapshot = await FirebaseFirestore.instance
          .collection("books")
          .where("visibility", isEqualTo: "public")
          .where("staff_review.approved", isEqualTo: true)
          .orderBy("updated_at", descending: _descending)
          .limit(_limit)
          .startAfterDocument(lastDocument)
          .get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          _hasNext = false;
          _loadingMore = false;
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
        _loadingMore = false;
        _lastDocument = snapshot.docs.last;
        _hasNext = snapshot.docs.length == _limit;
      });

      listenBookEvents(getListenQuery());
    } catch (error) {
      Utilities.logger.e(error);
    } finally {
      setState(() => _loading = false);
    }
  }

  /// Return the query to listen changes to.
  QueryMap? getListenQuery() {
    final DocumentSnapshot? lastDocument = _lastDocument;
    if (lastDocument == null) {
      return null;
    }

    return FirebaseFirestore.instance
        .collection("books")
        .where("visibility", isEqualTo: "public")
        .where("staff_review.approved", isEqualTo: true)
        .orderBy("updated_at", descending: _descending)
        .endAtDocument(lastDocument);
  }

  /// Listen to Firestore book events.
  void listenBookEvents(QueryMap? query) {
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

  /// Listen to books' likes for sync purpose.
  void listenLikeEvents() {
    String? userId = ref.read(AppState.userProvider).firestoreUser?.id;
    if (userId == null || userId.isEmpty) {
      return;
    }

    _likeSubscription = FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("user_likes")
        .where("type", isEqualTo: "book")
        .snapshots()
        .skip(1)
        .listen(
      (snapshot) {
        for (DocumentChangeMap documentChange in snapshot.docChanges) {
          switch (documentChange.type) {
            case DocumentChangeType.added:
              onAddStreamingLike(documentChange);
              break;
            case DocumentChangeType.removed:
              onRemoveStreamingLike(documentChange);
              break;
            default:
          }
        }
      },
      onError: (error) {
        Utilities.logger.e(error);
      },
      onDone: () {
        _likeSubscription?.cancel();
      },
    );
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

    if (scrollingDown) {
      if (!_showFabToTop) {
        return;
      }

      setState(() => _showFabToTop = false);
      return;
    }

    if (offset == 0.0) {
      setState(() => _showFabToTop = false);
      return;
    }

    if (_showFabToTop) {
      return;
    }

    setState(() => _showFabToTop = true);
  }

  void onTapBook(Book book) {
    NavigationStateHelper.book = book;
    Beamer.of(context).beamToNamed(
      "/books/${book.id}",
      data: {
        "bookId": book.id,
      },
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

  void onAddStreamingLike(DocumentChangeMap documentChange) {
    final String likeId = documentChange.doc.id;
    final int index = _books.indexWhere((x) => x.id == likeId);

    if (index < 0) {
      return;
    }

    final Book book = _books.elementAt(index);
    if (book.liked) {
      return;
    }

    setState(() {
      _books.replaceRange(
        index,
        index + 1,
        [book.copyWith(liked: true)],
      );
    });
  }

  void onDoubleTapBookItem(Book book, int index) {
    onLike(book, index);
  }

  void onPressedFab() {
    _pageScrollController.animateTo(
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

  /// Callback when the page scrolls up and down.
  void onPageScroll(double offset) {
    maybeShowFab(offset);
    maybeFetchMore(offset);
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
      case EnumBookItemAction.share:
        showShareDialog(book, index);
        break;
      default:
    }
  }

  /// Fire when a new document has been delete from Firestore.
  /// Delete the corresponding document from the UI.
  void onRemoveStreamingBook(DocumentChangeMap documentChange) {
    setState(() {
      _books.removeWhere((book) => book.id == documentChange.doc.id);
    });
  }

  void onRemoveStreamingLike(DocumentChangeMap documentChange) {
    final String likeId = documentChange.doc.id;
    final int index = _books.indexWhere((x) => x.id == likeId);

    if (index < 0) {
      return;
    }

    final Book book = _books.elementAt(index);
    if (!book.liked) {
      return;
    }

    setState(() {
      _books.replaceRange(
        index,
        index + 1,
        [book.copyWith(liked: false)],
      );
    });
  }

  void showShareDialog(Book book, int index) {
    showDialog(
      context: context,
      builder: (context) => ShareDialog(
        extension: "",
        itemId: book.id,
        imageProvider: NetworkImage(book.getCoverLink()),
        name: book.name,
        imageUrl: book.getCoverLink(),
        shareContentType: EnumShareContentType.book,
        userId: book.userId,
        username: "",
        visibility: book.visibility,
      ),
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
}
