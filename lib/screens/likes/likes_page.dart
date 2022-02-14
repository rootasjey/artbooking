import 'package:artbooking/components/application_bar/application_bar.dart';
import 'package:artbooking/components/popup_menu/popup_menu_item_icon.dart';
import 'package:artbooking/globals/app_state.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/router/navigation_state_helper.dart';
import 'package:artbooking/screens/likes/likes_page_body.dart';
import 'package:artbooking/screens/likes/likes_page_fab.dart';
import 'package:artbooking/screens/likes/likes_page_header.dart';
import 'package:artbooking/types/book/book.dart';
import 'package:artbooking/types/enums/enum_book_item_action.dart';
import 'package:artbooking/types/enums/enum_illustration_item_action.dart';
import 'package:artbooking/types/enums/enum_like_type.dart';
import 'package:artbooking/types/firestore/document_change_map.dart';
import 'package:artbooking/types/firestore/query_map.dart';
import 'package:artbooking/types/firestore/query_snapshot_stream_subscription.dart';
import 'package:artbooking/types/illustration/illustration.dart';
import 'package:beamer/beamer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicons/unicons.dart';

class LikesPage extends ConsumerStatefulWidget {
  const LikesPage({Key? key}) : super(key: key);

  @override
  ConsumerState<LikesPage> createState() => _LikesPageState();
}

class _LikesPageState extends ConsumerState<LikesPage> {
  /// True if there're more data to fetch.
  bool _hasNext = true;

  /// True if loading more style from Firestore.
  bool _isLoadingMore = false;

  bool _descending = true;
  bool _loading = false;
  bool _showFab = false;

  /// Last fetched document snapshot. Used for pagination.
  DocumentSnapshot<Object>? _lastDocumentSnapshot;

  final List<Illustration> _likedIllustrations = [];
  final List<Book> _likedBooks = [];

  /// Maximum licenses to fetch in one request.
  int _limit = 20;

  QuerySnapshotStreamSubscription? _likeSubscription;

  /// Selected tab to show license (staff or user).
  var _selectedTab = EnumLikeType.illustration;

  /// Items when opening the popup.
  final List<PopupMenuEntry<EnumIllustrationItemAction>>
      _illustrationPopupMenuEntries = [
    PopupMenuItemIcon(
      value: EnumIllustrationItemAction.unlike,
      icon: Icon(UniconsLine.heart_break),
      textLabel: "unlike".tr(),
    ),
  ];

  /// Items when opening the popup.
  final List<PopupMenuEntry<EnumBookItemAction>> _bookPopupMenuEntries = [
    PopupMenuItemIcon(
      value: EnumBookItemAction.unlike,
      icon: Icon(UniconsLine.heart_break),
      textLabel: "unlike".tr(),
    ),
  ];

  final _scrollController = ScrollController();

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
    return Scaffold(
      floatingActionButton: LikesPageFab(
        show: _showFab,
        scrollController: _scrollController,
      ),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: <Widget>[
          ApplicationBar(),
          LikesPageHeader(
            selectedTab: _selectedTab,
            onChangedTab: onChangedTab,
          ),
          LikesPageBody(
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
            onPopupMenuIllustrationSelected: onPopupMenuIllustrationSelected,
          )
        ],
      ),
    );
  }

  /// Fetch staff license on Firestore.
  void fetchLikes() async {
    _likeSubscription?.cancel();

    setState(() {
      _lastDocumentSnapshot = null;
      _loading = true;
    });

    if (_selectedTab == EnumLikeType.book) {
      return fetchLikedBooks();
    }

    return fetchLikedIllustrations();
  }

  void fetchMoreLikes() {
    if (_selectedTab == EnumLikeType.book) {
      return fetchMoreLikedBooks();
    }

    return fetchMoreLikedIllustrations();
  }

  void fetchLikedIllustrations() async {
    final String? userId = ref.read(AppState.userProvider).firestoreUser?.id;
    if (userId == null) {
      return;
    }

    _likedIllustrations.clear();

    try {
      final query = FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("user_likes")
          .where("type", isEqualTo: "illustration")
          .orderBy("created_at", descending: _descending)
          .limit(_limit);

      final snapshot = await query.get();
      if (snapshot.docs.isEmpty) {
        return;
      }

      for (var document in snapshot.docs) {
        final illustrationSnapshot = await FirebaseFirestore.instance
            .collection("illustrations")
            .doc(document.id)
            .get();

        final illustrationData = illustrationSnapshot.data();
        if (illustrationData != null) {
          illustrationData['id'] = illustrationSnapshot.id;
          illustrationData['liked'] = true;
          _likedIllustrations.add(Illustration.fromMap(illustrationData));
        }
      }

      _lastDocumentSnapshot = snapshot.docs.last;
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void fetchMoreLikedIllustrations() async {
    final lastDocumentSnapshot = _lastDocumentSnapshot;
    if (lastDocumentSnapshot == null) {
      return;
    }

    final String? userId = ref.read(AppState.userProvider).firestoreUser?.id;
    if (userId == null) {
      return;
    }

    try {
      final query = FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("user_likes")
          .where("type", isEqualTo: "illustration")
          .orderBy("created_at", descending: _descending)
          .startAfterDocument(lastDocumentSnapshot)
          .limit(_limit);

      final snapshot = await query.get();
      if (snapshot.docs.isEmpty) {
        return;
      }

      for (var document in snapshot.docs) {
        final illustrationSnapshot = await FirebaseFirestore.instance
            .collection("illustrations")
            .doc(document.id)
            .get();

        final illustrationData = illustrationSnapshot.data();
        if (illustrationData != null) {
          illustrationData['id'] = illustrationSnapshot.id;
          illustrationData['liked'] = true;
          _likedIllustrations.add(Illustration.fromMap(illustrationData));
        }
      }

      _lastDocumentSnapshot = snapshot.docs.last;
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void fetchLikedBooks() async {
    final String? userId = ref.read(AppState.userProvider).firestoreUser?.id;
    if (userId == null) {
      return;
    }

    _likedBooks.clear();

    try {
      final query = FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("user_likes")
          .where("type", isEqualTo: "book")
          .orderBy("created_at", descending: _descending)
          .limit(_limit);

      final snapshot = await query.get();
      if (snapshot.docs.isEmpty) {
        return;
      }

      for (var document in snapshot.docs) {
        final bookSnapshot = await FirebaseFirestore.instance
            .collection("books")
            .doc(document.id)
            .get();

        final bookData = bookSnapshot.data();
        if (bookData != null) {
          bookData['id'] = bookSnapshot.id;
          bookData['liked'] = true;
          _likedBooks.add(Book.fromMap(bookData));
        }
      }

      _lastDocumentSnapshot = snapshot.docs.last;
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void fetchMoreLikedBooks() async {
    final lastDocumentSnapshot = _lastDocumentSnapshot;
    if (lastDocumentSnapshot == null) {
      return;
    }

    final String? userId = ref.read(AppState.userProvider).firestoreUser?.id;
    if (userId == null) {
      return;
    }

    try {
      final query = FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("user_likes")
          .where("type", isEqualTo: "book")
          .orderBy("created_at", descending: _descending)
          .startAfterDocument(lastDocumentSnapshot)
          .limit(_limit);

      final snapshot = await query.get();
      if (snapshot.docs.isEmpty) {
        return;
      }

      for (var document in snapshot.docs) {
        final bookSnapshot = await FirebaseFirestore.instance
            .collection("books")
            .doc(document.id)
            .get();

        final bookData = bookSnapshot.data();
        if (bookData != null) {
          bookData['id'] = bookSnapshot.id;
          bookData['liked'] = true;
          _likedBooks.add(Book.fromMap(bookData));
        }
      }

      _lastDocumentSnapshot = snapshot.docs.last;
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void loadPreferences() {
    _selectedTab = Utilities.storage.getLikeTab();
  }

  void onChangedTab(EnumLikeType likeType) {
    setState(() {
      _selectedTab = likeType;
    });

    fetchLikes();
    Utilities.storage.saveLikeTab(likeType);
  }

  /// On scroll notification
  bool onNotification(ScrollNotification notification) {
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

    if (_hasNext && !_isLoadingMore && _lastDocumentSnapshot != null) {
      fetchMoreLikes();
    }

    return false;
  }

  /// Listen to the last Firestore query of this page.
  void listenLikeEvents(QueryMap query) {
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
