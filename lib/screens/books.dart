import 'package:artbooking/actions/illustrations.dart';
import 'package:artbooking/components/book_item.dart';
import 'package:artbooking/components/full_page_loading.dart';
import 'package:artbooking/components/sliver_appbar_header.dart';
import 'package:artbooking/components/upload_manager.dart';
import 'package:artbooking/screens/signin.dart';
import 'package:artbooking/state/colors.dart';
import 'package:artbooking/types/book.dart';
import 'package:artbooking/types/enums.dart';
import 'package:artbooking/utils/snack.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:supercharged/supercharged.dart';

class Books extends StatefulWidget {
  @override
  _BooksState createState() => _BooksState();
}

class _BooksState extends State<Books> {
  bool isLoading;
  bool descending = true;
  bool hasNext = true;
  bool isFabVisible = false;
  bool isLoadingMore = false;
  bool forceMultiSelect = false;

  DocumentSnapshot lastDoc;

  final booksList = <Book>[];
  final keyboardFocusNode = FocusNode();

  int limit = 20;

  Map<String, Book> multiSelectedItems = Map();

  ScrollController scrollController = ScrollController();

  @override
  initState() {
    super.initState();
    fetch();
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
            SliverAppHeader(),
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
          Text(
            'Books',
            style: TextStyle(
              fontSize: 80.0,
              fontWeight: FontWeight.w900,
            ),
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
            child: FullPageLoading(),
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
      children: [
        TextButton.icon(
          onPressed: () {
            setState(() {
              forceMultiSelect = !forceMultiSelect;
            });
          },
          icon: Icon(Icons.select_all),
          label: Text(
            'Multi-select',
          ),
          style: forceMultiSelect
              ? TextButton.styleFrom(primary: Colors.lightGreen)
              : TextButton.styleFrom(),
        ),
        TextButton.icon(
          onPressed: () {},
          icon: Icon(Icons.sort),
          label: Text(
            'Sort',
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
          Padding(
            padding: const EdgeInsets.only(
              bottom: 12.0,
            ),
            child: Text(
              "It's lonely there",
              style: TextStyle(
                fontSize: 40.0,
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
                "You haven't created any book yet",
                style: TextStyle(
                  fontSize: 20.0,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: OutlinedButton.icon(
              onPressed: () {
                appUploadManager.pickImage(context);
              },
              icon: Icon(Icons.library_add),
              label: Text(
                "create",
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
            ),
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

            return BookItem(
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

    final response = await deleteIllustrationsDocuments(
      imagesIds: booksIds,
    );

    if (!response.success) {
      showSnack(
        context: context,
        message: "Sorry, there was an issue while deleting your illustrations. "
            "Try again or contact us if the issue persists.",
        type: SnackType.error,
      );

      booksList.addAll(copyItems);
    }
  }

  void fetch() async {
    setState(() {
      isLoading = true;
    });

    try {
      final userAuth = FirebaseAuth.instance.currentUser;

      if (userAuth == null) {
        debugPrint("User is not authenticated.");

        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => Signin()),
          );
        });

        setState(() {
          isLoading = false;
        });
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('books')
          .where('user.id', isEqualTo: userAuth.uid)
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
}
