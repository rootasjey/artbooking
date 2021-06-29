import 'package:artbooking/actions/books.dart';
import 'package:artbooking/actions/illustrations.dart';
import 'package:artbooking/components/animated_app_icon.dart';
import 'package:artbooking/components/dark_elevated_button.dart';
import 'package:artbooking/components/illustration_card.dart';
import 'package:artbooking/components/main_app_bar.dart';
import 'package:artbooking/components/popup_menu_item_icon.dart';
import 'package:artbooking/components/sliver_edge_padding.dart';
import 'package:artbooking/components/text_divider.dart';
import 'package:artbooking/components/text_rectangle_button.dart';
import 'package:artbooking/components/underlined_button.dart';
import 'package:artbooking/components/user_books.dart';
import 'package:artbooking/router/app_router.gr.dart';
import 'package:artbooking/state/colors.dart';
import 'package:artbooking/types/book.dart';
import 'package:artbooking/types/enums.dart';
import 'package:artbooking/types/illustration/illustration.dart';
import 'package:artbooking/utils/app_logger.dart';
import 'package:artbooking/utils/constants.dart';
import 'package:artbooking/utils/fonts.dart';
import 'package:artbooking/utils/snack.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jiffy/jiffy.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:supercharged/supercharged.dart';
import 'package:unicons/unicons.dart';

class MyBookPage extends StatefulWidget {
  final String bookId;
  final Book? book;

  const MyBookPage({
    Key? key,
    @PathParam() required this.bookId,
    this.book,
  }) : super(key: key);
  @override
  _MyBookPageState createState() => _MyBookPageState();
}

class _MyBookPageState extends State<MyBookPage> {
  /// The viewing book.
  Book? bookPage;

  bool _isLoading = false;
  bool _hasError = false;
  bool _isFabVisible = false;
  bool _forceMultiSelect = false;

  final _illustrations = <Illustration>[];
  final _keyboardFocusNode = FocusNode();

  int _limit = 20;
  int _startIndex = 0;
  int _endIndex = 0;

  Map<String?, Illustration> _multiSelectedItems = Map();
  Map<int, Illustration> _processingIllustrations = Map();

  ScrollController _scrollController = ScrollController();

  final List<PopupMenuEntry<BookItemAction>> popupMenuEntries = [
    PopupMenuItemIcon(
      value: BookItemAction.addToBook,
      icon: Icon(UniconsLine.book_medical),
      textLabel: "add_to_book".tr(),
    ),
    PopupMenuItemIcon(
      value: BookItemAction.removeFromBook,
      icon: Icon(UniconsLine.image_minus),
      textLabel: "remove".tr(),
    ),
  ];

  @override
  initState() {
    super.initState();

    if (widget.book == null) {
      fetchBookAndIllustrations();
    } else {
      bookPage = widget.book;
      fetchIllustrations();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: fab(),
      body: NotificationListener<ScrollNotification>(
        onNotification: onNotification,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: <Widget>[
            SliverEdgePadding(),
            MainAppBar(),
            header(),
            body(),
            SliverPadding(
              padding: const EdgeInsets.only(
                bottom: 100.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget bookCoverCard() {
    if (bookPage == null) {
      return SizedBox(
        height: 260.0,
        width: 200.0,
        child: Card(
          elevation: 2.0,
          color: stateColors.clairPink,
        ),
      );
    }

    return SizedBox(
      height: 260.0,
      width: 200.0,
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        clipBehavior: Clip.antiAlias,
        child: Ink.image(
          image: NetworkImage(bookPage!.getCoverUrl()),
          height: 260.0,
          width: 200.0,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget body() {
    if (_isLoading) {
      return SliverList(
        delegate: SliverChildListDelegate.fixed([
          Padding(
            padding: const EdgeInsets.only(top: 100.0),
            child: AnimatedAppIcon(
              textTitle: "loading_illustrations".tr(),
            ),
          ),
        ]),
      );
    }

    if (_hasError) {
      return errorView();
    }

    if (_illustrations.isEmpty) {
      return emptyView();
    }

    return gridView();
  }

  Widget createdAt() {
    if (bookPage == null) {
      return Container();
    }

    final DateTime? createdAt = bookPage!.createdAt;

    if (createdAt == null) {
      return Container();
    }

    String createdAtStr = "";

    if (DateTime.now().difference(createdAt).inDays > 60) {
      createdAtStr = "date_created_at".tr(
        args: [
          Jiffy(bookPage!.createdAt).yMMMMEEEEd,
        ],
      );
    } else {
      createdAtStr = "date_created_ago".tr(
        args: [Jiffy(bookPage!.createdAt).fromNow()],
      );
    }

    return Opacity(
      opacity: 0.6,
      child: Text(
        createdAtStr,
        style: FontsUtils.mainStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget description() {
    if (bookPage == null) {
      return Container();
    }

    return Opacity(
      opacity: 0.6,
      child: Text(
        bookPage!.description,
        style: FontsUtils.mainStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget defaultActionsToolbar() {
    if (_multiSelectedItems.isNotEmpty) {
      return Container();
    }

    return Wrap(
      spacing: 12.0,
      runSpacing: 12.0,
      children: [
        multiSelectButton(),
      ],
    );
  }

  Widget emptyView() {
    return SliverPadding(
      padding: const EdgeInsets.only(
        top: 40.0,
        left: 50.0,
      ),
      sliver: SliverList(
        delegate: SliverChildListDelegate.fixed([
          Column(
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Opacity(
                  opacity: 0.8,
                  child: Icon(
                    UniconsLine.trees,
                    size: 80.0,
                    color: Colors.lightGreen,
                  ),
                ),
              ),
              Opacity(
                opacity: 0.6,
                child: Text(
                  "This is a new start".toUpperCase(),
                  style: FontsUtils.mainStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                width: 400.0,
                padding: const EdgeInsets.only(
                  bottom: 16.0,
                ),
                child: Opacity(
                  opacity: 0.4,
                  child: Text(
                    "book_no_illustrations".tr(),
                    textAlign: TextAlign.center,
                    style: FontsUtils.mainStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ),
              emptyViewActions(),
            ],
          ),
        ]),
      ),
    );
  }

  Widget emptyViewActions() {
    return Container(
      width: 400.0,
      padding: const EdgeInsets.only(top: 24.0),
      child: Column(
        children: [
          IconButton(
            tooltip: "book_upload_illustration".tr(),
            onPressed: uploadAndAddToThisBook,
            icon: Icon(UniconsLine.upload),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: TextDivider(
              text: Opacity(
                opacity: 0.6,
                child: Text(
                  "or".tr().toUpperCase(),
                  style: FontsUtils.mainStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          UnderlinedButton(
            onTap: () {
              context.router.root.push(
                DashboardPageRoute(
                  children: [DashIllustrationsRouter()],
                ),
              );
            },
            child: Text("illustrations_browse".tr()),
          ),
        ],
      ),
    );
  }

  Widget errorView() {
    return SliverPadding(
      padding: const EdgeInsets.only(
        top: 40.0,
        left: 50.0,
      ),
      sliver: SliverList(
        delegate: SliverChildListDelegate.fixed([
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 12.0,
                ),
                child: Text(
                  "issue_unexpected".tr(),
                  style: TextStyle(
                    fontSize: 32.0,
                    color: stateColors.primary,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 16.0,
                  // top: 24.0,
                ),
                child: Opacity(
                  opacity: 0.4,
                  child: Text(
                    "issue_data_retry".tr(),
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: fetchBookAndIllustrations,
                icon: Icon(UniconsLine.refresh),
                label: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    "retry".tr(),
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ]),
      ),
    );
  }

  Widget fab() {
    if (!_isFabVisible) {
      return FloatingActionButton(
        onPressed: fetchIllustrations,
        backgroundColor: stateColors.primary,
        foregroundColor: Colors.white,
        child: Icon(UniconsLine.refresh),
      );
    }

    return FloatingActionButton(
      onPressed: () {
        _scrollController.animateTo(
          0.0,
          duration: 1.seconds,
          curve: Curves.easeOut,
        );
      },
      backgroundColor: stateColors.primary,
      foregroundColor: Colors.white,
      child: Icon(UniconsLine.arrow_up),
    );
  }

  Widget gridView() {
    final selectionMode = _forceMultiSelect || _multiSelectedItems.isNotEmpty;

    return SliverPadding(
      padding: const EdgeInsets.all(40.0),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 300.0,
          mainAxisSpacing: 20.0,
          crossAxisSpacing: 20.0,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final illustration = _illustrations.elementAt(index);
            final selected = _multiSelectedItems.containsKey(illustration.id);

            return IllustrationCard(
              illustration: illustration,
              selected: selected,
              selectionMode: selectionMode,
              onPopupMenuItemSelected: onPopupMenuItemSelected,
              popupMenuEntries: popupMenuEntries,
              onLongPress: (selected) {
                if (selected) {
                  setState(() {
                    _multiSelectedItems.remove(illustration.id);
                  });
                  return;
                }

                setState(() {
                  _multiSelectedItems.putIfAbsent(
                      illustration.id, () => illustration);
                });
              },
            );
          },
          childCount: _illustrations.length,
        ),
      ),
    );
  }

  Widget header() {
    return SliverPadding(
      padding: const EdgeInsets.only(
        top: 60.0,
        left: 50.0,
        bottom: 24.0,
      ),
      sliver: SliverList(
        delegate: SliverChildListDelegate.fixed([
          headerTop(),
          headerBottom(),
        ]),
      ),
    );
  }

  Widget headerBottom() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 32.0,
        left: 8.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          defaultActionsToolbar(),
          multiSelectToolbar(),
        ],
      ),
    );
  }

  Widget headerTop() {
    return Wrap(
      spacing: 24.0,
      runSpacing: 24.0,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        bookCoverCard(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Opacity(
              opacity: 0.6,
              child: IconButton(
                tooltip: "back".tr(),
                onPressed: context.router.pop,
                icon: Icon(UniconsLine.arrow_left),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  title(),
                  description(),
                  updatedAt(),
                  stats(),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget multiSelectButton() {
    if (_illustrations.isEmpty) {
      return Container();
    }

    return TextRectangleButton(
      onPressed: () {
        setState(() {
          _forceMultiSelect = !_forceMultiSelect;
        });
      },
      icon: Icon(UniconsLine.layers_alt),
      label: Text('multi_select'.tr()),
      primary: _forceMultiSelect ? Colors.lightGreen : Colors.black38,
    );
  }

  Widget multiSelectToolbar() {
    if (_multiSelectedItems.isEmpty) {
      return Container();
    }

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Opacity(
          opacity: 0.6,
          child: Text(
            "multi_items_selected"
                .tr(args: [_multiSelectedItems.length.toString()]),
            style: TextStyle(
              fontSize: 30.0,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Container(
            height: 25.0,
            width: 2.0,
            color: Colors.black12,
          ),
        ),
        TextButton.icon(
          onPressed: () {
            setState(() {
              _multiSelectedItems.clear();
            });
          },
          icon: Icon(Icons.border_clear),
          label: Text('clear_selection'.tr()),
        ),
        TextButton.icon(
          onPressed: () {
            _illustrations.forEach((illustration) {
              _multiSelectedItems.putIfAbsent(
                  illustration.id, () => illustration);
            });

            setState(() {});
          },
          icon: Icon(Icons.select_all),
          label: Text('select_all'.tr()),
        ),
        TextButton.icon(
          onPressed: confirmSelectionDeletion,
          style: TextButton.styleFrom(
            primary: Colors.red,
          ),
          icon: Icon(Icons.delete_outline),
          label: Text('delete'.tr()),
        ),
      ],
    );
  }

  Widget stats() {
    if (bookPage == null) {
      return Container();
    }

    final Color color = bookPage!.illustrations.isEmpty
        ? stateColors.secondary
        : stateColors.primary;

    return Opacity(
      opacity: 0.8,
      child: Text(
        "illustrations_count".plural(bookPage!.illustrations.length),
        style: FontsUtils.mainStyle(
          color: color,
          fontSize: 16.0,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget title() {
    final bookName = bookPage != null ? bookPage!.name : 'My book';

    return Opacity(
      opacity: 0.8,
      child: Text(
        bookName,
        style: FontsUtils.mainStyle(
          fontSize: 40.0,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget updatedAt({bool clickable = true}) {
    if (bookPage == null) {
      return Container();
    }

    final DateTime? updatedAt = bookPage!.updatedAt;

    if (updatedAt == null) {
      return Container();
    }

    String updatedAtStr = "";

    if (DateTime.now().difference(updatedAt).inDays > 60) {
      updatedAtStr = "date_updated_at".tr(
        args: [
          Jiffy(bookPage!.updatedAt).yMMMMEEEEd,
        ],
      );
    } else {
      updatedAtStr = "date_updated_ago".tr(
        args: [Jiffy(bookPage!.updatedAt).fromNow()],
      );
    }

    return InkWell(
      onTap: clickable ? showDatesDialog : null,
      child: Opacity(
        opacity: 0.6,
        child: Text(
          updatedAtStr,
          style: FontsUtils.mainStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void confirmBookDeletion(Illustration illustration, int index) async {
    showCustomModalBottomSheet(
      context: context,
      builder: (context) {
        return Material(
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text(
                    "delete".tr(),
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  trailing: Icon(
                    UniconsLine.check,
                    color: Colors.white,
                  ),
                  tileColor: Color(0xfff55c5c),
                  onTap: () {
                    context.router.pop();
                    deleteIllustration(illustration, index);
                  },
                ),
                ListTile(
                  title: Text("cancel".tr()),
                  trailing: Icon(UniconsLine.times),
                  onTap: context.router.pop,
                ),
              ],
            ),
          ),
        );
      },
      containerWidget: (context, animation, child) {
        return RawKeyboardListener(
          autofocus: true,
          focusNode: _keyboardFocusNode,
          onKey: (keyEvent) {
            if (keyEvent.isKeyPressed(LogicalKeyboardKey.enter)) {
              Navigator.of(context).pop();
              deleteIllustration(illustration, index);
            }
          },
          child: SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 500.0,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 40.0,
                  ),
                  child: Material(
                    clipBehavior: Clip.antiAlias,
                    borderRadius: BorderRadius.circular(12.0),
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void deleteIllustration(Illustration illustration, int index) async {
    setState(() {
      _illustrations.removeAt(index);
    });

    final response = await IllustrationsActions.deleteOne(
      illustrationId: illustration.id,
    );

    if (response.success) {
      return;
    }

    setState(() {
      _illustrations.insert(index, illustration);
    });
  }

  void confirmSelectionDeletion() async {
    showCustomModalBottomSheet(
      context: context,
      builder: (context) {
        return Material(
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text(
                    'confirm'.tr(),
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  trailing: Icon(
                    Icons.check,
                    color: Colors.white,
                  ),
                  tileColor: Color(0xfff55c5c),
                  onTap: () {
                    Navigator.of(context).pop();
                    deleteSelection();
                  },
                ),
                ListTile(
                  title: Text('Cancel'.tr()),
                  trailing: Icon(Icons.close),
                  onTap: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        );
      },
      containerWidget: (context, animation, child) {
        return RawKeyboardListener(
          autofocus: true,
          focusNode: _keyboardFocusNode,
          onKey: (keyEvent) {
            if (keyEvent.isKeyPressed(LogicalKeyboardKey.enter)) {
              Navigator.of(context).pop();
              deleteSelection();
            }
          },
          child: SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 500.0,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 40.0,
                  ),
                  child: Material(
                    clipBehavior: Clip.antiAlias,
                    borderRadius: BorderRadius.circular(12.0),
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void deleteSelection() async {
    _multiSelectedItems.entries.forEach((multiSelectItem) {
      _illustrations.removeWhere((item) => item.id == multiSelectItem.key);
    });

    final duplicatedItems = _multiSelectedItems.values.toList();
    final illustrationIds = _multiSelectedItems.keys.toList();

    setState(() {
      _multiSelectedItems.clear();
      _forceMultiSelect = false;
    });

    final response = await BooksActions.removeIllustrations(
      bookId: bookPage!.id,
      illustrationIds: illustrationIds,
    );

    if (response.hasErrors) {
      Snack.e(
        context: context,
        message: "illustrations_delete_error".tr(),
      );

      _illustrations.addAll(duplicatedItems);
    }
  }

  void fetchBookAndIllustrations() async {
    await fetchBook();
    fetchIllustrations();
  }

  Future fetchBook() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final bookSnap = await FirebaseFirestore.instance
          .collection('books')
          .doc(widget.bookId)
          .get();

      if (!bookSnap.exists) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }

      final bookData = bookSnap.data()!;
      bookData['id'] = bookSnap.id;

      setState(() {
        bookPage = Book.fromJSON(bookData);
        _isLoading = false;
      });
    } catch (error) {
      appLogger.e(error);

      setState(() {
        _hasError = true;
        _isLoading = true;
      });
    }
  }

  void fetchIllustrations() async {
    if (bookPage == null) {
      return;
    }

    final bpIllustrations = bookPage!.illustrations;

    setState(() {
      _isLoading = true;
      _startIndex = 0;
      _endIndex =
          bpIllustrations.length >= _limit ? _limit : bpIllustrations.length;
    });

    try {
      if (bpIllustrations.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      final range = bpIllustrations.getRange(_startIndex, _endIndex);

      for (var bookIllustration in range) {
        final illustrationSnap = await FirebaseFirestore.instance
            .collection('illustrations')
            .doc(bookIllustration.id)
            .get();

        if (!illustrationSnap.exists) {
          continue;
        }

        final illusData = illustrationSnap.data()!;
        illusData['id'] = illustrationSnap.id;

        final illustration = Illustration.fromJSON(illusData);
        _illustrations.add(illustration);
      }

      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      appLogger.e(error);

      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  /// On scroll notifications.
  bool onNotification(ScrollNotification notification) {
    // FAB visibility
    if (notification.metrics.pixels < 50 && _isFabVisible) {
      setState(() {
        _isFabVisible = false;
      });
    } else if (notification.metrics.pixels > 50 && !_isFabVisible) {
      setState(() {
        _isFabVisible = true;
      });
    }

    if (notification.metrics.pixels < notification.metrics.maxScrollExtent) {
      return false;
    }

    // if (_hasNext && !_isLoadingMore) {
    //   fetchMoreIllustrations();
    // }

    return false;
  }

  void onRemoveFromBook({
    required int index,
    required Illustration illustration,
  }) async {
    _processingIllustrations.putIfAbsent(index, () => illustration);
    _illustrations.removeAt(index);

    final response = await BooksActions.removeIllustrations(
      bookId: bookPage!.id,
      illustrationIds: [illustration.id],
    );

    if (response.hasErrors) {
      Snack.e(
        context: context,
        message: "illustrations_remove_error".tr(),
      );

      _processingIllustrations.forEach((pIndex, pIllus) {
        _illustrations.insert(index, pIllus);
      });

      setState(() {
        _processingIllustrations.clear();
      });

      return;
    }

    Snack.s(
      context: context,
      message: "illustrations_remove_success".tr(),
    );

    setState(() {
      _processingIllustrations.clear();
    });
  }

  void onTapIllustrationCard(Illustration illustration) {
    if (_multiSelectedItems.isEmpty && !_forceMultiSelect) {
      navigateToIllustrationPage(illustration);
      return;
    }

    multiSelectIllustration(illustration);
  }

  void navigateToIllustrationPage(Illustration illustration) {
    context.router.root.push(
      IllustrationPageRoute(
        illustrationId: illustration.id,
        illustration: illustration,
      ),
    );
  }

  void multiSelectIllustration(Illustration illustration) {
    final selected = _multiSelectedItems.containsKey(illustration.id);

    if (selected) {
      setState(() {
        _multiSelectedItems.remove(illustration.id);
        _forceMultiSelect = _multiSelectedItems.length > 0;
      });

      return;
    }

    setState(() {
      _multiSelectedItems.putIfAbsent(illustration.id, () => illustration);
    });
  }

  void onPopupMenuItemSelected(
    BookItemAction action,
    int index,
    Illustration illustration,
  ) {
    switch (action) {
      case BookItemAction.delete:
        confirmBookDeletion(illustration, index);
        break;
      case BookItemAction.addToBook:
        showAddToBook(illustration);
        break;
      case BookItemAction.removeFromBook:
        onRemoveFromBook(
          index: index,
          illustration: illustration,
        );
        break;
      default:
    }
  }

  void showAddToBook(Illustration illustration) {
    int flex =
        MediaQuery.of(context).size.width < Constants.maxMobileWidth ? 5 : 3;

    showCustomModalBottomSheet(
      context: context,
      builder: (context) => UserBooks(
        scrollController: ModalScrollController.of(context),
        illustration: illustration,
      ),
      containerWidget: (context, animation, child) {
        return SafeArea(
          child: Row(
            children: [
              Spacer(),
              Expanded(
                flex: flex,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Material(
                    clipBehavior: Clip.antiAlias,
                    borderRadius: BorderRadius.circular(12.0),
                    child: child,
                  ),
                ),
              ),
              Spacer(),
            ],
          ),
        );
      },
    );
  }

  void showDatesDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          titlePadding: EdgeInsets.zero,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  top: 24.0,
                  left: 24.0,
                  right: 24.0,
                  bottom: 12.0,
                ),
                child: Text(
                  "Dates".toUpperCase(),
                  style: FontsUtils.mainStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Divider(
                thickness: 1.5,
                color: stateColors.secondary,
              ),
            ],
          ),
          contentPadding: const EdgeInsets.all(24.0),
          children: [
            Row(
              children: [
                Text("• "),
                createdAt(),
              ],
            ),
            Row(
              children: [
                Text("• "),
                updatedAt(clickable: false),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: DarkElevatedButton(
                onPressed: context.router.pop,
                child: Text(
                  "close".tr(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void uploadAndAddToThisBook() {
    // appUploadManager.pickImage(context);
  }
}
