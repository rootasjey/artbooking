import 'package:artbooking/components/cards/book_card.dart';
import 'package:artbooking/components/cards/shimmer_card.dart';
import 'package:artbooking/components/popup_menu/popup_menu_item_icon.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/book/book.dart';
import 'package:artbooking/types/enums/enum_book_item_action.dart';
import 'package:artbooking/types/enums/enum_section_action.dart';
import 'package:artbooking/types/enums/enum_section_data_mode.dart';
import 'package:artbooking/types/enums/enum_select_type.dart';
import 'package:artbooking/types/firestore/doc_snap_map.dart';
import 'package:artbooking/types/section.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flash/src/flash_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

/// A 3x2 book grid.
class BookGridSection extends StatefulWidget {
  const BookGridSection({
    Key? key,
    required this.index,
    required this.section,
    required this.userId,
    this.onPopupMenuItemSelected,
    this.popupMenuEntries = const [],
    this.isLast = false,
    this.onUpdateSectionItems,
    this.onShowBookDialog,
    this.usingAsDropTarget = false,
    this.editMode = false,
  }) : super(key: key);

  /// If true, the current authenticated user is the owner and
  /// this section can be edited.
  final bool editMode;

  final bool isLast;

  final bool usingAsDropTarget;

  final String userId;

  final void Function(EnumSectionAction, int, Section)? onPopupMenuItemSelected;

  final void Function({
    required Section section,
    required int index,
    required EnumSelectType selectType,
  })? onShowBookDialog;

  final void Function(
    Section section,
    int index,
    List<String> items,
  )? onUpdateSectionItems;

  final List<PopupMenuItemIcon<EnumSectionAction>> popupMenuEntries;

  /// Section's position in the layout (e.g. 0 is the first).
  final int index;
  final Section section;

  @override
  State<BookGridSection> createState() => _BookGridSectionState();
}

class _BookGridSectionState extends State<BookGridSection> {
  bool _loading = false;

  /// Used to know to flush current data and refetch.
  /// If not, simply do a data diff. and update only some UI parts.
  var _currentMode = EnumSectionDataMode.sync;

  /// Courcircuit initState.
  /// If first execution, do a whole data fetch.
  /// Otherwise, try a data diff. and udpdate only some UI parts.
  bool _firstExecution = true;

  List<Book> _books = [];

  @override
  void initState() {
    super.initState();
    _currentMode = widget.section.dataFetchMode;
  }

  @override
  void dispose() {
    _books.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    checkData();

    if (_loading) {
      return loadingWidget();
    }

    final EdgeInsets outerPadding =
        widget.usingAsDropTarget ? const EdgeInsets.all(4.0) : EdgeInsets.zero;

    final BoxDecoration boxDecoration = widget.usingAsDropTarget
        ? BoxDecoration(
            borderRadius: BorderRadius.circular(4.0),
            border: Border.all(
              color: Theme.of(context).primaryColor,
              width: 3.0,
            ),
            color: Color(widget.section.backgroundColor),
          )
        : BoxDecoration(
            color: Color(widget.section.backgroundColor),
          );

    return Padding(
      padding: outerPadding,
      child: Stack(
        children: [
          Container(
            decoration: boxDecoration,
            padding: const EdgeInsets.symmetric(
              horizontal: 70.0,
              vertical: 24.0,
            ),
            child: Column(
              children: [
                titleSectionWidget(),
                maybeHelperText(),
                Padding(
                  padding: const EdgeInsets.only(top: 34.0),
                  child: GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    mainAxisSpacing: 24.0,
                    crossAxisSpacing: 24.0,
                    childAspectRatio: 0.8,
                    children: getChildren(),
                  ),
                ),
              ],
            ),
          ),
          rightPopupMenuButton(),
        ],
      ),
    );
  }

  List<Widget> getChildren() {
    int index = -1;
    final bool canDrag = getCanDrag();
    final onDrop = canDrag ? onDropBook : null;
    final List<PopupMenuEntry<EnumBookItemAction>> popupMenuEntries = canDrag
        ? [
            PopupMenuItemIcon(
              icon: Icon(UniconsLine.minus),
              textLabel: "remove".tr(),
              value: EnumBookItemAction.remove,
            ),
          ]
        : [];

    final double width = 330.0;
    final double height = 380.0;

    final children = _books.map((Book book) {
      index++;

      final heroTag = "${widget.section.id}-${index}-${book.id}";

      return BookCard(
        index: index,
        canDrag: canDrag,
        dragGroupName: "${widget.section.id}-${widget.index}",
        heroTag: heroTag,
        onDrop: onDrop,
        book: book,
        width: width,
        height: height,
        onTap: book.available ? () => navigateToBookPage(book, heroTag) : null,
        popupMenuEntries: popupMenuEntries,
        onPopupMenuItemSelected: onBookItemSelected,
      );
    }).toList();

    if (widget.editMode && (children.length % 3 != 0 && children.length < 6) ||
        children.isEmpty) {
      children.add(
        BookCard(
          useAsPlaceholder: true,
          heroTag: "empty_${DateTime.now()}",
          width: width,
          height: height,
          book: Book.empty(),
          index: index,
          onTap: () => widget.onShowBookDialog?.call(
            section: widget.section,
            index: widget.index,
            selectType: EnumSelectType.add,
          ),
        ),
      );
    }

    return children;
  }

  List<PopupMenuItemIcon<EnumSectionAction>> getPopupMenuEntries() {
    final popupMenuEntries = widget.popupMenuEntries.sublist(0);

    if (widget.index == 0) {
      popupMenuEntries.removeWhere((x) => x.value == EnumSectionAction.moveUp);
    }

    if (widget.isLast) {
      popupMenuEntries.removeWhere(
        (x) => x.value == EnumSectionAction.moveDown,
      );
    }

    if (_currentMode == EnumSectionDataMode.chosen) {
      popupMenuEntries.add(
        PopupMenuItemIcon(
          icon: Icon(UniconsLine.plus),
          textLabel: "books_select".tr(),
          value: EnumSectionAction.selectBooks,
        ),
      );
    }

    return popupMenuEntries;
  }

  Widget loadingWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 90.9,
        vertical: 24.0,
      ),
      child: Wrap(
        spacing: 24.0,
        runSpacing: 12.0,
        children: [
          ShimmerCard(height: 300.0),
          ShimmerCard(height: 300.0),
        ],
      ),
    );
  }

  Widget maybeHelperText() {
    if (widget.section.dataFetchMode != EnumSectionDataMode.chosen ||
        _books.isNotEmpty) {
      return Container();
    }

    return Container(
      width: 500.0,
      padding: const EdgeInsets.all(24.0),
      child: Text.rich(
        TextSpan(
          text: "books_pick_description".tr(),
          children: [
            TextSpan(
              text: ' ${"books_sync_description".tr()} ',
              recognizer: TapGestureRecognizer()..onTap = setSyncDataMode,
              style: TextStyle(
                backgroundColor: Colors.amber.shade100,
              ),
            ),
          ],
        ),
        style: Utilities.fonts.style(
          fontSize: 16.0,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget rightPopupMenuButton() {
    if (!widget.editMode) {
      return Container();
    }

    final popupMenuEntries = getPopupMenuEntries();

    return Positioned(
      top: 12.0,
      right: 12.0,
      child: PopupMenuButton(
        child: Card(
          elevation: 2.0,
          color: Theme.of(context).backgroundColor,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(UniconsLine.ellipsis_h),
          ),
        ),
        itemBuilder: (_) => popupMenuEntries,
        onSelected: (EnumSectionAction action) {
          widget.onPopupMenuItemSelected?.call(
            action,
            widget.index,
            widget.section,
          );
        },
      ),
    );
  }

  Widget titleSectionWidget() {
    final title = widget.section.name;
    final description = widget.section.description;

    if (title.isEmpty && description.isEmpty) {
      return Container();
    }

    return Column(
      children: [
        InkWell(
          onTap: onTapTitleDescription,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                if (title.isNotEmpty)
                  Opacity(
                    opacity: 0.6,
                    child: Text(
                      title,
                      style: Utilities.fonts.style(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                if (description.isNotEmpty)
                  Opacity(
                    opacity: 0.4,
                    child: Text(
                      description,
                      style: Utilities.fonts.style(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        SizedBox(
          width: 200.0,
          child: Divider(
            color: Theme.of(context).secondaryHeaderColor,
            thickness: 4.0,
          ),
        ),
      ],
    );
  }

  /// (BAD) Check for changes and fetch new data a change is detected.
  /// WARNING: This is anti-pattern to `setState()` inside of a `build()` method.
  void checkData() {
    if (_firstExecution) {
      _firstExecution = false;
      fetchBooks();
      return;
    }

    if (_currentMode != widget.section.dataFetchMode) {
      _currentMode = widget.section.dataFetchMode;
      _currentMode == EnumSectionDataMode.sync ? fetchBooks() : null;
    }

    if (_currentMode == EnumSectionDataMode.chosen) {
      diffBook();
    }
  }

  /// Update UI without re-loading the whole component.
  void diffBook() async {
    if (_loading) {
      return;
    }

    _loading = true;

    final bookIds = _books.map((x) => x.id).toList();
    var initialBooks = widget.section.items;
    if (listEquals(bookIds, initialBooks)) {
      _loading = false;
      return;
    }

    // Ignore illustrations which are still in the list.
    final booksToFetch = initialBooks.sublist(0)
      ..removeWhere((x) => bookIds.contains(x));

    // Remove illustrations which are not in the list anymore.
    _books.removeWhere((x) => !initialBooks.contains(x.id));

    if (booksToFetch.isEmpty) {
      _loading = false;
      return;
    }

    // Fetch new illustrations.
    final List<Future<Book>> futures = [];
    for (final id in booksToFetch) {
      futures.add(fetchBook(id));
    }

    final futuresResult = await Future.wait(futures);
    setState(() {
      _books.addAll(futuresResult);
      _loading = false;
    });
  }

  Future<Book> fetchBook(String id) async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection("books").doc(id).get();

      final data = snapshot.data();
      if (!snapshot.exists || data == null) {
        return Book.empty(
          available: false,
          id: id,
          name: "?",
          userId: widget.userId,
        );
      }

      data["id"] = snapshot.id;
      return Book.fromMap(data);
    } catch (error) {
      Utilities.logger.e(error);
      return Book.empty(
        available: false,
        id: id,
        name: "?",
        userId: widget.userId,
      );
    }
  }

  void fetchBooks() {
    if (widget.section.dataFetchMode == EnumSectionDataMode.sync) {
      fetchSyncBooks();
      return;
    }

    fetchChosenBooks();
  }

  /// Fetch only chosen illustrations.
  /// When this section's data fetch mode is equals to 'chosen'.
  void fetchChosenBooks() async {
    setState(() {
      _loading = true;
      _books.clear();
    });

    final List<Future<Book>> futures = [];
    for (final id in widget.section.items) {
      futures.add(fetchBook(id));
    }

    final futuresResult = await Future.wait(futures);
    setState(() {
      _books.addAll(futuresResult);
      _loading = false;
    });
  }

  /// Fetch last user's public books
  /// when this section's data fetch mode is equals to 'sync'.
  void fetchSyncBooks() async {
    setState(() {
      _loading = true;
      _books.clear();
    });

    try {
      final bookSnapshot = await FirebaseFirestore.instance
          .collection("books")
          .where("user_id", isEqualTo: widget.userId)
          .where("visibility", isEqualTo: "public")
          .limit(6)
          .orderBy("user_custom_index", descending: true)
          .get();

      if (bookSnapshot.size == 0) {
        setState(() {
          _loading = false;
        });
        return;
      }

      for (DocSnapMap document in bookSnapshot.docs) {
        final data = document.data();
        data["id"] = document.id;
        _books.add(Book.fromMap(data));
      }
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  bool getCanDrag() {
    if (!widget.editMode) {
      return false;
    }

    return _currentMode == EnumSectionDataMode.chosen;
  }

  void navigateToBookPage(Book book, String heroTag) {
    Utilities.navigation.profileToBook(
      context,
      book: book,
      heroTag: heroTag,
      userId: widget.userId,
    );
  }

  void onBookItemSelected(
    EnumBookItemAction action,
    int index,
    Book book,
  ) {
    switch (action) {
      case EnumBookItemAction.remove:
        setState(() {
          _books.removeWhere((x) => x.id == book.id);
        });

        List<String> items = widget.section.items;
        items.removeWhere((x) => x == book.id);
        widget.onUpdateSectionItems?.call(widget.section, widget.index, items);

        break;
      default:
    }
  }

  void onDropBook(int dropTargetIndex, List<int> dragIndexes) {
    final int firstDragIndex = dragIndexes.first;
    if (dropTargetIndex == firstDragIndex) {
      return;
    }

    if (dropTargetIndex < 0 ||
        firstDragIndex < 0 ||
        dropTargetIndex >= _books.length ||
        firstDragIndex > _books.length) {
      return;
    }

    final dropTargetBook = _books.elementAt(dropTargetIndex);
    final dragBook = _books.elementAt(firstDragIndex);

    setState(() {
      _books[firstDragIndex] = dropTargetBook;
      _books[dropTargetIndex] = dragBook;
    });

    final List<String> items = _books.map((x) => x.id).toList();
    widget.onUpdateSectionItems?.call(widget.section, widget.index, items);
  }

  void onTapTitleDescription() {
    widget.onPopupMenuItemSelected?.call(
      EnumSectionAction.rename,
      widget.index,
      widget.section,
    );
  }

  void setSyncDataMode() {
    widget.onPopupMenuItemSelected?.call(
      EnumSectionAction.setSyncDataMode,
      widget.index,
      widget.section,
    );
  }
}
