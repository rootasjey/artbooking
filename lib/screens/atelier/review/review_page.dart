import 'package:artbooking/actions/books.dart';
import 'package:artbooking/actions/illustrations.dart';
import 'package:artbooking/components/application_bar/application_bar.dart';
import 'package:artbooking/components/custom_scroll_behavior.dart';
import 'package:artbooking/components/popup_menu/popup_menu_icon.dart';
import 'package:artbooking/components/popup_menu/popup_menu_item_icon.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/router/navigation_state_helper.dart';
import 'package:artbooking/screens/atelier/review/review_page_body.dart';
import 'package:artbooking/screens/atelier/review/review_page_header.dart';
import 'package:artbooking/components/buttons/fab_to_top.dart';
import 'package:artbooking/types/book/book.dart';
import 'package:artbooking/types/book/popup_entry_book.dart';
import 'package:artbooking/types/cloud_functions/illustration_response.dart';
import 'package:artbooking/types/enums/enum_book_item_action.dart';
import 'package:artbooking/types/enums/enum_illustration_item_action.dart';
import 'package:artbooking/types/enums/enum_tab_data_type.dart';
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

/// Admins users can validate illustrations and books
/// to appear on the main page.
class ReviewPage extends ConsumerStatefulWidget {
  const ReviewPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ReviewPage> createState() => _LikesPageState();
}

class _LikesPageState extends ConsumerState<ReviewPage> {
  /// Order results from most recent or oldest.
  bool _descending = true;

  /// If true, there are more items (illustrations or books) to fetch.
  bool _hasNext = true;

  /// Hide items who has been explicitly disapproved if true.
  bool _hideDisapproved = false;

  /// Loading the current page if true.
  bool _loading = false;

  /// Loading the next page if true.
  bool _loadingMore = false;

  /// Show the page floating action button if true.
  bool _showFabToTop = false;

  /// Last fetched document snapshot. Used for pagination.
  DocumentSnapshot<Object>? _lastDocument;

  /// Last saved Y offset.
  /// Used while scrolling to know the direction.
  double _previousOffset = 0.0;

  /// Selected tab showing data (books or illustrations).
  EnumTabDataType _selectedTab = EnumTabDataType.illustrations;

  /// Maximum items (illustrations or books) to fetch per page.
  final int _limit = 20;

  /// List of books to review.
  final List<Book> _books = [];

  /// List of llusttrations to review.
  final List<Illustration> _illustrations = [];

  /// Menu items for books.
  final List<PopupEntryBook> _bookPopupMenuEntries = [
    PopupMenuItemIcon(
      delay: Duration(milliseconds: 0),
      value: EnumBookItemAction.approve,
      icon: PopupMenuIcon(UniconsLine.check),
      textLabel: "approve".tr(),
    ),
    PopupMenuItemIcon(
      delay: Duration(milliseconds: 25),
      value: EnumBookItemAction.disapprove,
      icon: PopupMenuIcon(UniconsLine.times),
      textLabel: "disapprove".tr(),
    ),
  ];

  /// Menu items for illustrations.
  final List<PopupEntryIllustration> _illustrationPopupMenuEntries = [
    PopupMenuItemIcon(
      delay: Duration(milliseconds: 0),
      value: EnumIllustrationItemAction.approve,
      icon: PopupMenuIcon(UniconsLine.check),
      textLabel: "approve".tr(),
    ),
    PopupMenuItemIcon(
      delay: Duration(milliseconds: 25),
      value: EnumIllustrationItemAction.disapprove,
      icon: PopupMenuIcon(UniconsLine.times),
      textLabel: "disapprove".tr(),
    ),
  ];

  /// Collection subscription on books or illustrations
  /// according the current selected tab.
  QuerySnapshotStreamSubscription? _dataSubscription;

  /// Page scroll controller.
  final _pageScrollController = ScrollController();

  @override
  initState() {
    super.initState();
    loadPreferences();
    fetch();
  }

  @override
  void dispose() {
    _dataSubscription?.cancel();
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
        onScroll: onPageScroll,
        child: ScrollConfiguration(
          behavior: CustomScrollBehavior(),
          child: CustomScrollView(
            controller: _pageScrollController,
            slivers: <Widget>[
              ApplicationBar(
                bottom: PreferredSize(
                  child: ReviewPageHeader(
                    isMobileSize: isMobileSize,
                    hideDisapproved: _hideDisapproved,
                    onChangedTab: onChangedTab,
                    onToggleShowDisapproved: onToggleShowDisapproved,
                    selectedTab: _selectedTab,
                  ),
                  preferredSize: Size.fromHeight(120.0),
                ),
                pinned: false,
              ),
              ReviewPageBody(
                books: _books,
                bookPopupMenuEntries: _bookPopupMenuEntries,
                illustrations: _illustrations,
                illustrationPopupMenuEntries: _illustrationPopupMenuEntries,
                isMobileSize: isMobileSize,
                loading: _loading,
                onTapBook: onTapBook,
                onTapIllustration: onTapIllustration,
                onApproveBook: onApproveBook,
                onApproveIllustration: onApproveIllustration,
                onPopupMenuBookSelected: onPopupMenuBookSelected,
                onPopupMenuIllustrationSelected:
                    onPopupMenuIllustrationSelected,
                selectedTab: _selectedTab,
              )
            ],
          ),
        ),
      ),
    );
  }

  /// Fetch books or illustrations on Firestore.
  void fetch() async {
    setState(() {
      _lastDocument = null;
      _loading = true;
    });

    if (_selectedTab == EnumTabDataType.books) {
      return fetchBooks();
    }

    return fetchIllustrations();
  }

  void fetchBooks() async {
    _books.clear();
    _hasNext = true;

    try {
      QueryMap query = FirebaseFirestore.instance
          .collection("books")
          .where("visibility", isEqualTo: "public")
          .where("staff_review.approved", isEqualTo: false)
          .orderBy("created_at", descending: _descending)
          .limit(_limit);

      if (_hideDisapproved) {
        query = query.where("staff_review.user_id", isEqualTo: "");
      }

      final QuerySnapMap snapshot = await query.get();
      if (snapshot.docs.isEmpty) {
        _hasNext = false;
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
          _books.add(Book.fromMap(bookData));
        }
      }

      _lastDocument = snapshot.docs.last;
      _hasNext = snapshot.size == _limit;

      listenDataEvents(getListenQuery());
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void fetchIllustrations() async {
    _illustrations.clear();
    _hasNext = true;

    try {
      QueryMap query = FirebaseFirestore.instance
          .collection("illustrations")
          .where("visibility", isEqualTo: "public")
          .where("staff_review.approved", isEqualTo: false)
          .orderBy("created_at", descending: _descending)
          .limit(_limit);

      if (_hideDisapproved) {
        query = query.where("staff_review.user_id", isEqualTo: "");
      }

      final QuerySnapMap snapshot = await query.get();
      if (snapshot.docs.isEmpty) {
        _hasNext = false;
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
          _illustrations.add(Illustration.fromMap(illustrationData));
        }
      }

      _lastDocument = snapshot.docs.last;
      _hasNext = snapshot.size == _limit;

      listenDataEvents(getListenQuery());
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    } finally {
      setState(() => _loading = false);
    }
  }

  void fetchMore() {
    if (_selectedTab == EnumTabDataType.books) {
      return fetchMoreBooks();
    }

    return fetchMoreIllustrations();
  }

  void fetchMoreBooks() async {
    final DocumentSnapshot? lastDocumentSnapshot = _lastDocument;
    if (lastDocumentSnapshot == null) {
      return;
    }

    _loadingMore = true;

    try {
      QueryMap query = FirebaseFirestore.instance
          .collection("books")
          .where("visibility", isEqualTo: "public")
          .where("staff_review.approved", isEqualTo: false)
          .orderBy("created_at", descending: _descending)
          .startAfterDocument(lastDocumentSnapshot)
          .limit(_limit);

      if (_hideDisapproved) {
        query = query.where("staff_review.user_id", isEqualTo: "");
      }

      final QuerySnapMap snapshot = await query.get();
      if (snapshot.docs.isEmpty) {
        _hasNext = false;
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
          _books.add(Book.fromMap(bookData));
        }
      }

      _lastDocument = snapshot.docs.last;
      _hasNext = snapshot.size == _limit;

      listenDataEvents(getListenQuery());
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    } finally {
      setState(() {
        _loadingMore = false;
      });
    }
  }

  void fetchMoreIllustrations() async {
    final DocumentSnapshot? lastDocumentSnapshot = _lastDocument;
    if (lastDocumentSnapshot == null) {
      return;
    }

    _loadingMore = true;

    try {
      Query<Map<String, dynamic>> query = FirebaseFirestore.instance
          .collection("illustrations")
          .where("visibility", isEqualTo: "public")
          .where("staff_review.approved", isEqualTo: false)
          .orderBy("created_at", descending: _descending)
          .startAfterDocument(lastDocumentSnapshot)
          .limit(_limit);

      if (_hideDisapproved) {
        query = query.where("staff_review.user_id", isEqualTo: "");
      }

      final QuerySnapMap snapshot = await query.get();
      if (snapshot.docs.isEmpty) {
        _hasNext = false;
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
          _illustrations.add(Illustration.fromMap(illustrationData));
        }
      }

      _lastDocument = snapshot.docs.last;
      _hasNext = snapshot.size == _limit;

      listenDataEvents(getListenQuery());
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    } finally {
      setState(() {
        _loadingMore = false;
      });
    }
  }

  /// Return the query to listen changes to.
  QueryMap? getListenQuery() {
    final DocumentSnapshot? lastDocument = _lastDocument;
    if (lastDocument == null) {
      return null;
    }

    if (_selectedTab == EnumTabDataType.books) {
      QueryMap query = FirebaseFirestore.instance
          .collection("books")
          .where("visibility", isEqualTo: "public")
          .where("staff_review.approved", isEqualTo: false)
          .orderBy("created_at", descending: _descending)
          .endAtDocument(lastDocument);

      if (_hideDisapproved) {
        query = query.where("staff_review.user_id", isEqualTo: "");
      }

      return query;
    }

    QueryMap query = FirebaseFirestore.instance
        .collection("illustrations")
        .where("visibility", isEqualTo: "public")
        .where("staff_review.approved", isEqualTo: false)
        .orderBy("created_at", descending: _descending)
        .endAtDocument(lastDocument);

    if (_hideDisapproved) {
      query = query.where("staff_review.user_id", isEqualTo: "");
    }

    return query;
  }

  void loadPreferences() {
    _selectedTab = Utilities.storage.getReviewTab();
    _hideDisapproved = Utilities.storage.getReviewHideDisapproved();
  }

  void onChangedTab(EnumTabDataType reviewTabDataType) {
    setState(() => _selectedTab = reviewTabDataType);
    fetch();

    Utilities.storage.saveReviewTab(reviewTabDataType);
  }

  /// Listen to the last Firestore query of this page.
  void listenDataEvents(QueryMap? query) {
    if (query == null) {
      return;
    }

    _dataSubscription?.cancel();
    _dataSubscription = query.snapshots().skip(1).listen(
      (snapshot) {
        for (DocumentChangeMap documentChange in snapshot.docChanges) {
          switch (documentChange.type) {
            case DocumentChangeType.added:
              onAddStreamingItem(documentChange);
              break;
            case DocumentChangeType.removed:
              onRemoveStreamingItem(documentChange);
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

  void maybeFetchMore(double offset) {
    if (_pageScrollController.position.atEdge &&
        offset > 50 &&
        _hasNext &&
        !_loadingMore) {
      fetchMore();
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

  /// Fire when a new document has been created in Firestore.
  /// Add the corresponding document in the UI.
  void onAddStreamingItem(DocumentChangeMap documentChange) {
    final Json? data = documentChange.doc.data();
    if (data == null) {
      return;
    }

    if (_selectedTab == EnumTabDataType.books) {
      return onAddStreamingIllustration(documentChange);
    }

    return onAddStreamingBook(documentChange);
  }

  void onAddStreamingIllustration(DocumentChangeMap documentChange) async {
    final Json? data = documentChange.doc.data();
    if (data == null) {
      return;
    }

    setState(() {
      data["id"] = documentChange.doc.id;

      final illustration = Illustration.fromMap(data);
      _illustrations.insert(0, illustration);
    });
  }

  void onAddStreamingBook(DocumentChangeMap documentChange) async {
    final Json? data = documentChange.doc.data();
    if (data == null) {
      return;
    }

    setState(() {
      data["id"] = documentChange.doc.id;
      final book = Book.fromMap(data);
      _books.insert(0, book);
    });
  }

  void onPopupMenuBookSelected(
    EnumBookItemAction action,
    int index,
    Book book,
  ) {
    switch (action) {
      case EnumBookItemAction.approve:
        onApproveBook(book, index);
        break;
      case EnumBookItemAction.disapprove:
        onDisapproveBook(book, index);
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
      case EnumIllustrationItemAction.approve:
        onApproveIllustration(illustration, index);
        break;
      case EnumIllustrationItemAction.disapprove:
        onDisapproveIllustration(illustration, index);
        break;
      default:
    }
  }

  /// Fire when a new document has been delete from Firestore.
  /// Delete the corresponding document from the UI.
  void onRemoveStreamingItem(DocumentChangeMap documentChange) {
    if (_selectedTab == EnumTabDataType.books) {
      setState(() {
        _books.removeWhere((x) => x.id == documentChange.doc.id);
      });
      return;
    }

    setState(() {
      _illustrations.removeWhere((x) => x.id == documentChange.doc.id);
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

  void onTapIllustration(Illustration illustration) {
    NavigationStateHelper.illustration = illustration;
    Beamer.of(context, root: true).beamToNamed(
      "illustrations/${illustration.id}",
      data: {
        "illustrationId": illustration.id,
      },
    );
  }

  void onApproveBook(Book book, int index) async {
    setState(() => _books.removeAt(index));

    final response = await BooksActions.approve(
      bookId: book.id,
      approved: true,
    );

    if (response.success) {
      return;
    }

    setState(() {
      _books.insert(index, book);
    });
  }

  void onDisapproveBook(Book book, int index) async {
    if (_hideDisapproved) {
      setState(() => _books.removeAt(index));
    }

    final response = await BooksActions.approve(
      bookId: book.id,
      approved: false,
    );

    if (response.success) {
      return;
    }

    if (_hideDisapproved) {
      setState(() => _books.insert(index, book));
    }
  }

  void onApproveIllustration(Illustration illustration, int index) async {
    setState(() => _illustrations.removeAt(index));

    final IllustrationResponse response = await IllustrationsActions.approve(
      illustrationId: illustration.id,
      approved: true,
    );

    if (response.success) {
      return;
    }

    setState(() => _illustrations.insert(index, illustration));
  }

  void onDisapproveIllustration(Illustration illustration, int index) async {
    if (_hideDisapproved) {
      setState(() => _illustrations.removeAt(index));
    }

    final IllustrationResponse response = await IllustrationsActions.approve(
      illustrationId: illustration.id,
      approved: false,
    );

    if (response.success) {
      return;
    }

    if (_hideDisapproved) {
      setState(() => _illustrations.insert(index, illustration));
    }
  }

  /// Callback when the page scrolls up and down.
  void onPageScroll(double offset) {
    maybeShowFab(offset);
    maybeFetchMore(offset);
  }

  void onToggleShowDisapproved() {
    setState(() => _hideDisapproved = !_hideDisapproved);
    fetch();

    Utilities.storage.saveReviewHideDisapproved(_hideDisapproved);
  }
}
