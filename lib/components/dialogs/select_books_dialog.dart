import 'package:artbooking/components/buttons/dark_elevated_button.dart';
import 'package:artbooking/components/dialogs/themed_dialog.dart';
import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/book/book.dart';
import 'package:artbooking/types/firestore/query_doc_snap_map.dart';
import 'package:artbooking/types/json_types.dart';
import 'package:beamer/beamer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flash/src/flash_helper.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:unicons/unicons.dart';

/// Add a group of illustrations to one or more books.
class SelectBooksDialog extends StatefulWidget {
  SelectBooksDialog({
    required this.userId,
    this.admin = false,
    this.autoFocus = false,
    this.maxPick = 6,
    this.onComplete,
    this.onValidate,
  });

  final bool autoFocus;

  /// If true, show all approved books in dialog.
  final bool admin;

  /// When the operation complete (illustrations has been added to books).
  final void Function()? onComplete;

  /// Callback containing selected book ids.
  final void Function(List<String>)? onValidate;

  /// Maximum number of illustrations that can be choosen.
  final int maxPick;

  /// Current authenticated user's id.
  final String userId;

  @override
  _SelectBooksDialogState createState() => _SelectBooksDialogState();
}

class _SelectBooksDialogState extends State<SelectBooksDialog> {
  /// True if there's a next page (data) to fetch.
  bool _hasNext = false;

  /// If true, this widget is fetching data.
  bool _loading = false;

  /// True if this widget is fetching data after initial fetch.
  bool _loadingMore = false;

  /// Order data result from the most recent to the oldest.
  bool _descending = true;

  /// Last fetched document.
  DocumentSnapshot? _lastDocument;

  /// Maximum documents to fetch in a page.
  final int _limit = 20;

  /// List of books owned by the current authenticated user.
  List<Book> _books = [];

  /// Map to follow selected books.
  final Map<String, bool> _selectedBookIds = Map();

  /// Page's scroll controller.
  final ScrollController _pageScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchBooks();
  }

  @override
  void dispose() {
    _pageScrollController.dispose();
    _lastDocument = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _onValidate =
        _loading || _selectedBookIds.isEmpty ? null : onValidate;

    return ThemedDialog(
      autofocus: widget.autoFocus,
      useRawDialog: true,
      title: Column(
        children: [
          Opacity(
            opacity: 0.8,
            child: Text(
              "books".tr().toUpperCase(),
              style: Utilities.fonts.body(
                color: Colors.black,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Opacity(
              opacity: 0.4,
              child: Text(
                "books_choose_add_illustration_in".plural(2),
                textAlign: TextAlign.center,
                style: Utilities.fonts.body(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
      body: body(),
      textButtonValidation: "books_add_to".plural(_selectedBookIds.length),
      footer: footer(),
      onCancel: Beamer.of(context).popRoute,
      onValidate: _onValidate,
    );
  }

  Widget body() {
    if (_loading) {
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(26.0),
          child: Column(
            children: [
              Opacity(
                opacity: 0.8,
                child: Text(
                  "loading".tr(),
                  style: Utilities.fonts.body(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              LinearProgressIndicator(),
            ],
          ),
        ),
      );
    }

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: 430.0,
        maxWidth: 400.0,
      ),
      child: NotificationListener<ScrollNotification>(
        onNotification: onScrollNotification,
        child: CustomScrollView(
          controller: _pageScrollController,
          slivers: [
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final book = _books.elementAt(index);
                  return bookTile(book);
                },
                childCount: _books.length,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget bookTile(Book book) {
    String updatedAt = "";

    if (DateTime.now().difference(book.updatedAt).inDays > 60) {
      updatedAt = "date_updated_on".tr(
        args: [Jiffy(book.updatedAt).yMMMMEEEEd],
      ).toLowerCase();
    } else {
      updatedAt = "date_updated_ago".tr(
        args: [Jiffy(book.updatedAt).fromNow()],
      ).toLowerCase();
    }

    final double cardWidth = 100.0;
    final double cardHeight = 100.0;

    final bool selected = _selectedBookIds.containsKey(book.id);
    final Color primaryColor = Theme.of(context).primaryColor;
    final BorderSide borderSide = selected
        ? BorderSide(color: primaryColor, width: 2.0)
        : BorderSide.none;

    final Color? textColor = selected ? Colors.white : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: cardHeight,
                width: cardWidth,
                child: Card(
                  elevation: 3.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    side: borderSide,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Ink.image(
                    image: NetworkImage(book.getCoverLink()),
                    width: cardWidth,
                    height: cardHeight,
                    fit: BoxFit.cover,
                    child: InkWell(
                      onTap: () => onTapBook(book),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4.0, right: 12.0),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8.0),
                    onTap: () => onTapBook(book),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Container(
                        color: selected ? primaryColor : null,
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Opacity(
                              opacity: 0.8,
                              child: Text(
                                book.name,
                                maxLines: 1,
                                style: Utilities.fonts.body(
                                  color: textColor,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            Opacity(
                              opacity: 0.4,
                              child: Text(
                                book.description,
                                maxLines: 1,
                                style: Utilities.fonts.body(
                                  color: textColor,
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Opacity(
                              opacity: 0.6,
                              child: Text(
                                "illustrations_count".plural(book.count),
                                maxLines: 1,
                                style: Utilities.fonts.body(
                                  color: textColor,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Opacity(
                              opacity: 0.3,
                              child: Text(
                                updatedAt,
                                maxLines: 1,
                                style: Utilities.fonts.body(
                                  color: textColor,
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (selected)
            Positioned(
              right: 18.0,
              top: 0.0,
              bottom: 0.0,
              child: Icon(
                UniconsLine.check_circle,
                color: textColor,
              ),
            ),
        ],
      ),
    );
  }

  Widget footer() {
    final bool selectedEmpty = _selectedBookIds.isEmpty;
    final Function()? _onValidate =
        _loading || selectedEmpty ? null : onValidate;

    Widget child = Container();

    if (_books.isEmpty) {
      child = Padding(
        padding: EdgeInsets.all(12.0),
        child: DarkElevatedButton.large(
          onPressed: Beamer.of(context).popRoute,
          child: Text("close".tr()),
        ),
      );
    } else {
      child = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.all(12.0),
            child: DarkElevatedButton.large(
              onPressed: _onValidate,
              child: Text(
                "books_select_count".plural(
                  _selectedBookIds.length,
                ),
              ),
            ),
          ),
          Tooltip(
            message: "clear_selection".tr(),
            child: DarkElevatedButton.iconOnly(
              color: Theme.of(context).secondaryHeaderColor.withOpacity(0.8),
              onPressed: selectedEmpty ? null : clearSelected,
              child: Icon(UniconsLine.ban),
            ),
          ),
        ],
      );
    }

    return Material(
      color: Constants.colors.clairPink,
      child: child,
    );
  }

  void clearSelected() {
    setState(() {
      _selectedBookIds.clear();
    });
  }

  Query<Map<String, dynamic>> getFetchQuery() {
    if (widget.admin) {
      return FirebaseFirestore.instance
          .collection("books")
          .where("visibility", isEqualTo: "public")
          .where("staff_review.approved", isEqualTo: true)
          .orderBy("created_at", descending: _descending)
          .limit(_limit);
    }

    return FirebaseFirestore.instance
        .collection("books")
        .where("user_id", isEqualTo: widget.userId)
        .limit(_limit)
        .orderBy("updated_at", descending: _descending);
  }

  Query<Map<String, dynamic>> getFetchMoreQuery(
    DocumentSnapshot<Object?> lastDocument,
  ) {
    if (widget.admin) {
      return FirebaseFirestore.instance
          .collection("books")
          .where("visibility", isEqualTo: "public")
          .where("staff_review.approved", isEqualTo: true)
          .orderBy("created_at", descending: _descending)
          .startAfterDocument(lastDocument)
          .limit(_limit);
    }

    return FirebaseFirestore.instance
        .collection("books")
        .where("user_id", isEqualTo: widget.userId)
        .limit(_limit)
        .orderBy("updated_at", descending: _descending)
        .startAfterDocument(lastDocument);
  }

  Future fetchBooks() async {
    _books.clear();
    setState(() => _loading = true);

    try {
      final query = getFetchQuery();
      final snapshot = await query.get();

      if (snapshot.docs.isEmpty) {
        _hasNext = false;
        return;
      }

      for (QueryDocSnapMap document in snapshot.docs) {
        final Json map = document.data();
        map['id'] = document.id;

        final Book book = Book.fromMap(map);
        _books.add(book);
      }

      _lastDocument = snapshot.docs.last;
      _hasNext = snapshot.docs.length == _limit;
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text("books_fetch_error".tr()));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future fetchMoreBooks() async {
    final lastDocument = _lastDocument;
    if (lastDocument == null || !_hasNext || _loadingMore) {
      return;
    }

    setState(() => _loadingMore = true);

    try {
      final query = getFetchMoreQuery(lastDocument);
      final snapshot = await query.get();

      if (snapshot.docs.isEmpty) {
        _hasNext = false;
        return;
      }

      for (QueryDocSnapMap document in snapshot.docs) {
        final Json map = document.data();
        map['id'] = document.id;

        final Book book = Book.fromMap(map);
        _books.add(book);
      }

      _lastDocument = snapshot.docs.last;
      _hasNext = snapshot.docs.length == _limit;
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text("books_fetch_more_error".tr()));
    } finally {
      setState(() => _loadingMore = false);
    }
  }

  bool onScrollNotification(ScrollNotification scrollNotif) {
    if (scrollNotif.metrics.pixels < scrollNotif.metrics.maxScrollExtent) {
      return false;
    }

    if (_hasNext && !_loadingMore) {
      fetchMoreBooks();
    }

    return false;
  }

  void onTapBook(Book book) {
    if (_selectedBookIds.containsKey(book.id)) {
      _selectedBookIds.remove(book.id);
    } else {
      _selectedBookIds.putIfAbsent(book.id, () => true);
    }

    setState(() {});
  }

  void onValidate() {
    List<String> bookIds = _selectedBookIds.keys.toList();

    if (bookIds.length > widget.maxPick) {
      bookIds = bookIds.sublist(0, widget.maxPick);
    }

    widget.onValidate?.call(bookIds);
    Beamer.of(context).popRoute();
  }
}
