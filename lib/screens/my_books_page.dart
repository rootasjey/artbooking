import 'package:artbooking/actions/books.dart';
import 'package:artbooking/components/animated_app_icon.dart';
import 'package:artbooking/components/book_card.dart';
import 'package:artbooking/components/main_app_bar.dart';
import 'package:artbooking/components/sliver_edge_padding.dart';
import 'package:artbooking/components/text_rectangle_button.dart';
import 'package:artbooking/state/colors.dart';
import 'package:artbooking/state/user.dart';
import 'package:artbooking/types/book.dart';
import 'package:artbooking/utils/app_logger.dart';
import 'package:artbooking/utils/fonts.dart';
import 'package:artbooking/utils/snack.dart';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:supercharged/supercharged.dart';
import 'package:unicons/unicons.dart';

class MyBooksPage extends StatefulWidget {
  @override
  _MyBooksPageState createState() => _MyBooksPageState();
}

class _MyBooksPageState extends State<MyBooksPage> {
  bool _isLoading = false;
  bool _descending = true;
  bool _hasNext = true;
  bool _isFabVisible = false;
  bool _isLoadingMore = false;
  bool _forceMultiSelect = false;
  bool _isCreating = false;

  DocumentSnapshot? _lastFirestoreDoc;

  final _books = <Book>[];
  final _keyboardFocusNode = FocusNode();

  int _limit = 20;

  Map<String?, Book> _multiSelectedItems = Map();

  ScrollController _scrollController = ScrollController();

  TextEditingController? _newBookNameController;
  String _newBookName = '';
  String _newBookDescription = '';

  @override
  initState() {
    super.initState();
    _newBookNameController = TextEditingController();
    fetchMany();
  }

  @override
  void dispose() {
    _newBookNameController?.dispose();
    super.dispose();
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
              padding: const EdgeInsets.only(bottom: 100.0),
            ),
          ],
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
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              children: [
                Text(
                  "books".tr().toUpperCase(),
                  style: FontsUtils.mainStyle(
                    fontSize: 30.0,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (_isCreating)
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 24.0,
                      top: 12.0,
                    ),
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          ),
          defaultActionsToolbar(),
          multiSelectToolbar(),
        ]),
      ),
    );
  }

  Widget body() {
    if (_isLoading) {
      return SliverList(
        delegate: SliverChildListDelegate.fixed([
          Padding(
            padding: const EdgeInsets.only(top: 100.0),
            child: AnimatedAppIcon(textTitle: "loading_books".tr()),
          ),
        ]),
      );
    }

    if (_books.isEmpty) {
      return emptyView();
    }

    return gridView();
  }

  Widget createButton() {
    return TextRectangleButton(
      onPressed: showBookCreationDialog,
      icon: Icon(UniconsLine.plus),
      label: Text('create'.tr()),
      primary: Colors.black38,
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
        createButton(),
        multiSelectButton(),
        sortButton(),
      ],
    );
  }

  Widget fab() {
    if (!_isFabVisible) {
      return FloatingActionButton(
        onPressed: fetchMany,
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

  Widget multiSelectButton() {
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

  Widget emptyView() {
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
                  "lonely_there".tr(),
                  style: TextStyle(
                    fontSize: 32.0,
                    color: stateColors.primary,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 12.0,
                ),
                child: Opacity(
                  opacity: 0.6,
                  child: Text(
                    "books_none_created".tr(),
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: showBookCreationDialog,
                icon: Icon(UniconsLine.book_medical),
                label: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    "create".tr(),
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
            final book = _books.elementAt(index);
            final selected = _multiSelectedItems.containsKey(book.id);

            return BookCard(
              book: book,
              selected: selected,
              selectionMode: selectionMode,
              onBeforeDelete: () {
                setState(() {
                  _books.removeAt(index);
                });
              },
              onAfterDelete: (response) {
                if (response.success) {
                  return;
                }

                setState(() {
                  _books.insert(index, book);
                });
              },
              onBeforePressed: () {
                if (_multiSelectedItems.isEmpty && !_forceMultiSelect) {
                  return false;
                }

                if (selected) {
                  setState(() {
                    _multiSelectedItems.remove(book.id);
                    _forceMultiSelect = _multiSelectedItems.length > 0;
                  });
                } else {
                  setState(() {
                    _multiSelectedItems.putIfAbsent(book.id, () => book);
                  });
                }

                return true;
              },
              onLongPress: (selected) {
                if (selected) {
                  setState(() {
                    _multiSelectedItems.remove(book.id);
                  });
                  return;
                }

                setState(() {
                  _multiSelectedItems.putIfAbsent(book.id, () => book);
                });
              },
            );
          },
          childCount: _books.length,
        ),
      ),
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
          label: Text(
            "clear_selection".tr(),
          ),
        ),
        TextButton.icon(
          onPressed: () {
            _books.forEach((illustration) {
              _multiSelectedItems.putIfAbsent(
                  illustration.id, () => illustration);
            });

            setState(() {});
          },
          icon: Icon(Icons.select_all),
          label: Text("select_all".tr()),
        ),
        TextButton.icon(
          onPressed: confirmDeletion,
          style: TextButton.styleFrom(
            primary: Colors.red,
          ),
          icon: Icon(Icons.delete_outline),
          label: Text("delete".tr()),
        ),
      ],
    );
  }

  Widget sortButton() {
    return TextRectangleButton(
      onPressed: () {},
      icon: Icon(UniconsLine.sort),
      label: Text('sort'.tr()),
      primary: Colors.black38,
    );
  }

  void confirmDeletion() async {
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
                    "confirm".tr(),
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
                  title: Text("cancel".tr()),
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
      _books.removeWhere((item) => item.id == multiSelectItem.key);
    });

    final copyItems = _multiSelectedItems.values.toList();
    final booksIds = _multiSelectedItems.keys.toList();

    setState(() {
      _multiSelectedItems.clear();
      _forceMultiSelect = false;
    });

    final response = await BooksActions.deleteMany(
      bookIds: booksIds,
    );

    if (response.hasErrors) {
      Snack.e(
        context: context,
        message: "illustrations_delete_error".tr(),
      );

      _books.addAll(copyItems);
    }
  }

  void fetchMany() async {
    setState(() {
      _isLoading = true;
      _hasNext = true;
      _books.clear();
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('books')
          .where('user.id', isEqualTo: stateUser.userAuth!.uid)
          .orderBy('createdAt', descending: _descending)
          .limit(_limit)
          .get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          _isLoading = false;
          _hasNext = false;
        });

        return;
      }

      snapshot.docs.forEach((doc) {
        final data = doc.data();
        data['id'] = doc.id;

        _books.add(Book.fromJSON(data));
      });

      setState(() {
        _lastFirestoreDoc = snapshot.docs.last;
        _hasNext = snapshot.docs.length == _limit;
      });
    } catch (error) {
      appLogger.e(error);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void fetchManyMore() async {
    if (!_hasNext || _lastFirestoreDoc == null) {
      return;
    }

    _isLoadingMore = true;

    try {
      final userAuth = FirebaseAuth.instance.currentUser;

      if (userAuth == null) {
        throw Exception("User is not authenticated.");
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('books')
          .where('user.id', isEqualTo: userAuth.uid)
          .orderBy('createdAt', descending: _descending)
          .limit(_limit)
          .startAfterDocument(_lastFirestoreDoc!)
          .get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          _hasNext = false;
          _isLoadingMore = false;
        });

        return;
      }

      snapshot.docs.forEach((doc) {
        final data = doc.data();
        data['id'] = doc.id;

        _books.add(Book.fromJSON(data));
      });

      setState(() {
        _isLoadingMore = false;
        _lastFirestoreDoc = snapshot.docs.last;
        _hasNext = snapshot.docs.length == _limit;
      });
    } catch (error) {
      appLogger.e(error);
    }
  }

  void fetchOne(String? bookId) async {
    try {
      final bookSnap = await FirebaseFirestore.instance
          .collection('books')
          .doc(bookId)
          .get();

      final bookData = bookSnap.data()!;
      bookData['id'] = bookSnap.id;

      final book = Book.fromJSON(bookData);

      setState(() {
        _books.add(book);
      });
    } catch (error) {
      appLogger.e(error);
    }
  }

  void createBook() async {
    setState(() {
      _isCreating = true;
    });

    final response = await BooksActions.createOne(
      name: _newBookName,
      description: _newBookDescription,
    );

    setState(() => _isCreating = false);

    if (!response.success) {
      Snack.e(
        context: context,
        message: "book_creation_error".tr(),
      );

      return;
    }

    Snack.s(
      context: context,
      message: "book_creation_success".tr(),
    );

    fetchOne(response.bookId);
  }

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

    if (_hasNext && !_isLoadingMore) {
      fetchManyMore();
    }

    return false;
  }

  void showBookCreationDialog() {
    showDialog(
      context: context,
      builder: (_) => SimpleDialog(
        title: Text("book_create".tr()),
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: 25.0,
              right: 25.0,
              top: 32.0,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints.tight(Size(250.0, 80)),
              child: TextField(
                autofocus: true,
                controller: _newBookNameController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: "title".tr(),
                  labelStyle: TextStyle(color: stateColors.primary),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: stateColors.primary,
                      width: 2.0,
                    ),
                  ),
                ),
                onChanged: (newValue) {
                  _newBookName = newValue;
                },
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 25.0,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints.tight(Size(250.0, 80)),
              child: TextField(
                decoration: InputDecoration(
                  labelText: "description".tr(),
                  labelStyle: TextStyle(color: stateColors.primary),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: stateColors.primary,
                      width: 2.0,
                    ),
                  ),
                ),
                onChanged: (newValue) {
                  _newBookDescription = newValue;
                },
                onSubmitted: (value) {
                  createBook();
                  context.router.pop();
                },
              ),
            ),
          ),
          Container(
            height: 80.0,
            padding: EdgeInsets.only(
              top: 28.0,
              left: 24.0,
              right: 24.0,
            ),
            child: Wrap(
              spacing: 10.0,
              runSpacing: 10.0,
              alignment: WrapAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: context.router.pop,
                  icon: Icon(UniconsLine.times),
                  label: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12.0,
                      horizontal: 12.0,
                    ),
                    child: Opacity(
                      opacity: 1.0,
                      child: Text('cancel'.tr()),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    primary: stateColors.foreground,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    createBook();
                    context.router.pop();
                  },
                  icon: Icon(UniconsLine.plus),
                  label: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12.0,
                      horizontal: 12.0,
                    ),
                    child: Text(
                      "create".tr(),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: stateColors.validation,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
