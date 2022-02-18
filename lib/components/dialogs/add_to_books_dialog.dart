import 'package:artbooking/actions/books.dart';
import 'package:artbooking/components/buttons/dark_elevated_button.dart';
import 'package:artbooking/components/dialogs/input_dialog.dart';
import 'package:artbooking/components/dialogs/themed_dialog.dart';
import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/book/book.dart';
import 'package:artbooking/types/cloud_functions/illustrations_response.dart';
import 'package:artbooking/types/firestore/doc_snap_map.dart';
import 'package:artbooking/types/illustration/illustration.dart';
import 'package:artbooking/types/json_types.dart';
import 'package:beamer/beamer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash/src/flash_helper.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:unicons/unicons.dart';
import 'package:supercharged/supercharged.dart';

/// Add a group of illustrations to one or more books..
class AddToBooksDialog extends StatefulWidget {
  AddToBooksDialog({
    this.scrollController,
    required this.illustrations,
    this.books = const [],
    this.autoFocus = false,
    this.onComplete,
  });

  final bool autoFocus;
  final ScrollController? scrollController;
  final List<Illustration> illustrations;
  final List<Book> books;

  /// When the operation complete (illustrations has been added to books).
  final void Function()? onComplete;

  @override
  _AddToBooksDialogState createState() => _AddToBooksDialogState();
}

class _AddToBooksDialogState extends State<AddToBooksDialog> {
  bool _loading = false;
  bool _hasNext = false;
  bool _loadingMore = false;

  /// If true, the widget will show inputs to create a new book.
  /// Otherwise, a list of available books will be displayed.
  bool _createMode = false;

  DocumentSnapshot? _lastDocument;

  final int _limit = 20;
  List<Book> _books = [];
  List<Book> _selectedBooks = [];

  var _scrollController = ScrollController();
  var _nameController = TextEditingController();
  var _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchBooks();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _lastDocument = null;
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_createMode) {
      return InputDialog(
        titleValue: "book_create".tr().toUpperCase(),
        subtitleValue: "book_create_description".tr(),
        nameController: _nameController,
        descriptionController: _descriptionController,
        onCancel: Beamer.of(context).popRoute,
        onSubmitted: (value) {
          // createBook(
          //   _nameController.text,
          //   _descriptionController.text,
          // );
          createBookAndAddIllustrations();
          Beamer.of(context).popRoute();
        },
      );
    }

    final _onValidate = _loading || _selectedBooks.isEmpty ? null : onValidate;

    return ThemedDialog(
      autofocus: widget.autoFocus,
      useRawDialog: true,
      title: Column(
        children: [
          Opacity(
            opacity: 0.8,
            child: Text(
              "books".tr().toUpperCase(),
              style: Utilities.fonts.style(
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
                "books_choose_add_illustrations_in".tr(),
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
      body: body(),
      textButtonValidation: "books_add_to".plural(_selectedBooks.length),
      footer: Material(
        elevation: 4.0,
        color: Constants.colors.clairPink,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.all(12.0),
              child: DarkElevatedButton.large(
                onPressed: _onValidate,
                child: Text("books_add_to".plural(_selectedBooks.length)),
              ),
            ),
            Tooltip(
              message: "book_create".tr(),
              child: DarkElevatedButton.iconOnly(
                color: Theme.of(context).secondaryHeaderColor.withOpacity(0.8),
                onPressed: _loading ? null : showCreationInputs,
                child: Icon(UniconsLine.plus),
              ),
            ),
          ],
        ),
      ),
      onCancel: Beamer.of(context).popRoute,
      onValidate: _onValidate,
    );
  }

  void showCreationInputs() {
    setState(() {
      _createMode = true;
    });
  }

  void onValidate() {
    addIllustrationToBooks();
    Beamer.of(context).popRoute();
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
                  style: Utilities.fonts.style(
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
        maxHeight: 414.0,
        maxWidth: 400.0,
      ),
      child: NotificationListener<ScrollNotification>(
        onNotification: onScrollNotification,
        child: CustomScrollView(
          controller: _scrollController,
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

    final bool selected = _selectedBooks.contains(book);
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
                                style: Utilities.fonts.style(
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
                                style: Utilities.fonts.style(
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
                                style: Utilities.fonts.style(
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
                                style: Utilities.fonts.style(
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

  void addIllustrationToBooks() async {
    widget.onComplete?.call();

    final List<Illustration> illustrations = widget.illustrations;
    final List<String> illustrationIds =
        illustrations.map((x) => x.id).toList();

    final List<Book> books = widget.books;

    illustrationIds.addAll(
      books.fold(
        [],
        (p, b) => p.toList() + ((b.illustrations.map((i) => i.id)).toList()),
      ),
    );

    final String progressId = "add_illustrations_${DateTime.now()}";
    showProgress(progressId, illustrationIds.length);

    final List<Future<IllustrationsResponse>> futureArray = [];

    for (var book in _selectedBooks) {
      futureArray.add(BooksActions.addIllustrations(
        bookId: book.id,
        illustrationIds: illustrationIds,
      ));
    }

    final responses = await Future.wait(futureArray);

    Utilities.flash.dismissProgress(id: progressId);
    final response = responses.firstWhere(
      (x) => x.hasErrors,
      orElse: () => IllustrationsResponse.empty(),
    );

    if (response.hasErrors) {
      context.showErrorBar(
        icon: Icon(UniconsLine.exclamation_triangle),
        content: Text(
          _selectedBooks.length > 1
              ? "books_add_illustrations_error".plural(illustrationIds.length)
              : "book_add_illustrations_error".plural(illustrationIds.length),
        ),
      );
    }
  }

  void createBookAndAddIllustrations() async {
    widget.onComplete?.call();

    final String progressId = "create_book_${DateTime.now()}";
    Utilities.flash.showProgress(
      context,
      title: "books_task".tr(),
      progressId: progressId,
      message: "book_creating_name".tr(args: [_nameController.text]) + "...",
      icon: Icon(UniconsLine.plus),
      duration: 60.seconds,
    );

    final List<Illustration> illustrations = widget.illustrations;
    final List<String> illustrationIds =
        illustrations.map((x) => x.id).toList();

    final List<Book> books = widget.books;

    illustrationIds.addAll(
      books.fold(
        [],
        (p, b) => p.toList() + ((b.illustrations.map((i) => i.id)).toList()),
      ),
    );

    final response = await BooksActions.createOne(
      name: _nameController.text,
      description: _descriptionController.text,
      illustrationIds: illustrationIds,
    );

    Utilities.flash.dismissProgress(id: progressId);

    if (!response.success) {
      context.showErrorBar(
        content: Text("book_creation_error".tr()),
      );

      return;
    }
  }

  Future fetchBooks() async {
    _books.clear();
    setState(() => _loading = true);

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("books")
          .where("user_id", isEqualTo: FirebaseAuth.instance.currentUser?.uid)
          .limit(_limit)
          .orderBy("updated_at", descending: true)
          .get();

      if (snapshot.docs.isEmpty) {
        _hasNext = false;
        return;
      }

      for (DocSnapMap document in snapshot.docs) {
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
      final snapshot = await FirebaseFirestore.instance
          .collection("books")
          .where("user_id", isEqualTo: FirebaseAuth.instance.currentUser?.uid)
          .limit(_limit)
          .orderBy("updated_at", descending: true)
          .startAfterDocument(lastDocument)
          .get();

      if (snapshot.docs.isEmpty) {
        _hasNext = false;
        return;
      }

      for (DocSnapMap document in snapshot.docs) {
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
    if (_selectedBooks.contains(book)) {
      _selectedBooks.remove(book);
    } else {
      _selectedBooks.add(book);
    }

    setState(() {});
  }

  void showProgress(String progressId, int illustrationCount) {
    String message = "";

    if (_selectedBooks.length > 1) {
      message = "books_adding_illustrations".plural(illustrationCount) + "...";
    } else {
      message = "book_adding_illustrations".plural(illustrationCount) + "...";
    }

    Utilities.flash.showProgress(
      context,
      title: "illustrations_task".tr(),
      progressId: progressId,
      message: message,
      icon: Icon(UniconsLine.plus),
      duration: 60.seconds,
    );
  }
}
