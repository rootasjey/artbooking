import 'package:artbooking/components/buttons/dark_text_button.dart';
import 'package:artbooking/components/cards/book_card.dart';
import 'package:artbooking/components/cards/shimmer_card.dart';
import 'package:artbooking/components/popup_menu/popup_menu_icon.dart';
import 'package:artbooking/components/popup_menu/popup_menu_item_icon.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/screens/atelier/profile/popup_menu_button_section.dart';
import 'package:artbooking/types/book/book.dart';
import 'package:artbooking/types/book/popup_entry_book.dart';
import 'package:artbooking/types/enums/enum_book_item_action.dart';
import 'package:artbooking/types/enums/enum_navigation_section.dart';
import 'package:artbooking/types/enums/enum_section_action.dart';
import 'package:artbooking/types/enums/enum_section_data_mode.dart';
import 'package:artbooking/types/enums/enum_select_type.dart';
import 'package:artbooking/types/firestore/query_doc_snap_map.dart';
import 'package:artbooking/types/popup_item_section.dart';
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
    this.isHover = false,
    this.onNavigateFromSection,
  }) : super(key: key);

  /// If true, the current authenticated user is the owner and
  /// this section can be edited.
  final bool editMode;

  final bool isLast;
  final bool isHover;

  final bool usingAsDropTarget;

  final String userId;

  final void Function(
    EnumNavigationSection enumNavigationSection,
  )? onNavigateFromSection;

  final void Function(
    EnumSectionAction action,
    int index,
    Section section,
  )? onPopupMenuItemSelected;

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

    final bool isMobileSize = Utilities.size.isMobileSize(context);

    return Padding(
      padding: outerPadding,
      child: Stack(
        children: [
          Container(
            decoration: boxDecoration,
            padding: EdgeInsets.symmetric(
              horizontal: isMobileSize ? 12.0 : 70.0,
              vertical: 24.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                titleWidget(isMobileSize: isMobileSize),
                maybeHelperText(),
                gridWidget(isMobileSize: isMobileSize),
              ],
            ),
          ),
          rightPopupMenuButton(),
        ],
      ),
    );
  }

  List<Widget> getChildren({
    bool isMobileSize = false,
  }) {
    int index = -1;
    final bool canDrag = getCanDrag();
    final onDrop = canDrag ? onDropBook : null;
    final List<PopupEntryBook> popupMenuEntries = canDrag
        ? [
            PopupMenuItemIcon(
              icon: PopupMenuIcon(UniconsLine.minus),
              textLabel: "remove".tr(),
              value: EnumBookItemAction.remove,
            ),
          ]
        : [];

    final List<Widget> children = _books.map((Book book) {
      index++;

      final String heroTag = "${widget.section.id}-${index}-${book.id}";

      return BookCard(
        book: book,
        canDrag: canDrag,
        dragGroupName: "${widget.section.id}-${widget.index}",
        height: isMobileSize ? 161.0 : 320.0,
        heroTag: heroTag,
        index: index,
        onDrop: onDrop,
        onPopupMenuItemSelected: onBookItemSelected,
        onTap: book.available ? () => navigateToBookPage(book, heroTag) : null,
        popupMenuEntries: popupMenuEntries,
        width: isMobileSize ? 160.0 : 380.0,
      );
    }).toList();

    if (widget.editMode && (children.length % 3 != 0 && children.length < 6) ||
        children.isEmpty) {
      children.add(
        BookCard(
          book: Book.empty(),
          height: isMobileSize ? 161.0 : 342.0,
          heroTag: "empty_${DateTime.now()}",
          index: index,
          onTap: () => widget.onShowBookDialog?.call(
            section: widget.section,
            index: widget.index,
            selectType: EnumSelectType.add,
          ),
          useAsPlaceholder: true,
          width: isMobileSize ? 220.0 : 400.0,
        ),
      );
    }

    return children;
  }

  List<PopupMenuItemSection> getPopupMenuEntries() {
    final List<PopupMenuItemSection> popupMenuEntries =
        widget.popupMenuEntries.sublist(0);

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
          icon: PopupMenuIcon(UniconsLine.plus),
          textLabel: "books_select".tr(),
          value: EnumSectionAction.selectBooks,
          delay: Duration(milliseconds: popupMenuEntries.length * 25),
        ),
      );
    }

    return popupMenuEntries;
  }

  Widget gridWidget({
    bool isMobileSize = false,
  }) {
    if (isMobileSize) {
      return Padding(
        padding: const EdgeInsets.only(top: 34.0),
        child: Wrap(
          spacing: 6.0,
          runSpacing: 6.0,
          children: getChildren(
            isMobileSize: isMobileSize,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 34.0),
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        mainAxisSpacing: 24.0,
        crossAxisSpacing: 24.0,
        children: getChildren(
          isMobileSize: isMobileSize,
        ),
      ),
    );
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
        style: Utilities.fonts.body(
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

    return PopupMenuButtonSection(
      show: widget.isHover,
      itemBuilder: (_) => getPopupMenuEntries(),
      onSelected: (EnumSectionAction action) {
        widget.onPopupMenuItemSelected?.call(
          action,
          widget.index,
          widget.section,
        );
      },
    );
  }

  Widget seeMoreButton() {
    return DarkTextButton(
      onPressed: () {
        widget.onNavigateFromSection?.call(
          EnumNavigationSection.books,
        );
      },
      backgroundColor: Colors.black12,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Text("see_more".tr()), Icon(UniconsLine.arrow_right)],
      ),
    );
  }

  Widget titleWidget({bool isMobileSize = false}) {
    final String title = widget.section.name;
    final String description = widget.section.description;

    if (title.isEmpty && description.isEmpty) {
      return Container();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Flexible(
          flex: 4,
          child: SizedBox(
            width: 400.0,
            child: InkWell(
              onTap: widget.editMode ? onTapTitleDescription : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title.isNotEmpty)
                    Opacity(
                      opacity: 0.8,
                      child: Text(
                        title,
                        style: Utilities.fonts.title(
                          fontSize: isMobileSize ? 24 : 42.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  if (description.isNotEmpty)
                    Opacity(
                      opacity: 0.5,
                      child: Text(
                        description,
                        style: Utilities.fonts.body(
                          fontSize: isMobileSize ? 14.0 : 16.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        Spacer(flex: 2),
        seeMoreButton(),
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

      for (QueryDocSnapMap document in bookSnapshot.docs) {
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
