import 'package:artbooking/components/application_bar/application_bar.dart';
import 'package:artbooking/components/dialogs/share_dialog.dart';
import 'package:artbooking/components/popup_menu/popup_menu_icon.dart';
import 'package:artbooking/components/popup_menu/popup_menu_item_icon.dart';
import 'package:artbooking/components/texts/page_title.dart';
import 'package:artbooking/globals/app_state.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/router/locations/home_location.dart';
import 'package:artbooking/router/navigation_state_helper.dart';
import 'package:artbooking/screens/illustrations/illustrations_page_body.dart';
import 'package:artbooking/screens/illustrations/illustrations_page_fab.dart';
import 'package:artbooking/types/enums/enum_illustration_item_action.dart';
import 'package:artbooking/types/enums/enum_share_content_type.dart';
import 'package:artbooking/types/firestore/document_snapshot_map.dart';
import 'package:artbooking/types/firestore/query_doc_snap_map.dart';
import 'package:artbooking/types/firestore/document_change_map.dart';
import 'package:artbooking/types/firestore/query_map.dart';
import 'package:artbooking/types/firestore/query_snap_map.dart';
import 'package:artbooking/types/firestore/query_snapshot_stream_subscription.dart';
import 'package:artbooking/types/illustration/illustration.dart';
import 'package:artbooking/types/illustration/popup_entry_illustration.dart';
import 'package:artbooking/types/json_types.dart';
import 'package:beamer/beamer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_improved_scrolling/flutter_improved_scrolling.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicons/unicons.dart';

class IllustrationsPage extends ConsumerStatefulWidget {
  @override
  _IllustrationsPageState createState() => _IllustrationsPageState();
}

class _IllustrationsPageState extends ConsumerState<IllustrationsPage> {
  /// Start from the most recent.
  bool _descending = true;

  /// If true, there are more books to fetch.
  bool _hasNext = true;

  /// Loading the current page if true.
  bool _loading = false;

  /// Loading the next page if true.
  bool _loadingMore = false;

  /// Show the page floating action button if true.
  bool _showFabToTop = false;

  /// Last fetched illustration document.
  DocumentSnapshot? _lastDocument;

  /// Last saved Y offset.
  /// Used while scrolling to know the direction.
  double _previousOffset = 0.0;

  /// Maximum books fetched in a page.
  final int _limit = 30;

  /// Illustration list.
  final List<Illustration> _illustrations = [];

  /// Available items for authenticated user and illustration is not liked yet.
  final List<PopupEntryIllustration> _likePopupMenuEntries = [
    PopupMenuItemIcon(
      value: EnumIllustrationItemAction.like,
      icon: PopupMenuIcon(UniconsLine.heart),
      textLabel: "like".tr(),
    ),
    PopupMenuItemIcon(
      icon: PopupMenuIcon(UniconsLine.share),
      textLabel: "share".tr(),
      value: EnumIllustrationItemAction.share,
    ),
  ];

  /// Available items for authenticated user and illustration is already liked.
  final List<PopupEntryIllustration> _unlikePopupMenuEntries = [
    PopupMenuItemIcon(
      value: EnumIllustrationItemAction.unlike,
      icon: PopupMenuIcon(UniconsLine.heart_break),
      textLabel: "unlike".tr(),
    ),
    PopupMenuItemIcon(
      icon: PopupMenuIcon(UniconsLine.share),
      textLabel: "share".tr(),
      value: EnumIllustrationItemAction.share,
    ),
  ];

  /// Listens to illustration's updates.
  QuerySnapshotStreamSubscription? _illustrationSubscription;

  /// Listens to user like's updates.
  QuerySnapshotStreamSubscription? _likeSubscription;

  /// Page scroll controller.
  final _pageScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchIllustrations();
    listenLikeEvents();
  }

  @override
  void dispose() {
    _illustrationSubscription?.cancel();
    _likeSubscription?.cancel();
    _pageScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String? userId = ref.watch(AppState.userProvider).firestoreUser?.id;
    final bool authenticated = userId != null && userId.isNotEmpty;
    final List<PopupEntryIllustration> likePopupMenuEntries =
        authenticated ? _likePopupMenuEntries : [];

    final bool isMobileSize = Utilities.size.isMobileSize(context);

    return HeroControllerScope(
      controller: HeroController(),
      child: Scaffold(
        floatingActionButton: IllustrationsPageFab(
          show: _showFabToTop,
          pageScrollController: _pageScrollController,
        ),
        body: ImprovedScrolling(
          onScroll: onPageScroll,
          scrollController: _pageScrollController,
          child: CustomScrollView(
            controller: _pageScrollController,
            slivers: <Widget>[
              ApplicationBar(
                bottom: PreferredSize(
                    child: PageTitle(
                      showBackButton: false,
                      titleValue: "illustrations".tr(),
                      subtitleValue: "illustrations_browse".tr(),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      padding: const EdgeInsets.only(
                        left: 12.0,
                        top: 0.0,
                        bottom: 8.0,
                      ),
                      renderSliver: false,
                    ),
                    preferredSize: Size.fromHeight(120.0)),
                pinned: false,
              ),
              IllustrationsPageBody(
                isMobileSize: isMobileSize,
                loading: _loading,
                illustrations: _illustrations,
                onDoubleTap: authenticated ? onDoubleTapIllustrationItem : null,
                onTapIllustrationCard: onTapIllustration,
                likePopupMenuEntries: likePopupMenuEntries,
                unlikePopupMenuEntries: _unlikePopupMenuEntries,
                onPopupMenuItemSelected: onPopupMenuItemSelected,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Fetch illustrations data from Firestore.
  void fetchIllustrations() async {
    setState(() {
      _loading = true;
      _illustrations.clear();
    });

    try {
      final QuerySnapMap snapshot = await FirebaseFirestore.instance
          .collection("illustrations")
          .where("visibility", isEqualTo: "public")
          .where("staff_review.approved", isEqualTo: true)
          .orderBy("created_at", descending: _descending)
          .limit(_limit)
          .get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          _loading = false;
          _hasNext = false;
        });

        return;
      }

      for (final QueryDocSnapMap document in snapshot.docs) {
        final Json data = document.data();
        data["id"] = document.id;
        data["liked"] = await fetchLike(document.id);

        _illustrations.add(Illustration.fromMap(data));
      }

      setState(() {
        _lastDocument = snapshot.docs.last;
        _hasNext = snapshot.docs.length == _limit;
      });

      listenIllustrationEvents(getListenQuery());
    } catch (error) {
      Utilities.logger.e(error);
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<bool> fetchLike(String illustrationId) async {
    final String? userId = ref.read(AppState.userProvider).firestoreUser?.id;
    if (userId == null || userId.isEmpty) {
      return false;
    }

    try {
      final DocumentSnapshotMap snapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("user_likes")
          .doc(illustrationId)
          .get();

      if (snapshot.exists) {
        return true;
      }

      return false;
    } catch (error) {
      Utilities.logger.e(error);
      return false;
    }
  }

  /// Fetch more illustrations data from Firestore.
  void fetchMoreIllustrations() async {
    final lastDocument = _lastDocument;
    if (!_hasNext || lastDocument == null) {
      return;
    }

    _loadingMore = true;

    try {
      final QuerySnapMap snapshot = await FirebaseFirestore.instance
          .collection("illustrations")
          .where("visibility", isEqualTo: "public")
          .where("staff_review.approved", isEqualTo: true)
          .orderBy("created_at", descending: _descending)
          .limit(_limit)
          .startAfterDocument(lastDocument)
          .get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          _hasNext = false;
          _loadingMore = false;
        });

        return;
      }

      for (final QueryDocSnapMap document in snapshot.docs) {
        final Json data = document.data();
        data["id"] = document.id;
        data["liked"] = await fetchLike(document.id);

        _illustrations.add(Illustration.fromMap(data));
      }

      setState(() {
        _lastDocument = snapshot.docs.last;
        _hasNext = snapshot.docs.length == _limit;
        _loadingMore = false;
      });

      listenIllustrationEvents(getListenQuery());
    } catch (error) {
      Utilities.logger.e(error);
    } finally {
      setState(() => _loading = false);
    }
  }

  /// Return the query to listen changes to.
  QueryMap? getListenQuery() {
    final DocumentSnapshot? lastDocument = _lastDocument;
    if (lastDocument == null) {
      return null;
    }

    return FirebaseFirestore.instance
        .collection("illustrations")
        .where("visibility", isEqualTo: "public")
        .where("staff_review.approved", isEqualTo: true)
        .orderBy("created_at", descending: _descending)
        .endAtDocument(lastDocument);
  }

  /// Listen to Firestore illustration events
  void listenIllustrationEvents(QueryMap? query) {
    if (query == null) {
      return;
    }

    _illustrationSubscription?.cancel();
    _illustrationSubscription = query.snapshots().skip(1).listen(
      (snapshot) {
        for (DocumentChangeMap documentChange in snapshot.docChanges) {
          switch (documentChange.type) {
            case DocumentChangeType.added:
              onAddStreamingIllustration(documentChange);
              break;
            case DocumentChangeType.modified:
              onUpdateStreamingIllustration(documentChange);
              break;
            case DocumentChangeType.removed:
              onRemoveStreamingIllustration(documentChange);
              break;
          }
        }
      },
      onError: (error) {
        Utilities.logger.e(error);
      },
    );
  }

  /// Listen to Firestore illustration' like events for sync purpose.
  void listenLikeEvents() {
    String? userId = ref.read(AppState.userProvider).firestoreUser?.id;
    if (userId == null || userId.isEmpty) {
      return;
    }

    _likeSubscription = FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("user_likes")
        .where("type", isEqualTo: "illustration")
        .snapshots()
        .skip(1)
        .listen(
      (snapshot) {
        for (final DocumentChangeMap documentChange in snapshot.docChanges) {
          switch (documentChange.type) {
            case DocumentChangeType.added:
              onAddStreamingLike(documentChange);
              break;
            case DocumentChangeType.removed:
              onRemoveStreamingLike(documentChange);
              break;
            default:
          }
        }
      },
      onError: (error) {
        Utilities.logger.e(error);
      },
      onDone: () {
        _likeSubscription?.cancel();
      },
    );
  }

  void maybeFetchMore(double offset) {
    if (_pageScrollController.position.atEdge &&
        offset > 50 &&
        _hasNext &&
        !_loadingMore) {
      fetchMoreIllustrations();
    }
  }

  void maybeShowFab(double offset) {
    final bool scrollingDown = offset - _previousOffset > 0;
    _previousOffset = offset;

    if (scrollingDown) {
      if (!_showFabToTop) {
        return;
      }

      setState(() => _showFabToTop = false);
      return;
    }

    if (offset == 0.0) {
      setState(() => _showFabToTop = false);
      return;
    }

    if (_showFabToTop) {
      return;
    }

    setState(() => _showFabToTop = true);
  }

  /// Fire when a new document has been created in Firestore.
  /// Add the corresponding document in the UI.
  void onAddStreamingIllustration(DocumentChangeMap documentChange) {
    final Json? data = documentChange.doc.data();

    if (data == null) {
      return;
    }

    setState(() {
      data["id"] = documentChange.doc.id;
      final illustration = Illustration.fromMap(data);
      _illustrations.insert(0, illustration);
    });
  }

  void onAddStreamingLike(DocumentChangeMap documentChange) {
    final String likeId = documentChange.doc.id;
    final int index = _illustrations.indexWhere((x) => x.id == likeId);

    if (index < 0) {
      return;
    }

    final Illustration illustration = _illustrations.elementAt(index);
    if (illustration.liked) {
      return;
    }

    setState(() {
      _illustrations.replaceRange(
        index,
        index + 1,
        [illustration.copyWith(liked: true)],
      );
    });
  }

  void onDoubleTapIllustrationItem(Illustration illustration, int index) {
    onLike(illustration, index);
  }

  void onLike(Illustration illustration, int index) {
    if (illustration.liked) {
      return tryUnLike(illustration, index);
    }

    return tryLike(illustration, index);
  }

  /// Callback when the page scrolls up and down.
  void onPageScroll(double offset) {
    maybeShowFab(offset);
    maybeFetchMore(offset);
  }

  void onPopupMenuItemSelected(
    EnumIllustrationItemAction action,
    int index,
    Illustration illustration,
    String illustrationKey,
  ) {
    switch (action) {
      case EnumIllustrationItemAction.like:
      case EnumIllustrationItemAction.unlike:
        onLike(illustration, index);
        break;
      case EnumIllustrationItemAction.share:
        showShareDialog(illustration, index);
        break;
      default:
    }
  }

  /// Fire when a new document has been delete from Firestore.
  /// Delete the corresponding document from the UI.
  void onRemoveStreamingIllustration(DocumentChangeMap documentChange) {
    setState(() {
      _illustrations.removeWhere(
        (illustration) => illustration.id == documentChange.doc.id,
      );
    });
  }

  void onRemoveStreamingLike(DocumentChangeMap documentChange) {
    final String likeId = documentChange.doc.id;
    final int index = _illustrations.indexWhere((x) => x.id == likeId);

    if (index < 0) {
      return;
    }

    final Illustration illustration = _illustrations.elementAt(index);
    if (!illustration.liked) {
      return;
    }

    setState(() {
      _illustrations.replaceRange(
        index,
        index + 1,
        [illustration.copyWith(liked: false)],
      );
    });
  }

  void onTapIllustration(Illustration illustration) {
    NavigationStateHelper.illustration = illustration;
    Beamer.of(context).beamToNamed(
      HomeLocation.illustrationRoute.replaceFirst(
        ":illustrationId",
        illustration.id,
      ),
      data: {
        "illustrationId": illustration.id,
      },
    );
  }

  /// Fire when a new document has been updated in Firestore.
  /// Update the corresponding document in the UI.
  void onUpdateStreamingIllustration(DocumentChangeMap documentChange) async {
    try {
      final data = documentChange.doc.data();
      if (data == null) {
        return;
      }

      final int index = _illustrations.indexWhere(
        (illustration) => illustration.id == documentChange.doc.id,
      );

      data["id"] = documentChange.doc.id;
      data["liked"] = await fetchLike(documentChange.doc.id);
      final updatedIllustration = Illustration.fromMap(data);

      setState(() {
        _illustrations.removeAt(index);
        _illustrations.insert(index, updatedIllustration);
      });
    } on Exception catch (error) {
      Utilities.logger.e(
        "The document with the id ${documentChange.doc.id} "
        "doesn't exist in the illustrations list.",
      );

      Utilities.logger.e(error);
    }
  }

  void showShareDialog(Illustration illustration, int index) {
    showDialog(
      context: context,
      builder: (context) => ShareDialog(
        extension: illustration.extension,
        itemId: illustration.id,
        imageProvider: NetworkImage(illustration.getThumbnail()),
        name: illustration.name,
        imageUrl: illustration.getThumbnail(),
        shareContentType: EnumShareContentType.illustration,
        userId: illustration.userId,
        username: "",
        visibility: illustration.visibility,
      ),
    );
  }

  void tryLike(Illustration illustration, int index) async {
    setState(() {
      _illustrations.replaceRange(
        index,
        index + 1,
        [illustration.copyWith(liked: true)],
      );
    });

    try {
      final String? userId = ref.read(AppState.userProvider).firestoreUser?.id;

      await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("user_likes")
          .doc(illustration.id)
          .set({
        "type": "illustration",
        "target_id": illustration.id,
        "user_id": userId,
      });
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
      setState(() {
        _illustrations.replaceRange(
          index,
          index + 1,
          [illustration.copyWith(liked: false)],
        );
      });
    }
  }

  void tryUnLike(Illustration illustration, int index) async {
    setState(() {
      _illustrations.replaceRange(
        index,
        index + 1,
        [illustration.copyWith(liked: false)],
      );
    });

    try {
      final String? userId = ref.read(AppState.userProvider).firestoreUser?.id;
      await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("user_likes")
          .doc(illustration.id)
          .delete();
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
      setState(() {
        _illustrations.replaceRange(
          index,
          index + 1,
          [illustration.copyWith(liked: true)],
        );
      });
    }
  }
}
