import 'dart:async';

import 'package:artbooking/components/application_bar/application_bar.dart';
import 'package:artbooking/components/custom_scroll_behavior.dart';
import 'package:artbooking/components/dialogs/themed_dialog.dart';
import 'package:artbooking/components/loading_view.dart';
import 'package:artbooking/components/popup_menu/popup_menu_icon.dart';
import 'package:artbooking/components/popup_menu/popup_menu_item_icon.dart';
import 'package:artbooking/globals/app_state.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/router/locations/atelier_location.dart';
import 'package:artbooking/screens/posts/many/posts_page_body.dart';
import 'package:artbooking/screens/posts/many/posts_page_fab.dart';
import 'package:artbooking/screens/posts/many/posts_page_header.dart';
import 'package:artbooking/types/cloud_functions/post_response.dart';
import 'package:artbooking/types/enums/enum_content_visibility.dart';
import 'package:artbooking/types/enums/enum_post_item_action.dart';
import 'package:artbooking/types/firestore/query_doc_snap_map.dart';
import 'package:artbooking/types/firestore/document_change_map.dart';
import 'package:artbooking/types/firestore/query_map.dart';
import 'package:artbooking/types/firestore/query_snap_map.dart';
import 'package:artbooking/types/firestore/query_snapshot_stream_subscription.dart';
import 'package:artbooking/types/json_types.dart';
import 'package:artbooking/types/popup_entry_post.dart';
import 'package:artbooking/types/post.dart';
import 'package:artbooking/types/user/user.dart';
import 'package:beamer/beamer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_improved_scrolling/flutter_improved_scrolling.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicons/unicons.dart';

class PostsPage extends ConsumerStatefulWidget {
  const PostsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<PostsPage> createState() => _LicensesPageState();
}

class _LicensesPageState extends ConsumerState<PostsPage> {
  /// True if currently creating a new post.
  bool _creating = false;

  /// Posts displayed order If true, start with the most recent.
  bool _descending = true;

  /// True if there're more data to fetch.
  bool _hasNext = true;

  /// Loading the next page if true.
  bool _loadingMore = false;

  /// Loading the current page if true.
  bool _loading = false;

  /// Show this page floating action button if true.
  bool _showFabCreate = true;

  /// Show FAB to scroll to the top of the page if true.
  bool _showFabToTop = false;

  /// Last fetched document snapshot. Used for pagination.
  DocumentSnapshot<Object>? _lastDocument;

  /// Last saved Y offset.
  /// Used while scrolling to know the direction.
  double _previousOffset = 0.0;

  /// Selected tab to show (published or drafts).
  var _selectedTab = EnumContentVisibility.public;

  /// Maximum posts to fetch in one request.
  int _limit = 20;

  /// Post list.
  final List<Post> _posts = [];

  /// Menu items on post.
  final List<PopupEntryPost> _postPopupMenuEntries = [
    PopupMenuItemIcon(
      value: EnumPostItemAction.delete,
      icon: PopupMenuIcon(UniconsLine.trash),
      textLabel: "delete".tr(),
    ),
  ];

  QuerySnapshotStreamSubscription? _postSubscription;

  /// Page scroll controller.
  final _pageScrollController = ScrollController();

  /// Search controller.
  final _searchTextController = TextEditingController();

  /// Delay search after typing input.
  Timer? _searchTimer;

  @override
  initState() {
    super.initState();
    loadPreferences();
    fetchPosts();
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    _searchTextController.dispose();
    _postSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final User user = ref.watch(AppState.userProvider);
    final bool canManagePosts =
        user.firestoreUser?.rights.canManagePosts ?? false;

    if (_creating) {
      return creatingWidget();
    }

    final bool isMobileSize = Utilities.size.isMobileSize(context);

    return Scaffold(
      floatingActionButton: PostsPageFab(
        isOwner: canManagePosts,
        label: Text("post_create".tr()),
        onPressed: tryCreatePost,
        pageScrollController: _pageScrollController,
        showFabCreate: _showFabCreate,
        showFabToTop: _showFabToTop,
      ),
      body: ImprovedScrolling(
        scrollController: _pageScrollController,
        enableKeyboardScrolling: true,
        onScroll: onPageScroll,
        child: ScrollConfiguration(
          behavior: CustomScrollBehavior(),
          child: CustomScrollView(
            controller: _pageScrollController,
            slivers: <Widget>[
              ApplicationBar(
                bottom: PreferredSize(
                  child: PostsPageHeader(
                    isMobileSize: isMobileSize,
                    onChangedTab: onChangedTab,
                    selectedTab: _selectedTab,
                  ),
                  preferredSize: Size.fromHeight(160.0),
                ),
                pinned: false,
              ),
              PostsPageBody(
                isMobileSize: isMobileSize,
                loading: _loading,
                onCreatePost: tryCreatePost,
                onDeletePost: canManagePosts ? onDeletePost : null,
                onPopupMenuItemSelected: onPopupMenuItemSelected,
                onTap: onTapPost,
                posts: _posts,
                popupMenuEntries: _postPopupMenuEntries,
                selectedTab: _selectedTab,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget creatingWidget() {
    final double marginTop = MediaQuery.of(context).size.height / 3;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          ApplicationBar(),
          SliverPadding(
            padding: EdgeInsets.only(top: marginTop),
            sliver: LoadingView(
              title: Text(
                "post_creating".tr() + "...",
                style: Utilities.fonts.body(
                  fontSize: 32.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void fetchPosts() {
    if (_selectedTab == EnumContentVisibility.public) {
      return fetchPublishedPosts();
    }

    return fetchDrafts();
  }

  /// Fetch published posts on Firestore.
  void fetchPublishedPosts() async {
    setState(() {
      _lastDocument = null;
      _posts.clear();
      _loading = true;
    });

    try {
      final QuerySnapMap snapshot = await FirebaseFirestore.instance
          .collection("posts")
          .where("visibility", isEqualTo: "public")
          .orderBy("published_at", descending: true)
          .limit(_limit)
          .get();

      if (snapshot.size == 0) {
        setState(() {
          _hasNext = false;
          _loading = false;
        });

        return;
      }

      for (final QueryDocSnapMap doc in snapshot.docs) {
        final Json data = doc.data();
        data["id"] = doc.id;

        final Post post = Post.fromMap(data);
        _posts.add(post);
      }

      _hasNext = _limit == snapshot.size;
      _lastDocument = snapshot.docs.last;

      listenPostEvents(getListenQuery());
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    } finally {
      setState(() => _loading = false);
    }
  }

  /// Fetch more published posts on Firestore.
  void fetchMorePublishedPosts() async {
    final DocumentSnapshot? lastDocumentSnapshot = _lastDocument;
    if (_loadingMore || !_hasNext || lastDocumentSnapshot == null) {
      return;
    }

    setState(() => _loadingMore = true);

    try {
      final QuerySnapMap snapshot = await FirebaseFirestore.instance
          .collection("posts")
          .where("visibility", isEqualTo: "public")
          .orderBy("published_at", descending: true)
          .startAfterDocument(lastDocumentSnapshot)
          .get();

      if (snapshot.size == 0) {
        setState(() {
          _hasNext = false;
          _loadingMore = false;
          _lastDocument = null;
        });

        return;
      }

      for (final QueryDocSnapMap doc in snapshot.docs) {
        final Json data = doc.data();
        data["id"] = doc.id;

        final Post post = Post.fromMap(data);
        _posts.add(post);
      }

      _hasNext = _limit == snapshot.size;
      _lastDocument = snapshot.docs.last;

      listenPostEvents(getListenQuery());
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    } finally {
      setState(() => _loadingMore = false);
    }
  }

  /// Fetch drafts posts on Firestore.
  void fetchDrafts() async {
    setState(() {
      _lastDocument = null;
      _posts.clear();
      _loading = true;
    });

    try {
      final QuerySnapMap snapshot = await FirebaseFirestore.instance
          .collection("posts")
          .where("visibility", isEqualTo: "private")
          .orderBy("created_at", descending: _descending)
          .limit(_limit)
          .get();

      if (snapshot.size == 0) {
        setState(() {
          _hasNext = false;
          _loading = false;
        });

        return;
      }

      for (final QueryDocSnapMap doc in snapshot.docs) {
        final Json data = doc.data();
        data["id"] = doc.id;

        final Post post = Post.fromMap(data);
        _posts.add(post);
      }

      _hasNext = _limit == snapshot.size;
      _lastDocument = snapshot.docs.last;

      listenPostEvents(getListenQuery());
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    } finally {
      setState(() => _loading = false);
    }
  }

  /// Fetch more drafts posts on Firestore.
  void fetchMoreDrafts() async {
    final DocumentSnapshot? lastDocumentSnapshot = _lastDocument;
    if (_loadingMore || !_hasNext || lastDocumentSnapshot == null) {
      return;
    }

    setState(() => _loadingMore = true);

    try {
      final QuerySnapMap snapshot = await FirebaseFirestore.instance
          .collection("posts")
          .where("visibility", isEqualTo: "private")
          .orderBy("created_at", descending: _descending)
          .startAfterDocument(lastDocumentSnapshot)
          .get();

      if (snapshot.size == 0) {
        setState(() {
          _hasNext = false;
          _loadingMore = false;
          _lastDocument = null;
        });

        return;
      }

      for (final QueryDocSnapMap doc in snapshot.docs) {
        final Json data = doc.data();
        data["id"] = doc.id;

        final Post post = Post.fromMap(data);
        _posts.add(post);
      }

      _hasNext = _limit == snapshot.size;
      _lastDocument = snapshot.docs.last;

      listenPostEvents(getListenQuery());
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    } finally {
      setState(() => _loadingMore = false);
    }
  }

  /// Return the query to listen changes to.
  QueryMap? getListenQuery() {
    final DocumentSnapshot? lastDocument = _lastDocument;
    if (lastDocument == null) {
      return null;
    }

    if (_selectedTab == EnumContentVisibility.public) {
      return FirebaseFirestore.instance
          .collection("posts")
          .where("visibility", isEqualTo: "public")
          .orderBy("published_at", descending: true)
          .limit(_limit)
          .endAtDocument(lastDocument);
    }

    return FirebaseFirestore.instance
        .collection("posts")
        .where("visibility", isEqualTo: "private")
        .orderBy("created_at", descending: _descending)
        .limit(_limit)
        .endAtDocument(lastDocument);
  }

  void loadPreferences() {
    _selectedTab = Utilities.storage.getPostTab();
  }

  void onChangedTab(EnumContentVisibility visibilityTab) {
    Utilities.storage.savePostTab(visibilityTab);

    setState(() {
      _selectedTab = visibilityTab;
    });

    switch (visibilityTab) {
      case EnumContentVisibility.public:
        fetchPublishedPosts();
        break;
      case EnumContentVisibility.private:
        fetchDrafts();
        break;
      default:
    }
  }

  /// On scroll notification
  bool onNotification(ScrollNotification notification) {
    if (notification.metrics.pixels < notification.metrics.maxScrollExtent) {
      return false;
    }

    if (_hasNext && !_loadingMore && _lastDocument != null) {
      fetchMorePublishedPosts();
    }

    return false;
  }

  void onPopupMenuItemSelected(
      EnumPostItemAction action, int index, Post post) {
    switch (action) {
      case EnumPostItemAction.delete:
        tryDeletePost(post, index);
        break;
      default:
    }
  }

  /// Listen to the last Firestore query of this page.
  void listenPostEvents(QueryMap? query) {
    if (query == null) {
      return;
    }

    _postSubscription?.cancel();
    _postSubscription = query.snapshots().skip(1).listen(
      (snapshot) {
        for (DocumentChangeMap documentChange in snapshot.docChanges) {
          switch (documentChange.type) {
            case DocumentChangeType.added:
              onAddStreamingPost(documentChange);
              break;
            case DocumentChangeType.modified:
              onUpdateStreamingPost(documentChange);
              break;
            case DocumentChangeType.removed:
              onRemoveStreamingPost(documentChange);
              break;
          }
        }
      },
      onError: (error) {
        Utilities.logger.e(error);
      },
    );
  }

  void maybeFetchMore(double offset) {
    if (_pageScrollController.position.atEdge &&
        offset > 50 &&
        _hasNext &&
        !_loadingMore) {
      _selectedTab == EnumContentVisibility.private
          ? fetchMoreDrafts()
          : fetchMorePublishedPosts();
    }
  }

  void maybeShowFab(double offset) {
    final bool scrollingDown = offset - _previousOffset > 0;
    _previousOffset = offset;

    _showFabToTop = offset == 0.0 ? false : true;

    if (scrollingDown) {
      if (!_showFabCreate) {
        return;
      }

      setState(() => _showFabCreate = false);
      return;
    }

    if (offset == 0.0) {
      setState(() => _showFabToTop = false);
    }

    if (_showFabCreate) {
      return;
    }

    setState(() => _showFabCreate = true);
  }

  /// Fire when a new document has been created in Firestore.
  /// Add the corresponding document in the UI.
  void onAddStreamingPost(DocumentChangeMap documentChange) {
    final data = documentChange.doc.data();

    if (data == null) {
      return;
    }

    setState(() {
      data["id"] = documentChange.doc.id;
      final post = Post.fromMap(data);
      _posts.insert(0, post);
    });
  }

  void onDeletePost(Post post, int index) {
    showDeleteConfirmDialog(post, index);
  }

  /// Callback when the page scrolls up and down.
  void onPageScroll(double offset) {
    maybeShowFab(offset);
    maybeFetchMore(offset);
  }

  /// Fire when a new document has been delete from Firestore.
  /// Delete the corresponding document from the UI.
  void onRemoveStreamingPost(DocumentChangeMap documentChange) {
    setState(() {
      _posts.removeWhere(
        (post) => post.id == documentChange.doc.id,
      );
    });
  }

  void onTapPost(Post post) {
    Beamer.of(context).beamToNamed(
      AtelierLocationContent.postRoute.replaceFirst(":postId", post.id),
      data: {"postId": post.id},
    );
  }

  /// Fire when a new document has been updated in Firestore.
  /// Update the corresponding document in the UI.
  void onUpdateStreamingPost(DocumentChangeMap documentChange) {
    try {
      final Json? data = documentChange.doc.data();
      if (data == null || !documentChange.doc.exists) {
        return;
      }

      final int index = _posts.indexWhere(
        (x) => x.id == documentChange.doc.id,
      );

      data["id"] = documentChange.doc.id;
      final updatedPost = Post.fromMap(data);

      setState(() {
        _posts.removeAt(index);
        _posts.insert(index, updatedPost);
      });
    } on Exception catch (error) {
      Utilities.logger.e(
        "The document with the id ${documentChange.doc.id} "
        "doesn't exist in the illustrations list.",
      );

      Utilities.logger.e(error);
    }
  }

  void tryCreatePost() async {
    setState(() => _creating = true);

    try {
      final response = await Utilities.cloud.fun("posts-createOne").call({
        "language": context.locale.languageCode,
      });

      final bool success = response.data["success"];

      if (!success) {
        throw ErrorDescription("post_create_error".tr());
      }

      final String createdPostId = response.data["post"]["id"];
      Beamer.of(context).beamToNamed(
        AtelierLocationContent.postRoute.replaceFirst(":postId", createdPostId),
        data: {
          "postId": createdPostId,
        },
      );
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    } finally {
      setState(() => _creating = false);
    }
  }

  void showDeleteConfirmDialog(Post post, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return ThemedDialog(
          spaceActive: false,
          centerTitle: false,
          autofocus: true,
          title: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Opacity(
              opacity: 0.8,
              child: Text(
                "post_delete".tr().toUpperCase(),
                style: Utilities.fonts.body(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          body: Container(
            width: 300.0,
            padding: const EdgeInsets.all(12.0),
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Text.rich(
                  TextSpan(
                    text: "post_delete_are_you_sure".tr(),
                    style: Utilities.fonts.body(
                      fontSize: 24.0,
                      fontWeight: FontWeight.w500,
                    ),
                    children: [
                      TextSpan(
                        text: post.name,
                        style: Utilities.fonts.body(
                          fontSize: 24.0,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).secondaryHeaderColor,
                        ),
                      ),
                      TextSpan(text: " ?"),
                    ],
                  ),
                ),
              ),
            ),
          ),
          textButtonValidation: "delete".tr(),
          onValidate: () {
            tryDeletePost(post, index);
            Beamer.of(context).popRoute();
          },
          onCancel: Beamer.of(context).popRoute,
        );
      },
    );
  }

  void tryDeletePost(Post post, int index) async {
    setState(() => _posts.removeAt(index));

    try {
      final response = await Utilities.cloud.fun("posts-deleteOne").call({
        "post_id": post.id,
      });

      final data = PostResponse.fromJSON(response.data);
      if (data.success) {
        return;
      }

      throw ErrorDescription("post_delete_failed".tr());
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
      setState(() => _posts.insert(index, post));
    }
  }
}
