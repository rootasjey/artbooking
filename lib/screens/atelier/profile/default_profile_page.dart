import 'package:artbooking/components/loading_view.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/router/locations/atelier_location.dart';
import 'package:artbooking/router/locations/home_location.dart';
import 'package:artbooking/router/navigation_state_helper.dart';
import 'package:artbooking/screens/atelier/profile/default_profile_page_body.dart';
import 'package:artbooking/types/book/book.dart';
import 'package:artbooking/types/firestore/document_snapshot_map.dart';
import 'package:artbooking/types/firestore/query_doc_snap_map.dart';
import 'package:artbooking/types/firestore/query_snap_map.dart';
import 'package:artbooking/types/illustration/illustration.dart';
import 'package:artbooking/types/json_types.dart';
import 'package:artbooking/types/user/user_firestore.dart';
import 'package:beamer/beamer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flash/flash.dart';
import 'package:flutter/material.dart';

class DefaultProfilePage extends StatefulWidget {
  const DefaultProfilePage({
    Key? key,
    required this.userId,
    required this.isOwner,
    this.onCreateProfilePage,
    this.isMobileSize = false,
  }) : super(key: key);

  final String userId;
  final bool isOwner;
  final bool isMobileSize;
  final void Function()? onCreateProfilePage;

  @override
  State<DefaultProfilePage> createState() => _DefaultProfilePageState();
}

class _DefaultProfilePageState extends State<DefaultProfilePage> {
  /// This widget is fetching data if true.
  bool _loading = false;

  /// Show profile page username if true, and if it's a profile page type.
  bool _showAppBarTitle = false;

  /// User's books list.
  final List<Book> _books = [];

  /// User's illustrations list.
  final List<Illustration> _illustrations = [];

  /// Page scroll controller.
  final ScrollController _pageScrollController = ScrollController();

  /// Profile page's owner.
  UserFirestore _userFirestore = UserFirestore.empty();

  @override
  void initState() {
    super.initState();
    fetch();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        body: Center(
          child: LoadingView(
            title: Text(
              "loading".tr(),
              style: Utilities.fonts.body(
                fontSize: 28.0,
                fontWeight: FontWeight.w700,
              ),
            ),
            sliver: false,
          ),
        ),
      );
    }

    return DefaultProfilePageBody(
      books: _books,
      illustrations: _illustrations,
      isMobileSize: widget.isMobileSize,
      onPageScroll: onPageScroll,
      onTapBook: onTapBook,
      onTapIllustration: onTapIllustration,
      scrollController: _pageScrollController,
      showAppBarTitle: _showAppBarTitle,
      userFirestore: _userFirestore,
    );
  }

  void fetch() async {
    setState(() {
      _loading = true;
    });

    await Future.wait([
      fetchBooks(),
      fetchIllustrations(),
      fetchUser(),
    ]);

    setState(() {
      _loading = false;
    });
  }

  Future fetchBooks() async {
    try {
      final QuerySnapMap snapshot = await FirebaseFirestore.instance
          .collection("books")
          .where("user_id", isEqualTo: widget.userId)
          .where("visibility", isEqualTo: "public")
          .limit(6)
          .get();

      for (final QueryDocSnapMap doc in snapshot.docs) {
        final Json map = doc.data();
        map["id"] = doc.id;

        final Book book = Book.fromMap(map);
        _books.add(book);
      }
    } catch (error) {
      Utilities.logger.i(error);
      context.showErrorBar(content: Text(error.toString()));
    }
  }

  Future fetchIllustrations() async {
    try {
      final QuerySnapMap snapshot = await FirebaseFirestore.instance
          .collection("illustrations")
          .where("user_id", isEqualTo: widget.userId)
          .where("visibility", isEqualTo: "public")
          .limit(6)
          .get();

      for (final QueryDocSnapMap doc in snapshot.docs) {
        final Json map = doc.data();
        map["id"] = doc.id;

        final Illustration illustration = Illustration.fromMap(map);
        _illustrations.add(illustration);
      }
    } catch (error) {
      Utilities.logger.i(error);
      context.showErrorBar(content: Text(error.toString()));
    }
  }

  Future fetchUser() async {
    try {
      final DocumentSnapshotMap snapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.userId)
          .collection("user_public_fields")
          .doc("base")
          .get();

      final Json? map = snapshot.data();
      if (map == null) {
        return;
      }

      map["id"] = snapshot.id;

      setState(() {
        _userFirestore = UserFirestore.fromMap(map);
      });
    } catch (error) {
      Utilities.logger.i(error);
      context.showErrorBar(content: Text(error.toString()));
    }
  }

  void onPageScroll(double offset) {
    updateAppBarTitleVisibility(offset);
  }

  void navigateToBookPage(Book book) {
    NavigationStateHelper.book = book;

    String route = HomeLocation.userBookRoute
        .replaceFirst(":userId", widget.userId)
        .replaceFirst(":bookId", book.id);

    final String? location = Beamer.of(context)
        .beamingHistory
        .last
        .history
        .last
        .routeInformation
        .location;

    if (location != null && location.contains("atelier")) {
      route = AtelierLocationContent.bookRoute.replaceFirst(
        ":bookId",
        book.id,
      );
    }

    Beamer.of(context).beamToNamed(
      route,
      data: {
        "bookId": book.id,
      },
    );
  }

  void navigateToIllustrationPage(Illustration illustration) {
    NavigationStateHelper.illustration = illustration;

    String route = HomeLocation.userIllustrationRoute
        .replaceFirst(":userId", widget.userId)
        .replaceFirst(":illustrationId", illustration.id);

    final String? location = Beamer.of(context)
        .beamingHistory
        .last
        .history
        .last
        .routeInformation
        .location;

    if (location != null && location.contains("atelier")) {
      route = AtelierLocationContent.illustrationRoute.replaceFirst(
        ":illustrationId",
        illustration.id,
      );
    }

    Beamer.of(context).beamToNamed(
      route,
      data: {
        "illustrationId": illustration.id,
      },
    );
  }

  /// When a book card receives onTap event.
  void onTapBook(Book book) {
    navigateToBookPage(book);
  }

  void onTapIllustration(Illustration illustration) {
    navigateToIllustrationPage(illustration);
  }

  void updateAppBarTitleVisibility(double offset) {
    final double treshold = 400.0;

    if (_showAppBarTitle && offset < treshold) {
      setState(() => _showAppBarTitle = false);
    }

    if (!_showAppBarTitle && offset >= treshold) {
      setState(() => _showAppBarTitle = true);
    }
  }
}
