import 'package:artbooking/actions/books.dart';
import 'package:artbooking/actions/illustrations.dart';
import 'package:artbooking/components/application_bar/application_bar.dart';
import 'package:artbooking/components/custom_scroll_behavior.dart';
import 'package:artbooking/components/popup_menu/popup_menu_item_icon.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/router/navigation_state_helper.dart';
import 'package:artbooking/screens/atelier/review/review_page_body.dart';
import 'package:artbooking/screens/atelier/review/review_page_header.dart';
import 'package:artbooking/screens/likes/likes_page_fab.dart';
import 'package:artbooking/types/book/book.dart';
import 'package:artbooking/types/enums/enum_book_item_action.dart';
import 'package:artbooking/types/enums/enum_illustration_item_action.dart';
import 'package:artbooking/types/enums/enum_tab_data_type.dart';
import 'package:artbooking/types/firestore/document_change_map.dart';
import 'package:artbooking/types/firestore/query_map.dart';
import 'package:artbooking/types/firestore/query_snapshot_stream_subscription.dart';
import 'package:artbooking/types/illustration/illustration.dart';
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
  /// True if there're more data to fetch.
  bool _hasNext = true;

  /// True if loading more style from Firestore.
  bool _loadingMore = false;

  bool _descending = true;
  bool _loading = false;
  bool _showFab = false;
  bool _hideDisapproved = false;

  /// Last fetched document snapshot. Used for pagination.
  DocumentSnapshot<Object>? _lastDocumentSnapshot;

  /// Illusttrations to review.
  final List<Illustration> _illustrations = [];

  /// Books  to review.
  final List<Book> _books = [];

  /// Maximum licenses to fetch in one request.
  int _limit = 20;

  /// Collection subscription on books or illustrations
  /// according the current selected tab.
  QuerySnapshotStreamSubscription? _dataSubscription;

  /// Selected tab showing data (books or illustrations).
  var _selectedTab = EnumTabDataType.illustrations;

  /// Items when opening the popup.
  final List<PopupMenuEntry<EnumIllustrationItemAction>>
      _illustrationPopupMenuEntries = [
    PopupMenuItemIcon(
      value: EnumIllustrationItemAction.approve,
      icon: Icon(UniconsLine.check),
      textLabel: "approve".tr(),
    ),
    PopupMenuItemIcon(
      value: EnumIllustrationItemAction.disapprove,
      icon: Icon(UniconsLine.times),
      textLabel: "disapprove".tr(),
    ),
  ];

  /// Items when opening the popup.
  final List<PopupMenuEntry<EnumBookItemAction>> _bookPopupMenuEntries = [
    PopupMenuItemIcon(
      value: EnumBookItemAction.approve,
      icon: Icon(UniconsLine.check),
      textLabel: "approve".tr(),
    ),
    PopupMenuItemIcon(
      value: EnumBookItemAction.disapprove,
      icon: Icon(UniconsLine.times),
      textLabel: "disapprove".tr(),
    ),
  ];

  final _scrollController = ScrollController();

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
    return Scaffold(
      floatingActionButton: LikesPageFab(
        show: _showFab,
        scrollController: _scrollController,
      ),
      body: ImprovedScrolling(
        scrollController: _scrollController,
        enableKeyboardScrolling: true,
        onScroll: onScroll,
        child: ScrollConfiguration(
          behavior: CustomScrollBehavior(),
          child: CustomScrollView(
            controller: _scrollController,
            slivers: <Widget>[
              ApplicationBar(),
              ReviewPageHeader(
                selectedTab: _selectedTab,
                onChangedTab: onChangedTab,
                hideDisapproved: _hideDisapproved,
                onUpdateShowHidden: onUpdateShowHidden,
              ),
              ReviewPageBody(
                loading: _loading,
                books: _books,
                selectedTab: _selectedTab,
                illustrations: _illustrations,
                bookPopupMenuEntries: _bookPopupMenuEntries,
                illustrationPopupMenuEntries: _illustrationPopupMenuEntries,
                onTapBook: onTapBook,
                onTapIllustration: onTapIllustration,
                onApproveBook: onApproveBook,
                onApproveIllustration: onApproveIllustration,
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

  /// Fetch books or illustrations on Firestore.
  void fetch() async {
    _dataSubscription?.cancel();

    setState(() {
      _lastDocumentSnapshot = null;
      _loading = true;
    });

    if (_selectedTab == EnumTabDataType.books) {
      return fetchBooks();
    }

    return fetchIllustrations();
  }

  void fetchMore() {
    if (_selectedTab == EnumTabDataType.books) {
      return fetchMoreBooks();
    }

    return fetchMoreIllustrations();
  }

  void fetchIllustrations() async {
    _illustrations.clear();
    _hasNext = true;

    try {
      Query<Map<String, dynamic>> query = FirebaseFirestore.instance
          .collection("illustrations")
          .where("visibility", isEqualTo: "public")
          .where("staff_review.approved", isEqualTo: false)
          .orderBy("created_at", descending: _descending)
          .limit(_limit);

      if (_hideDisapproved) {
        query = query.where("staff_review.user_id", isEqualTo: "");
      }

      final snapshot = await query.get();
      if (snapshot.docs.isEmpty) {
        _hasNext = false;
        return;
      }

      for (var document in snapshot.docs) {
        final illustrationSnapshot = await FirebaseFirestore.instance
            .collection("illustrations")
            .doc(document.id)
            .get();

        final illustrationData = illustrationSnapshot.data();
        if (illustrationData != null) {
          illustrationData["id"] = illustrationSnapshot.id;
          _illustrations.add(Illustration.fromMap(illustrationData));
        }
      }

      _lastDocumentSnapshot = snapshot.docs.last;
      _hasNext = snapshot.size == _limit;
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void fetchMoreIllustrations() async {
    final lastDocumentSnapshot = _lastDocumentSnapshot;
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

      final snapshot = await query.get();
      if (snapshot.docs.isEmpty) {
        _hasNext = false;
        return;
      }

      for (var document in snapshot.docs) {
        final illustrationSnapshot = await FirebaseFirestore.instance
            .collection("illustrations")
            .doc(document.id)
            .get();

        final illustrationData = illustrationSnapshot.data();
        if (illustrationData != null) {
          illustrationData["id"] = illustrationSnapshot.id;
          _illustrations.add(Illustration.fromMap(illustrationData));
        }
      }

      _lastDocumentSnapshot = snapshot.docs.last;
      _hasNext = snapshot.size == _limit;
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    } finally {
      setState(() {
        _loadingMore = false;
      });
    }
  }

  void fetchBooks() async {
    _books.clear();
    _hasNext = true;

    try {
      Query<Map<String, dynamic>> query = FirebaseFirestore.instance
          .collection("books")
          .where("visibility", isEqualTo: "public")
          .where("staff_review.approved", isEqualTo: false)
          .orderBy("created_at", descending: _descending)
          .limit(_limit);

      if (_hideDisapproved) {
        query = query.where("staff_review.user_id", isEqualTo: "");
      }

      final snapshot = await query.get();
      if (snapshot.docs.isEmpty) {
        _hasNext = false;
        return;
      }

      for (var document in snapshot.docs) {
        final bookSnapshot = await FirebaseFirestore.instance
            .collection("books")
            .doc(document.id)
            .get();

        final bookData = bookSnapshot.data();
        if (bookData != null) {
          bookData["id"] = bookSnapshot.id;
          _books.add(Book.fromMap(bookData));
        }
      }

      _lastDocumentSnapshot = snapshot.docs.last;
      _hasNext = snapshot.size == _limit;
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void fetchMoreBooks() async {
    final lastDocumentSnapshot = _lastDocumentSnapshot;
    if (lastDocumentSnapshot == null) {
      return;
    }

    _loadingMore = true;

    try {
      Query<Map<String, dynamic>> query = FirebaseFirestore.instance
          .collection("books")
          .where("visibility", isEqualTo: "public")
          .where("staff_review.approved", isEqualTo: false)
          .orderBy("created_at", descending: _descending)
          .startAfterDocument(lastDocumentSnapshot)
          .limit(_limit);

      if (_hideDisapproved) {
        query = query.where("staff_review.user_id", isEqualTo: "");
      }

      final snapshot = await query.get();
      if (snapshot.docs.isEmpty) {
        _hasNext = false;
        return;
      }

      for (var document in snapshot.docs) {
        final bookSnapshot = await FirebaseFirestore.instance
            .collection("books")
            .doc(document.id)
            .get();

        final bookData = bookSnapshot.data();
        if (bookData != null) {
          bookData["id"] = bookSnapshot.id;
          _books.add(Book.fromMap(bookData));
        }
      }

      _lastDocumentSnapshot = snapshot.docs.last;
      _hasNext = snapshot.size == _limit;
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    } finally {
      setState(() {
        _loadingMore = false;
      });
    }
  }

  void loadPreferences() {
    _selectedTab = Utilities.storage.getReviewTab();
    _hideDisapproved = Utilities.storage.getReviewHideDisapproved();
  }

  void onChangedTab(EnumTabDataType reviewTabDataType) {
    setState(() {
      _selectedTab = reviewTabDataType;
    });

    fetch();
    Utilities.storage.saveReviewTab(reviewTabDataType);
  }

  /// Listen to the last Firestore query of this page.
  void listenDataEvents(QueryMap query) {
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

  /// Fire when a new document has been created in Firestore.
  /// Add the corresponding document in the UI.
  void onAddStreamingItem(DocumentChangeMap documentChange) {
    final data = documentChange.doc.data();
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
    setState(() {
      _books.removeAt(index);
    });

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
    Utilities.logger.i(book.id);
    if (_hideDisapproved) {
      setState(() {
        _books.removeAt(index);
      });
    }

    final response = await BooksActions.approve(
      bookId: book.id,
      approved: false,
    );

    if (response.success) {
      return;
    }

    if (_hideDisapproved) {
      setState(() {
        _books.insert(index, book);
      });
    }
  }

  void onApproveIllustration(Illustration illustration, int index) async {
    setState(() {
      _illustrations.removeAt(index);
    });

    final response = await IllustrationsActions.approve(
      illustrationId: illustration.id,
      approved: true,
    );

    if (response.success) {
      return;
    }

    setState(() {
      _illustrations.insert(index, illustration);
    });
  }

  void onDisapproveIllustration(Illustration illustration, int index) async {
    if (_hideDisapproved) {
      setState(() {
        _illustrations.removeAt(index);
      });
    }

    final response = await IllustrationsActions.approve(
      illustrationId: illustration.id,
      approved: false,
    );

    if (response.success) {
      return;
    }

    if (_hideDisapproved) {
      setState(() {
        _illustrations.insert(index, illustration);
      });
    }
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
      fetchMore();
    }
  }

  void onUpdateShowHidden() {
    setState(() {
      _hideDisapproved = !_hideDisapproved;
    });

    Utilities.storage.saveReviewHideDisapproved(_hideDisapproved);
    fetch();
  }
}
