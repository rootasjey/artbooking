import 'dart:async';

import 'package:artbooking/components/application_bar/application_bar.dart';
import 'package:artbooking/components/dialogs/themed_dialog.dart';
import 'package:artbooking/components/loading_view.dart';
import 'package:artbooking/components/popup_menu/popup_menu_icon.dart';
import 'package:artbooking/components/popup_menu/popup_menu_item_icon.dart';
import 'package:artbooking/globals/app_state.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/router/locations/atelier_location.dart';
import 'package:artbooking/screens/licenses/many/licenses_page_fab.dart';
import 'package:artbooking/screens/posts/many/posts_page_body.dart';
import 'package:artbooking/screens/posts/many/posts_page_header.dart';
import 'package:artbooking/types/cloud_functions/post_response.dart';
import 'package:artbooking/types/enums/enum_content_visibility.dart';
import 'package:artbooking/types/enums/enum_post_item_action.dart';
import 'package:artbooking/types/firestore/query_doc_snap_map.dart';
import 'package:artbooking/types/firestore/document_change_map.dart';
import 'package:artbooking/types/firestore/query_map.dart';
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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicons/unicons.dart';

class PostsPage extends ConsumerStatefulWidget {
  const PostsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<PostsPage> createState() => _LicensesPageState();
}

class _LicensesPageState extends ConsumerState<PostsPage> {
  /// True if there're more data to fetch.
  bool _hasNext = true;

  /// True if loading more style from Firestore.
  bool _loadingMore = false;

  /// Posts displayed order.
  bool _descending = true;

  /// True if the data is loading.
  bool _loading = false;

  /// True if currently creating a new post.
  bool _creating = false;

  /// Last fetched document snapshot. Used for pagination.
  DocumentSnapshot<Object>? _lastDocumentSnapshot;

  /// Staff's available licenses.
  final List<Post> _posts = [];

  /// Search results.
  // final List<IllustrationLicense> _suggestionsLicenses = [];

  /// Search controller.
  final _searchTextController = TextEditingController();

  /// Maximum licenses to fetch in one request.
  int _limit = 20;

  QuerySnapshotStreamSubscription? _postSubscription;

  /// Delay search after typing input.
  Timer? _searchTimer;

  /// Selected tab to show (published or drafts).
  var _selectedTab = EnumContentVisibility.public;

  /// Items when opening the popup.
  final List<PopupEntryPost> _postPopupMenuEntries = [
    PopupMenuItemIcon(
      value: EnumPostItemAction.delete,
      icon: PopupMenuIcon(UniconsLine.trash),
      textLabel: "delete".tr(),
    ),
  ];

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

    return Scaffold(
      floatingActionButton: LicensesPageFab(
        show: canManagePosts,
        onPressed: tryCreatePost,
        tooltip: "post_create".tr(),
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          ApplicationBar(),
          PostsPageHeader(
            selectedTab: _selectedTab,
            onChangedTab: onChangedTab,
          ),
          PostsPageBody(
            posts: _posts,
            loading: _loading,
            onTap: onTapPost,
            selectedTab: _selectedTab,
            onDeletePost: canManagePosts ? onDeletePost : null,
            onCreatePost: tryCreatePost,
            popupMenuEntries: _postPopupMenuEntries,
            onPopupMenuItemSelected: onPopupMenuItemSelected,
          )
        ],
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
    _postSubscription?.cancel();

    setState(() {
      _lastDocumentSnapshot = null;
      _posts.clear();
      _loading = true;
    });

    try {
      final query = await FirebaseFirestore.instance
          .collection("posts")
          .where("visibility", isEqualTo: "public")
          .orderBy("published_at", descending: true)
          .limit(_limit);

      listenPostEvents(query);
      final snapshot = await query.get();

      if (snapshot.size == 0) {
        setState(() {
          _hasNext = false;
          _loading = false;
        });

        return;
      }

      for (final QueryDocSnapMap doc in snapshot.docs) {
        final data = doc.data();
        data["id"] = doc.id;

        final post = Post.fromMap(data);
        _posts.add(post);
      }

      _hasNext = _limit == snapshot.size;
      _lastDocumentSnapshot = snapshot.docs.last;
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    } finally {
      setState(() => _loading = false);
    }
  }

  /// Fetch more published posts on Firestore.
  void fetchMorePublishedPosts() async {
    final lastDocumentSnapshot = _lastDocumentSnapshot;
    if (_loadingMore || !_hasNext || lastDocumentSnapshot == null) {
      return;
    }

    setState(() => _loadingMore = true);

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("posts")
          .where("visibility", isEqualTo: "public")
          .orderBy("published_at", descending: true)
          .startAfterDocument(lastDocumentSnapshot)
          .get();

      if (snapshot.size == 0) {
        setState(() {
          _hasNext = false;
          _loadingMore = false;
          _lastDocumentSnapshot = null;
        });

        return;
      }

      for (final QueryDocSnapMap doc in snapshot.docs) {
        final data = doc.data();
        data["id"] = doc.id;

        final post = Post.fromMap(data);
        _posts.add(post);
      }

      _hasNext = _limit == snapshot.size;
      _lastDocumentSnapshot = snapshot.docs.last;
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    } finally {
      setState(() => _loadingMore = false);
    }
  }

  /// Fetch drafts posts on Firestore.
  void fetchDrafts() async {
    _postSubscription?.cancel();

    setState(() {
      _lastDocumentSnapshot = null;
      _posts.clear();
      _loading = true;
    });

    try {
      final query = await FirebaseFirestore.instance
          .collection("posts")
          .where("visibility", isEqualTo: "private")
          .orderBy("created_at", descending: _descending)
          .limit(_limit);

      listenPostEvents(query);
      final snapshot = await query.get();

      if (snapshot.size == 0) {
        setState(() {
          _hasNext = false;
          _loading = false;
        });

        return;
      }

      for (final QueryDocSnapMap doc in snapshot.docs) {
        final data = doc.data();
        data["id"] = doc.id;

        final post = Post.fromMap(data);
        _posts.add(post);
      }

      _hasNext = _limit == snapshot.size;
      _lastDocumentSnapshot = snapshot.docs.last;
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    } finally {
      setState(() => _loading = false);
    }
  }

  /// Fetch more drafts posts on Firestore.
  void fetchMoreDrafts() async {
    final lastDocumentSnapshot = _lastDocumentSnapshot;
    if (_loadingMore || !_hasNext || lastDocumentSnapshot == null) {
      return;
    }

    setState(() => _loadingMore = true);

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("posts")
          .where("visibility", isEqualTo: "private")
          .orderBy("created_at", descending: _descending)
          .startAfterDocument(lastDocumentSnapshot)
          .get();

      if (snapshot.size == 0) {
        setState(() {
          _hasNext = false;
          _loadingMore = false;
          _lastDocumentSnapshot = null;
        });

        return;
      }

      for (final QueryDocSnapMap doc in snapshot.docs) {
        final data = doc.data();
        data["id"] = doc.id;

        final post = Post.fromMap(data);
        _posts.add(post);
      }

      _hasNext = _limit == snapshot.size;
      _lastDocumentSnapshot = snapshot.docs.last;
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    } finally {
      setState(() => _loadingMore = false);
    }
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

    if (_hasNext && !_loadingMore && _lastDocumentSnapshot != null) {
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
  void listenPostEvents(QueryMap query) {
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
