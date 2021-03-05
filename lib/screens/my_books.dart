import 'package:artbooking/actions/books.dart';
import 'package:artbooking/components/animated_app_icon.dart';
import 'package:artbooking/components/book_card.dart';
import 'package:artbooking/components/default_app_bar.dart';
import 'package:artbooking/state/colors.dart';
import 'package:artbooking/state/user.dart';
import 'package:artbooking/types/book.dart';
import 'package:artbooking/utils/fonts.dart';
import 'package:artbooking/utils/snack.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:supercharged/supercharged.dart';
import 'package:unicons/unicons.dart';

class MyBooks extends StatefulWidget {
  @override
  _MyBooksState createState() => _MyBooksState();
}

class _MyBooksState extends State<MyBooks> {
  bool isLoading;
  bool descending = true;
  bool hasNext = true;
  bool isFabVisible = false;
  bool isLoadingMore = false;
  bool forceMultiSelect = false;
  bool isCreating = false;

  DocumentSnapshot lastDoc;

  final booksList = <Book>[];
  final keyboardFocusNode = FocusNode();

  int limit = 20;

  Map<String, Book> multiSelectedItems = Map();

  ScrollController scrollController = ScrollController();

  TextEditingController newBookNameController;
  String newBookName = '';
  String newBookDescription = '';

  @override
  initState() {
    super.initState();
    newBookNameController = TextEditingController();
    fetch();
  }

  @override
  void dispose() {
    newBookNameController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: isFabVisible
          ? FloatingActionButton(
              onPressed: () {
                scrollController.animateTo(
                  0.0,
                  duration: 1.seconds,
                  curve: Curves.easeOut,
                );
              },
              backgroundColor: stateColors.accent,
              foregroundColor: Colors.white,
              child: Icon(Icons.arrow_upward),
            )
          : null,
      body: NotificationListener<ScrollNotification>(
        onNotification: (scrollNotification) {
          // FAB visibility
          if (scrollNotification.metrics.pixels < 50 && isFabVisible) {
            setState(() {
              isFabVisible = false;
            });
          } else if (scrollNotification.metrics.pixels > 50 && !isFabVisible) {
            setState(() {
              isFabVisible = true;
            });
          }

          if (scrollNotification.metrics.pixels <
              scrollNotification.metrics.maxScrollExtent) {
            return false;
          }

          if (hasNext && !isLoadingMore) {
            fetchMore();
          }

          return false;
        },
        child: CustomScrollView(
          controller: scrollController,
          slivers: <Widget>[
            DefaultAppBar(),
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
        top: 40.0,
        left: 50.0,
      ),
      sliver: SliverList(
        delegate: SliverChildListDelegate.fixed([
          Row(
            children: [
              Text(
                'Books',
                style: FontsUtils.boldTitleStyle(),
              ),
              if (isCreating)
                Padding(
                  padding: const EdgeInsets.only(
                    left: 24.0,
                    top: 12.0,
                  ),
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
          defaultActionsToolbar(),
          multiSelectToolbar(),
        ]),
      ),
    );
  }

  Widget body() {
    if (isLoading) {
      return SliverList(
        delegate: SliverChildListDelegate.fixed([
          Padding(
            padding: const EdgeInsets.only(top: 100.0),
            child: AnimatedAppIcon(
              textTitle: "Loading your books...",
            ),
          ),
        ]),
      );
    }

    if (booksList.isEmpty) {
      return emptyView();
    }

    return gridView();
  }

  Widget defaultActionsToolbar() {
    if (multiSelectedItems.isNotEmpty) {
      return Container();
    }

    return Wrap(
      spacing: 12.0,
      runSpacing: 12.0,
      children: [
        OutlinedButton.icon(
          onPressed: () {
            setState(() {
              forceMultiSelect = !forceMultiSelect;
            });
          },
          icon: Padding(
            padding: const EdgeInsets.only(bottom: 6.0),
            child: Icon(UniconsLine.layers_alt),
          ),
          label: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              'Multi-select',
            ),
          ),
          style: forceMultiSelect
              ? TextButton.styleFrom(primary: Colors.lightGreen)
              : TextButton.styleFrom(),
        ),
        OutlinedButton.icon(
          onPressed: () {},
          icon: Padding(
            padding: const EdgeInsets.only(bottom: 6.0),
            child: Icon(UniconsLine.sort),
          ),
          label: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              'Sort',
            ),
          ),
        ),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 12.0,
                ),
                child: Text(
                  "It's lonely there",
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
                    "You haven't created any book yet.",
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
                    "create",
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
    final selectionMode = forceMultiSelect || multiSelectedItems.isNotEmpty;

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
            final book = booksList.elementAt(index);
            final selected = multiSelectedItems.containsKey(book.id);

            return BookCard(
              book: book,
              selected: selected,
              selectionMode: selectionMode,
              onBeforeDelete: () {
                setState(() {
                  booksList.removeAt(index);
                });
              },
              onAfterDelete: (response) {
                if (response.success) {
                  return;
                }

                setState(() {
                  booksList.insert(index, book);
                });
              },
              onBeforePressed: () {
                if (multiSelectedItems.isEmpty && !forceMultiSelect) {
                  return false;
                }

                if (selected) {
                  setState(() {
                    multiSelectedItems.remove(book.id);
                    forceMultiSelect = multiSelectedItems.length > 0;
                  });
                } else {
                  setState(() {
                    multiSelectedItems.putIfAbsent(book.id, () => book);
                  });
                }

                return true;
              },
              onLongPress: (selected) {
                if (selected) {
                  setState(() {
                    multiSelectedItems.remove(book.id);
                  });
                  return;
                }

                setState(() {
                  multiSelectedItems.putIfAbsent(book.id, () => book);
                });
              },
            );
          },
          childCount: booksList.length,
        ),
      ),
    );
  }

  Widget multiSelectToolbar() {
    if (multiSelectedItems.isEmpty) {
      return Container();
    }

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Opacity(
          opacity: 0.6,
          child: Text(
            "${multiSelectedItems.length} selected",
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
              multiSelectedItems.clear();
            });
          },
          icon: Icon(Icons.border_clear),
          label: Text(
            'Clear selection',
          ),
        ),
        TextButton.icon(
          onPressed: () {
            booksList.forEach((illustration) {
              multiSelectedItems.putIfAbsent(
                  illustration.id, () => illustration);
            });

            setState(() {});
          },
          icon: Icon(Icons.select_all),
          label: Text(
            'Select all',
          ),
        ),
        TextButton.icon(
          onPressed: confirmDeletion,
          style: TextButton.styleFrom(
            primary: Colors.red,
          ),
          icon: Icon(Icons.delete_outline),
          label: Text(
            'Delete',
          ),
        ),
      ],
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
                    'Confirm',
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
                  title: Text('Cancel'),
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
          focusNode: keyboardFocusNode,
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
    multiSelectedItems.entries.forEach((multiSelectItem) {
      booksList.removeWhere((item) => item.id == multiSelectItem.key);
    });

    final copyItems = multiSelectedItems.values.toList();
    final booksIds = multiSelectedItems.keys.toList();

    setState(() {
      multiSelectedItems.clear();
      forceMultiSelect = false;
    });

    final response = await BooksActions.deleteMany(
      bookIds: booksIds,
    );

    if (response.hasErrors) {
      Snack.e(
        context: context,
        message: "Sorry, there was an issue while deleting your illustrations. "
            "Try again or contact us if the issue persists.",
      );

      booksList.addAll(copyItems);
    }
  }

  void fetch() async {
    setState(() {
      isLoading = true;
      hasNext = true;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('books')
          .where('user.id', isEqualTo: stateUser.userAuth.uid)
          .orderBy('createdAt', descending: descending)
          .limit(limit)
          .get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          isLoading = false;
          hasNext = false;
        });

        return;
      }

      snapshot.docs.forEach((doc) {
        final data = doc.data();
        data['id'] = doc.id;

        booksList.add(Book.fromJSON(data));
      });

      setState(() {
        isLoading = false;
        lastDoc = snapshot.docs.last;
        hasNext = snapshot.docs.length == limit;
      });
    } catch (error) {
      debugPrint(error.toString());

      setState(() {
        isLoading = false;
      });
    }
  }

  void fetchMore() async {
    if (!hasNext || lastDoc == null) {
      return;
    }

    isLoadingMore = true;

    try {
      final userAuth = FirebaseAuth.instance.currentUser;

      if (userAuth == null) {
        throw Exception("User is not authenticated.");
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('books')
          .where('user.id', isEqualTo: userAuth.uid)
          .orderBy('createdAt', descending: descending)
          .limit(limit)
          .startAfterDocument(lastDoc)
          .get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          hasNext = false;
          isLoadingMore = false;
        });

        return;
      }

      snapshot.docs.forEach((doc) {
        final data = doc.data();
        data['id'] = doc.id;

        booksList.add(Book.fromJSON(data));
      });

      setState(() {
        isLoading = false;
        lastDoc = snapshot.docs.last;
        hasNext = snapshot.docs.length == limit;
        isLoadingMore = false;
      });
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  void createBook() async {
    setState(() {
      isCreating = true;
    });

    final response = await BooksActions.createOne(
      name: newBookName,
      description: newBookDescription,
    );

    setState(() {
      isCreating = true;
    });

    if (!response.success) {
      Snack.e(
        context: context,
        message: "Sorry, there wasan error while creating your book."
            " Please try again later.",
      );

      return;
    }

    Snack.s(
      context: context,
      message: "Your book has been successfully created!",
    );

    fetch();
  }

  void showBookCreationDialog() {
    showDialog(
      context: context,
      builder: (_) => SimpleDialog(
        title: Text("Create book"),
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
                controller: newBookNameController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Name',
                  labelStyle: TextStyle(color: stateColors.primary),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: stateColors.primary,
                      width: 2.0,
                    ),
                  ),
                ),
                onChanged: (newValue) {
                  newBookName = newValue;
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
                  labelText: 'Description',
                  labelStyle: TextStyle(color: stateColors.primary),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: stateColors.primary,
                      width: 2.0,
                    ),
                  ),
                ),
                onChanged: (newValue) {
                  newBookDescription = newValue;
                },
                onSubmitted: (value) {
                  context.router.pop();
                  createBook();
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
                      child: Text(
                        'Cancel',
                      ),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    primary: stateColors.foreground,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    context.router.pop();
                    createBook();
                  },
                  icon: Icon(UniconsLine.plus),
                  label: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12.0,
                      horizontal: 12.0,
                    ),
                    child: Text(
                      "Create",
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
