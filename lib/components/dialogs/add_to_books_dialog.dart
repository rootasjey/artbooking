import 'dart:math';

import 'package:artbooking/actions/books.dart';
import 'package:artbooking/components/buttons/dark_elevated_button.dart';
import 'package:artbooking/components/dialogs/input_dialog.dart';
import 'package:artbooking/components/dialogs/themed_dialog.dart';
import 'package:artbooking/components/texts/outlined_text_field.dart';
import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/book/book.dart';
import 'package:artbooking/types/cloud_functions/illustrations_response.dart';
import 'package:artbooking/types/firestore/query_doc_snap_map.dart';
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

/// Add a group of illustrations to one or more books.
class AddToBooksDialog extends StatefulWidget {
  AddToBooksDialog({
    required this.illustrations,
    this.asBottomSheet = false,
    this.autoFocus = false,
    this.books = const [],
    this.onComplete,
  });

  /// If true, this widget will take a suitable layout for bottom sheet.
  /// Otherwise, it will have a dialog layout.
  final bool asBottomSheet;

  /// Will request focus on mount if true.
  final bool autoFocus;

  /// Illustrations to add to books.
  final List<Illustration> illustrations;

  /// Books to add to other books.
  final List<Book> books;

  /// Callback fired when the operation complete
  /// (illustrations has been added to books).
  final void Function()? onComplete;

  @override
  _AddToBooksDialogState createState() => _AddToBooksDialogState();
}

class _AddToBooksDialogState extends State<AddToBooksDialog> {
  /// Currently fetching data if true.
  bool _loading = false;

  /// More books can be fetched if true.
  bool _hasNext = false;

  /// Currently fetching more data (page >= 2) if true.
  bool _loadingMore = false;

  /// If true, the widget will show inputs to create a new book.
  /// Otherwise, a list of available books will be displayed.
  bool _createMode = false;

  /// Last fetched document (from Firestore).
  DocumentSnapshot? _lastDocument;

  /// Maximum books to fetch per page.
  final int _limit = 20;

  /// Books fetched.
  List<Book> _books = [];

  /// Selected books to add illustration(s) in.
  List<Book> _selectedBooks = [];

  /// Scroll controller for this widget.
  final ScrollController _pageScrollController = ScrollController();

  /// Controller for new book name.
  final TextEditingController _nameController = TextEditingController();

  /// Controller for new book description.
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchBooks();
  }

  @override
  void dispose() {
    _pageScrollController.dispose();
    _lastDocument = null;
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_createMode) {
      return createBookWidget();
    }

    final void Function()? _onValidate =
        _loading || _selectedBooks.isEmpty ? null : onValidate;

    if (widget.asBottomSheet) {
      return mobileWidget(onValidate: _onValidate);
    }

    return ThemedDialog(
      autofocus: widget.autoFocus,
      useRawDialog: true,
      title: header(),
      body: desktopBody(),
      textButtonValidation: "books_add_to".plural(_selectedBooks.length),
      footer: footer(onValidate: _onValidate),
      onCancel: Beamer.of(context).popRoute,
      onValidate: _onValidate,
    );
  }

  Widget desktopBody() {
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
                (BuildContext context, int index) {
                  final Book book = _books.elementAt(index);
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

  Widget createBookWidget() {
    if (widget.asBottomSheet) {
      return Material(
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.only(
              top: 24.0,
              left: 12.0,
              right: 12.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                header(
                  create: true,
                  margin: const EdgeInsets.only(bottom: 24.0),
                ),
                OutlinedTextField(
                  controller: _nameController,
                  label: "book_name".tr(),
                  hintText:
                      "book_create_hint_texts.${Random().nextInt(13)}".tr(),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: OutlinedTextField(
                    autofocus: false,
                    controller: _descriptionController,
                    label: "book_description".tr(),
                    hintText:
                        "book_create_hint_description_texts.${Random().nextInt(13)}"
                            .tr(),
                  ),
                ),
                DarkElevatedButton.large(
                  child: Text("book_create_and_add_illustration"
                      .plural(widget.books.length)),
                  margin: const EdgeInsets.only(top: 24.0, bottom: 16.0),
                  onPressed: () {
                    createBookAndAddIllustrations();
                    Beamer.of(context).popRoute();
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }

    return InputDialog(
      titleValue: "book_create".tr().toUpperCase(),
      subtitleValue: "book_create_description".tr(),
      nameController: _nameController,
      descriptionController: _descriptionController,
      onCancel: Beamer.of(context).popRoute,
      onSubmitted: (_) {
        createBookAndAddIllustrations();
        Beamer.of(context).popRoute();
      },
    );
  }

  Widget footer({void Function()? onValidate}) {
    return Material(
      elevation: 0.0,
      color: Constants.colors.clairPink,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.all(6.0),
            child: widget.asBottomSheet
                ? DarkElevatedButton(
                    onPressed: onValidate,
                    child: Text("books_add_to".plural(_selectedBooks.length)),
                  )
                : DarkElevatedButton.large(
                    onPressed: onValidate,
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
    );
  }

  Widget header({
    bool create = false,
    EdgeInsets margin = EdgeInsets.zero,
  }) {
    return Padding(
      padding: margin,
      child: Column(
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
                create
                    ? "books_create_and_add_illustration_in"
                        .plural(widget.illustrations.length)
                    : "books_choose_add_illustration_in"
                        .plural(widget.illustrations.length),
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
    );
  }

  Widget mobileWidget({void Function()? onValidate}) {
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

    return Stack(
      children: [
        NotificationListener<ScrollNotification>(
          onNotification: onScrollNotification,
          child: CustomScrollView(
            controller: _pageScrollController,
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    header(
                      margin: const EdgeInsets.all(12.0),
                    ),
                    Divider(
                      thickness: 2.0,
                      color: Theme.of(context).secondaryHeaderColor,
                    ),
                  ],
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      final Book book = _books.elementAt(index);
                      return bookTile(book);
                    },
                    childCount: _books.length,
                  ),
                ),
              ),
              SliverPadding(padding: const EdgeInsets.only(bottom: 150.0)),
            ],
          ),
        ),
        Positioned(
          bottom: 0.0,
          left: 0.0,
          right: 0.0,
          child: footer(onValidate: onValidate),
        ),
      ],
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
    if (_selectedBooks.contains(book)) {
      _selectedBooks.remove(book);
    } else {
      _selectedBooks.add(book);
    }

    setState(() {});
  }

  void showCreationInputs() {
    setState(() {
      _createMode = true;
    });
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

  void onValidate() {
    addIllustrationToBooks();
    Beamer.of(context).popRoute();
  }
}
