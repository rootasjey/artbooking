import 'package:artbooking/components/application_bar/application_bar.dart';
import 'package:artbooking/components/custom_scroll_behavior.dart';
import 'package:artbooking/components/popup_menu/popup_menu_icon.dart';
import 'package:artbooking/components/popup_menu/popup_menu_item_icon.dart';
import 'package:artbooking/globals/app_state.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/router/navigation_state_helper.dart';
import 'package:artbooking/screens/likes/likes_page_body.dart';
import 'package:artbooking/components/buttons/fab_to_top.dart';
import 'package:artbooking/screens/likes/likes_page_header.dart';
import 'package:artbooking/types/book/book.dart';
import 'package:artbooking/types/book/popup_entry_book.dart';
import 'package:artbooking/types/enums/enum_book_item_action.dart';
import 'package:artbooking/types/enums/enum_illustration_item_action.dart';
import 'package:artbooking/types/enums/enum_like_type.dart';
import 'package:artbooking/types/firestore/document_change_map.dart';
import 'package:artbooking/types/firestore/document_snapshot_map.dart';
import 'package:artbooking/types/firestore/query_doc_snap_map.dart';
import 'package:artbooking/types/firestore/query_map.dart';
import 'package:artbooking/types/firestore/query_snap_map.dart';
import 'package:artbooking/types/firestore/query_snapshot_stream_subscription.dart';
import 'package:artbooking/types/illustration/illustration.dart';
import 'package:artbooking/types/illustration/popup_entry_illustration.dart';
import 'package:artbooking/types/json_types.dart';
import 'package:beamer/beamer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_improved_scrolling/flutter_improved_scrolling.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicons/unicons.dart';

class LikesPage extends ConsumerStatefulWidget {
  const LikesPage({Key? key}) : super(key: key);

  @override
  ConsumerState<LikesPage> createState() => _LikesPageState();
}

class _LikesPageState extends ConsumerState<LikesPage> {
  /// Order results from most recent or oldest.
  bool _descending = true;

  /// If true, there are more liked items to fetch.
  bool _hasNext = true;

  /// Loading the next page if true.
  bool _loadingMore = false;

  /// Loading the current page if true.
  bool _loading = false;

  /// Show the page floating action button if true.
  bool _showFabToTop = false;

  /// Last fetched document snapshot. Used for pagination.
  DocumentSnapshot<Object>? _lastDocument;

  double _previousOffset = 0.0;

  /// Selected tab to show license (staff or user).
  var _selectedTab = EnumLikeType.illustration;

  /// List of liked illustrations.
  final List<Illustration> _likedIllustrations = [];

  /// List of liked books.
  final List<Book> _likedBooks = [];

  /// Menu items for books.
  final List<PopupEntryBook> _bookPopupMenuEntries = [
    PopupMenuItemIcon(
      delay: Duration(milliseconds: 25),
      value: EnumBookItemAction.unlike,
      icon: PopupMenuIcon(UniconsLine.heart_break),
      textLabel: "unlike".tr(),
    ),
  ];

  /// Menu items for illustrations.
  final List<PopupEntryIllustration> _illustrationPopupMenuEntries = [
    PopupMenuItemIcon(
      delay: Duration(milliseconds: 25),
      value: EnumIllustrationItemAction.unlike,
      icon: PopupMenuIcon(UniconsLine.heart_break),
      textLabel: "unlike".tr(),
    ),
  ];

  /// Maximum likes to fetch in one request.
  final int _limit = 20;

  /// Subscribe to illustration collection updates.
  QuerySnapshotStreamSubscription? _likeSubscription;

  /// Page scroll controller.
  final _pageScrollController = ScrollController();

  @override
  initState() {
    super.initState();
    loadPreferences();
    fetchLikes();
  }

  @override
  void dispose() {
    _likeSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobileSize = Utilities.size.isMobileSize(context);

    return Scaffold(
      floatingActionButton: FabToTop(
        show: _showFabToTop,
        pageScrollController: _pageScrollController,
      ),
      body: ImprovedScrolling(
        scrollController: _pageScrollController,
        enableKeyboardScrolling: true,
        enableMMBScrolling: true,
        onScroll: onPageScroll,
        child: ScrollConfiguration(
          behavior: CustomScrollBehavior(),
          child: CustomScrollView(
            controller: _pageScrollController,
            slivers: <Widget>[
              ApplicationBar(
                bottom: PreferredSize(
                  child: LikesPageHeader(
                    isMobileSize: isMobileSize,
                    selectedTab: _selectedTab,
                    onChangedTab: onChangedTab,
                  ),
                  preferredSize: Size.fromHeight(160.0),
                ),
                minimal: true,
                pinned: false,
              ),
              LikesPageBody(
                isMobileSize: isMobileSize,
                loading: _loading,
                books: _likedBooks,
                selectedTab: _selectedTab,
                illustrations: _likedIllustrations,
                bookPopupMenuEntries: _bookPopupMenuEntries,
                illustrationPopupMenuEntries: _illustrationPopupMenuEntries,
                onTapBrowse: onTapBrowse,
                onTapBook: onTapBook,
                onTapIllustration: onTapIllustration,
                onUnlikeBook: onUnlikeBook,
                onUnlikeIllustration: onUnlikeIllustration,
                onPopupMenuBookSelected: onPopupMenuBookSelected,
                onPopupMenuIllustrationSelected:
                    onPopupMenuIllustrationSelected,
              )
            ],
          ),
        ),
      ),
    );
  }

  /// Fetch liked books or illustrations on Firestore.
  void fetchLikes() async {
    setState(() {
      _lastDocument = null;
      _loading = true;
    });

    if (_selectedTab == EnumLikeType.book) {
      return fetchLikedBooks();
    }

    return fetchLikedIllustrations();
  }

  void fetchLikedBooks() async {
    final String? userId = ref.read(AppState.userProvider).firestoreUser?.id;
    if (userId == null) {
      return;
    }

    _likedBooks.clear();

    try {
      final QuerySnapMap snapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("user_likes")
          .where("type", isEqualTo: "book")
          .orderBy("created_at", descending: _descending)
          .limit(_limit)
          .get();

      if (snapshot.docs.isEmpty) {
        return;
      }

      for (final QueryDocSnapMap document in snapshot.docs) {
        final DocumentSnapshotMap bookSnapshot = await FirebaseFirestore
            .instance
            .collection("books")
            .doc(document.id)
            .get();

        final Json? bookData = bookSnapshot.data();

        if (bookData != null) {
          bookData["id"] = bookSnapshot.id;
          bookData["liked"] = true;

          _likedBooks.add(Book.fromMap(bookData));
        }
      }

      _lastDocument = snapshot.docs.last;
      listenLikeEvents(getListenQuery());
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    } finally {
      setState(() => _loading = false);
    }
  }

  void fetchLikedIllustrations() async {
    final String? userId = ref.read(AppState.userProvider).firestoreUser?.id;
    if (userId == null) {
      return;
    }

    _likedIllustrations.clear();

    try {
      final QuerySnapMap snapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("user_likes")
          .where("type", isEqualTo: "illustration")
          .orderBy("created_at", descending: _descending)
          .limit(_limit)
          .get();

      if (snapshot.docs.isEmpty) {
        return;
      }

      for (final QueryDocSnapMap document in snapshot.docs) {
        final DocumentSnapshotMap illustrationSnapshot = await FirebaseFirestore
            .instance
            .collection("illustrations")
            .doc(document.id)
            .get();

        final Json? illustrationData = illustrationSnapshot.data();

        if (illustrationData != null) {
          illustrationData["id"] = illustrationSnapshot.id;
          illustrationData["liked"] = true;
          _likedIllustrations.add(Illustration.fromMap(illustrationData));
        }
      }

      _lastDocument = snapshot.docs.last;
      listenLikeEvents(getListenQuery());
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    } finally {
      setState(() => _loading = false);
    }
  }

  void fetchMoreLikes() {
    if (_selectedTab == EnumLikeType.book) {
      return fetchMoreLikedBooks();
    }

    return fetchMoreLikedIllustrations();
  }

  void fetchMoreLikedBooks() async {
    final DocumentSnapshot? lastDocumentSnapshot = _lastDocument;
    if (lastDocumentSnapshot == null) {
      return;
    }

    final String? userId = ref.read(AppState.userProvider).firestoreUser?.id;
    if (userId == null) {
      return;
    }

    try {
      final QuerySnapMap snapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("user_likes")
          .where("type", isEqualTo: "book")
          .orderBy("created_at", descending: _descending)
          .startAfterDocument(lastDocumentSnapshot)
          .limit(_limit)
          .get();

      if (snapshot.docs.isEmpty) {
        return;
      }

      for (final QueryDocSnapMap document in snapshot.docs) {
        final DocumentSnapshotMap bookSnapshot = await FirebaseFirestore
            .instance
            .collection("books")
            .doc(document.id)
            .get();

        final Json? bookData = bookSnapshot.data();

        if (bookData != null) {
          bookData["id"] = bookSnapshot.id;
          bookData["liked"] = true;

          _likedBooks.add(Book.fromMap(bookData));
        }
      }

      _lastDocument = snapshot.docs.last;
      listenLikeEvents(getListenQuery());
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    } finally {
      setState(() => _loading = false);
    }
  }

  void fetchMoreLikedIllustrations() async {
    final DocumentSnapshot? lastDocumentSnapshot = _lastDocument;
    if (lastDocumentSnapshot == null) {
      return;
    }

    final String? userId = ref.read(AppState.userProvider).firestoreUser?.id;
    if (userId == null) {
      return;
    }

    try {
      final QuerySnapMap snapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("user_likes")
          .where("type", isEqualTo: "illustration")
          .orderBy("created_at", descending: _descending)
          .startAfterDocument(lastDocumentSnapshot)
          .limit(_limit)
          .get();

      if (snapshot.docs.isEmpty) {
        return;
      }

      for (final QueryDocSnapMap document in snapshot.docs) {
        final DocumentSnapshotMap illustrationSnapshot = await FirebaseFirestore
            .instance
            .collection("illustrations")
            .doc(document.id)
            .get();

        final Json? illustrationData = illustrationSnapshot.data();

        if (illustrationData != null) {
          illustrationData["id"] = illustrationSnapshot.id;
          illustrationData["liked"] = true;
          _likedIllustrations.add(Illustration.fromMap(illustrationData));
        }
      }

      _lastDocument = snapshot.docs.last;
      listenLikeEvents(getListenQuery());
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
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

    final String? userId = ref.read(AppState.userProvider).firestoreUser?.id;

    if (_selectedTab == EnumLikeType.book) {
      return FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("user_likes")
          .where("type", isEqualTo: "book")
          .orderBy("created_at", descending: _descending)
          .endAtDocument(lastDocument);
    }

    return FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("user_likes")
        .where("type", isEqualTo: "illustration")
        .orderBy("created_at", descending: _descending)
        .endAtDocument(lastDocument);
  }

  /// Listen to the last Firestore query of this page.
  void listenLikeEvents(QueryMap? query) {
    if (query == null) {
      return;
    }

    _likeSubscription?.cancel();
    _likeSubscription = query.snapshots().skip(1).listen(
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
    );
  }

  void loadPreferences() {
    _selectedTab = Utilities.storage.getLikesTab();
  }

  void maybeFetchMore(double offset) {
    if (_pageScrollController.position.atEdge &&
        offset > 50 &&
        _hasNext &&
        !_loadingMore) {
      _selectedTab == EnumLikeType.book
          ? fetchMoreLikedBooks()
          : fetchMoreLikedIllustrations();
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

  void onChangedTab(EnumLikeType likeType) {
    setState(() {
      _selectedTab = likeType;
    });

    fetchLikes();
    Utilities.storage.saveLikesTab(likeType);
  }

  /// Fire when a new document has been created in Firestore.
  /// Add the corresponding document in the UI.
  void onAddStreamingLike(DocumentChangeMap documentChange) {
    final data = documentChange.doc.data();
    if (data == null) {
      return;
    }

    if (_selectedTab == EnumLikeType.book) {
      return onAddStreamingIllustration(documentChange);
    }

    setState(() {
      data['id'] = documentChange.doc.id;
      data['liked'] = true;
      final book = Illustration.fromMap(data);
      _likedIllustrations.insert(0, book);
    });
  }

  void onAddStreamingIllustration(DocumentChangeMap documentChange) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("illustrations")
          .doc(documentChange.doc.id)
          .get();

      final data = snapshot.data();
      if (!snapshot.exists || data == null) {
        return;
      }

      data['id'] = snapshot.id;
      data['liked'] = true;
      final illustration = Illustration.fromMap(data);
      _likedIllustrations.insert(0, illustration);
    } catch (error) {
      Utilities.logger.e(error);
    }
  }

  void onAddStreamingBook(DocumentChangeMap documentChange) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("books")
          .doc(documentChange.doc.id)
          .get();

      final data = snapshot.data();
      if (!snapshot.exists || data == null) {
        return;
      }

      data['id'] = snapshot.id;
      data['liked'] = true;
      final book = Book.fromMap(data);
      _likedBooks.insert(0, book);
    } catch (error) {
      Utilities.logger.e(error);
    }
  }

  /// On scroll notification
  bool onNotification(ScrollNotification notification) {
    if (notification.metrics.pixels < 50 && _showFabToTop) {
      setState(() => _showFabToTop = false);
    } else if (notification.metrics.pixels > 50 && !_showFabToTop) {
      setState(() => _showFabToTop = true);
    }

    if (notification.metrics.pixels < notification.metrics.maxScrollExtent) {
      return false;
    }

    if (_hasNext && !_loadingMore && _lastDocument != null) {
      fetchMoreLikes();
    }

    return false;
  }

  /// Callback when the page scrolls up and down.
  void onPageScroll(double offset) {
    maybeShowFab(offset);
    maybeFetchMore(offset);
  }

  void onPopupMenuBookSelected(
    EnumBookItemAction action,
    int index,
    Book book,
  ) {
    switch (action) {
      case EnumBookItemAction.unlike:
        onUnlikeBook(book, index);
        break;
      default:
    }
  }

  void onPopupMenuIllustrationSelected(
    EnumIllustrationItemAction action,
    int index,
    Illustration illustration,
    String illustrationKey,
  ) {
    switch (action) {
      case EnumIllustrationItemAction.unlike:
        onUnlikeIllustration(illustration, index);
        break;
      default:
    }
  }

  /// Fire when a new document has been delete from Firestore.
  /// Delete the corresponding document from the UI.
  void onRemoveStreamingLike(DocumentChangeMap documentChange) {
    if (_selectedTab == EnumLikeType.book) {
      setState(() {
        _likedBooks.removeWhere((x) => x.id == documentChange.doc.id);
      });
      return;
    }

    setState(() {
      _likedIllustrations.removeWhere((x) => x.id == documentChange.doc.id);
    });
  }

  void onTapBook(Book book) {
    NavigationStateHelper.book = book;
    Beamer.of(context, root: true).beamToNamed(
      "/books/${book.id}",
      data: {
        "bookId": book.id,
      },
    );
  }

  void onTapBrowse() {
    if (_selectedTab == EnumLikeType.book) {
      return Beamer.of(context, root: true).beamToNamed("books/");
    }

    return Beamer.of(context, root: true).beamToNamed("illustrations/");
  }

  void onTapIllustration(Illustration illustration) {
    NavigationStateHelper.illustration = illustration;
    Beamer.of(context, root: true).beamToNamed(
      "illustrations/${illustration.id}",
      data: {
        "illustrationId": illustration.id,
      },
    );
  }

  void onUnlikeBook(Book book, int index) {
    return tryUnLikeBook(book, index);
  }

  void onUnlikeIllustration(Illustration illustration, int index) {
    return tryUnLikeIllustration(illustration, index);
  }

  void tryUnLikeBook(Book book, int index) async {
    setState(() {
      _likedBooks.removeAt(index);
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
        _likedBooks.insert(index, book);
      });
    }
  }

  void tryUnLikeIllustration(Illustration illustration, int index) async {
    setState(() {
      _likedIllustrations.removeAt(index);
    });

    try {
      final String? userId = ref.read(AppState.userProvider).firestoreUser?.id;
      await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("user_likes")
          .doc(illustration.id)
          .delete();
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
      setState(() {
        _likedIllustrations.insert(index, illustration);
      });
    }
  }
}
