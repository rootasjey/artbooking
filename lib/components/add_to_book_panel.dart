import 'package:artbooking/actions/books.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/book/book.dart';
import 'package:artbooking/types/illustration/illustration.dart';
import 'package:beamer/beamer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash/src/flash_helper.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';
import 'package:supercharged/supercharged.dart';

/// List of an user's books.
class AddToBookPanel extends StatefulWidget {
  AddToBookPanel({
    this.scrollController,
    required this.illustrations,
  });

  final ScrollController? scrollController;
  final List<Illustration> illustrations;

  @override
  _AddToBookPanelState createState() => _AddToBookPanelState();
}

class _AddToBookPanelState extends State<AddToBookPanel> {
  bool _hasErrors = false;
  bool _loading = false;
  bool _loaded = false;
  bool _hasNext = false;
  bool _loadingMore = false;

  late DocumentSnapshot _lastDocument;

  final _limit = 10;

  List<Book> _books = [];

  String _newBookName = '';
  String _newBookDescription = '';

  @override
  Widget build(BuildContext context) {
    return Material(
      child: body(),
    );
  }

  Widget body() {
    List<Widget> tiles = [];

    if (_hasErrors) {
      tiles.add(errorTileList(onPressed: () async {
        await fetchBooks();
        setState(() {
          _loaded = true;
        });
      }));
    }

    if (_books.length == 0 && !_loading && !_loaded) {
      tiles.add(LinearProgressIndicator());

      fetchBooks().then((_) {
        setState(() {
          _loaded = true;
        });
      });
    }

    if (_books.length > 0) {
      for (var list in _books) {
        tiles.add(tileList(list));
      }
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollNotif) {
        if (scrollNotif.metrics.pixels < scrollNotif.metrics.maxScrollExtent) {
          return false;
        }

        if (_hasNext && !_loadingMore) {
          fetchMoreBooks().then((_) {
            setState(() {
              _loadingMore = false;
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
          Beamer.of(context).popRoute();
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

  Widget errorTileList({Function? onPressed}) {
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
        addIllustrationToBook(
          bookId: book.id,
        );

        Beamer.of(context).popRoute();
      },
      title: Center(
        child: Text(
          book.name,
        ),
      ),
    );
  }

  void addIllustrationToBook({required String bookId}) async {
    context.showSuccessBar(
      icon: Icon(UniconsLine.plus),
      content:
          Text("The illustration has been successfully added to your book."),
    );

    final response = await BooksActions.addIllustrations(
      bookId: bookId,
      illustrationIds: widget.illustrations.map((x) => x.id).toList(),
    );

    if (response.hasErrors) {
      context.showErrorBar(
        icon: Icon(UniconsLine.exclamation_triangle),
        content: Text(
          "There was an error while adding the illustration to the book.",
        ),
      );

      return;
    }
  }

  void createBookAndAddIllustration(BuildContext context) async {
    Utilities.flash.showProgress(
      context,
      title: "Create",
      progressId: 'create_book',
      message: "Creating book $_newBookName...",
      icon: Icon(UniconsLine.plus),
      duration: 60.seconds,
    );

    final createdList = await BooksActions.createOne(
      name: _newBookName,
      description: _newBookDescription,
      illustrationIds: widget.illustrations.map((x) => x.id).toList(),
    );

    Utilities.flash.dismissProgress(id: 'create_book');

    if (!createdList.success) {
      context.showErrorBar(
        content: Text(
          "There was and issue while creating the book. "
          "Try again later or contact us if the problem persists.",
        ),
      );

      return;
    }

    context.showSuccessBar(
      icon: Icon(UniconsLine.check),
      content: Text("Your list $_newBookName has been successfully created."),
    );
  }

  Future fetchBooks() async {
    setState(() {
      _loading = true;
    });

    try {
      _books.clear();

      final snapshot = await FirebaseFirestore.instance
          .collection('books')
          .where('user_id', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
          .limit(_limit)
          .orderBy('updated_at', descending: true)
          .get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          _hasNext = false;
          _loading = false;
        });

        return;
      }

      snapshot.docs.forEach((doc) {
        final data = doc.data();
        data['id'] = doc.id;

        final book = Book.fromMap(data);
        _books.add(book);
      });

      _lastDocument = snapshot.docs.last;

      setState(() {
        _hasNext = snapshot.docs.length == _limit;
        _loading = false;
      });
    } catch (error) {
      Utilities.logger.e(error);

      setState(() {
        _loading = false;
        _hasErrors = false;
      });

      context.showErrorBar(
        content: Text("Cannot retrieve your books right now"),
      );
    }
  }

  Future fetchMoreBooks() async {
    setState(() {
      _loadingMore = true;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('books')
          .where('user_id', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
          .limit(_limit)
          .orderBy('updated_at', descending: true)
          .startAfterDocument(_lastDocument)
          .get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          _hasNext = false;
          _loadingMore = false;
        });

        return;
      }

      snapshot.docs.forEach((doc) {
        final data = doc.data();
        data['id'] = doc.id;

        final book = Book.fromMap(data);
        _books.add(book);
      });

      _lastDocument = snapshot.docs.last;

      setState(() {
        _hasNext = snapshot.docs.length == _limit;
        _loadingMore = false;
      });
    } catch (error) {
      Utilities.logger.e(error);

      setState(() {
        _loadingMore = false;
        _hasErrors = false;
      });

      context.showErrorBar(
        content: Text("Cannot retrieve more books"),
      );
    }
  }

  Future<bool?> showCreateBookDialog(BuildContext context) {
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
                _newBookName = newValue;
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
                _newBookDescription = newValue;
              },
              onSubmitted: (_) {
                createBookAndAddIllustration(context);
                return Navigator.of(context).pop(true);
                // Beamer.of(context).popRoute();
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
                    // Beamer.of(context).popRoute();
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
