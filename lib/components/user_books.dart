import 'package:artbooking/actions/books.dart';
import 'package:artbooking/state/user.dart';
import 'package:artbooking/types/book.dart';
import 'package:artbooking/types/illustration/illustration.dart';
import 'package:artbooking/utils/flash_helper.dart';
import 'package:artbooking/utils/snack.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';
import 'package:supercharged/supercharged.dart';

class UserBooks extends StatefulWidget {
  final ScrollController scrollController;
  final Illustration illustration;

  UserBooks({this.scrollController, @required this.illustration});

  @override
  _UserBooksState createState() => _UserBooksState();
}

class _UserBooksState extends State<UserBooks> {
  bool hasErrors = false;
  bool isLoading = false;
  bool isLoaded = false;
  bool hasNext = false;
  bool isLoadingMore = false;

  DocumentSnapshot lastDoc;

  Error error;

  final limit = 10;

  List<Book> books = [];

  String newBookName = '';
  String newBookDescription = '';

  @override
  Widget build(BuildContext context) {
    return Material(
      child: body(),
    );
  }

  Widget body() {
    List<Widget> tiles = [];

    if (hasErrors) {
      tiles.add(errorTileList(onPressed: () async {
        await fetchBooks();
        setState(() {
          isLoaded = true;
        });
      }));
    }

    if (books.length == 0 && !isLoading && !isLoaded) {
      tiles.add(LinearProgressIndicator());

      fetchBooks().then((_) {
        setState(() {
          isLoaded = true;
        });
      });
    }

    if (books.length > 0) {
      for (var list in books) {
        tiles.add(tileList(list));
      }
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollNotif) {
        if (scrollNotif.metrics.pixels < scrollNotif.metrics.maxScrollExtent) {
          return false;
        }

        if (hasNext && !isLoadingMore) {
          fetchMoreBooks().then((_) {
            setState(() {
              isLoadingMore = false;
            });
          });
        }

        return false;
      },
      child: ListView(
        shrinkWrap: true,
        controller: widget.scrollController,
        children: <Widget>[
          createListButton(),
          Divider(
            thickness: 2.0,
          ),
          ...tiles
        ],
      ),
    );
  }

  Widget createListButton() {
    return ListTile(
      onTap: () async {
        final isBookCreated = await showCreateBookDialog(context);

        if (isBookCreated != null && isBookCreated) {
          context.router.pop();
        }
      },
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Opacity(
            opacity: 0.6,
            child: Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: Icon(Icons.add),
            ),
          ),
          Text(
            'Create list',
            textAlign: TextAlign.start,
            style: TextStyle(
              fontSize: 20.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget errorTileList({Function onPressed}) {
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: Column(
        children: <Widget>[
          Text('There was an issue while loading your lists.'),
          TextButton(
            onPressed: () {
              if (onPressed != null) {
                onPressed();
              }
            },
            child: Padding(
              padding: EdgeInsets.all(5.0),
              child: Text('Retry'),
            ),
          )
        ],
      ),
    );
  }

  Widget tileList(Book book) {
    return ListTile(
      onTap: () {
        addQuoteToList(
          bookId: book.id,
        );

        context.router.pop();
      },
      title: Center(
        child: Text(
          book.name,
        ),
      ),
    );
  }

  void addQuoteToList({String bookId}) async {
    Snack.s(
      context: context,
      title: "Add",
      message: "The illustration has been successfully added to your book!",
    );

    final response = await BooksActions.addIllustrations(
      bookId: bookId,
      illustrationIds: [widget.illustration.id],
    );

    if (response.hasErrors) {
      Snack.e(
        context: context,
        message: "There was an error while adding "
            "the illustration to the book.",
      );

      return;
    }
  }

  void createBookAndAddIllustration(BuildContext context) async {
    FlashHelper.showProgress(
      context,
      title: "Create",
      progressId: 'create_book',
      message: "Creating book $newBookName...",
      icon: Icon(UniconsLine.plus),
      duration: 60.seconds,
    );

    final createdList = await BooksActions.createOne(
      name: newBookName,
      description: newBookDescription,
      illustrationIds: [widget.illustration.id],
    );

    FlashHelper.dismissProgress(id: 'create_book');

    if (createdList == null) {
      Snack.e(
        context: context,
        message: "There was and issue while creating the book. "
            "Try again later or contact us if the problem persists.",
      );

      return;
    }

    Snack.e(
      context: context,
      title: "Create",
      message: "Your list $newBookName has been successfully created!",
    );
  }

  Future fetchBooks() async {
    isLoading = true;

    try {
      books.clear();

      final snapshot = await FirebaseFirestore.instance
          .collection('books')
          .where('user.id', isEqualTo: stateUser.userAuth.uid)
          .limit(limit)
          .orderBy('updatedAt', descending: true)
          .get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          hasNext = false;
          isLoading = false;
        });

        return;
      }

      snapshot.docs.forEach((doc) {
        final data = doc.data();
        data['id'] = doc.id;

        final book = Book.fromJSON(data);
        books.add(book);
      });

      lastDoc = snapshot.docs.last;

      setState(() {
        hasNext = snapshot.docs.length == limit;
        isLoading = false;
      });
    } catch (err) {
      debugPrint(err.toString());

      setState(() {
        isLoading = false;
        error = err;
        hasErrors = false;
      });

      Snack.e(
        context: context,
        message: 'Cannot retrieve your books right now',
      );
    }
  }

  Future fetchMoreBooks() async {
    isLoadingMore = true;

    try {
      final userAuth = stateUser.userAuth;

      if (userAuth == null) {
        return;
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('books')
          .where('user.id', isEqualTo: stateUser.userAuth.uid)
          .limit(limit)
          .orderBy('updatedAt', descending: true)
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

        final book = Book.fromJSON(data);
        books.add(book);
      });

      lastDoc = snapshot.docs.last;

      setState(() {
        hasNext = snapshot.docs.length == limit;
        isLoadingMore = false;
      });
    } catch (err) {
      debugPrint(err.toString());

      setState(() {
        isLoadingMore = false;
        error = err;
        hasErrors = false;
      });

      Snack.e(
        context: context,
        message: 'Cannot retrieve more books.',
      );
    }
  }

  Future<bool> showCreateBookDialog(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text('Create new book'),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 20.0,
            vertical: 25.0,
          ),
          children: <Widget>[
            TextField(
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Name',
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(width: 2.0),
                ),
              ),
              textInputAction: TextInputAction.next,
              onChanged: (newValue) {
                newBookName = newValue;
              },
            ),
            Padding(
              padding: EdgeInsets.only(top: 10.0),
            ),
            TextField(
              decoration: InputDecoration(
                labelText: 'Description',
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(width: 2.0),
                ),
              ),
              onChanged: (newValue) {
                newBookDescription = newValue;
              },
              onSubmitted: (_) {
                createBookAndAddIllustration(context);
                return Navigator.of(context).pop(true);
                // context.router.pop();
              },
            ),
            Padding(
              padding: EdgeInsets.only(top: 20.0),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                TextButton(
                  onPressed: () {
                    return Navigator.of(context).pop(false);
                    // context.router.pop();
                  },
                  child: Text(
                    'Cancel',
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.green,
                  ),
                  onPressed: () {
                    createBookAndAddIllustration(context);
                    return Navigator.of(context).pop(true);
                  },
                  child: Text(
                    'Create',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          ],
        );
      },
    );
  }
}
