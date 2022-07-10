import 'dart:async';
import 'dart:typed_data';

import 'package:artbooking/components/application_bar/application_bar.dart';
import 'package:artbooking/components/dialogs/delete_dialog.dart';
import 'package:artbooking/components/popup_menu/popup_menu_icon.dart';
import 'package:artbooking/components/dialogs/input_dialog.dart';
import 'package:artbooking/components/loading_view.dart';
import 'package:artbooking/components/popup_menu/popup_menu_item_icon.dart';
import 'package:artbooking/globals/app_state.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/router/locations/atelier_location.dart';
import 'package:artbooking/router/locations/home_location.dart';
import 'package:artbooking/router/navigation_state_helper.dart';
import 'package:artbooking/screens/post/bottom_action_bar.dart';
import 'package:artbooking/screens/post/post_page_body.dart';
import 'package:artbooking/screens/post/post_page_header.dart';
import 'package:artbooking/types/cloud_functions/post_response.dart';
import 'package:artbooking/types/enums/enum_content_visibility.dart';
import 'package:artbooking/types/firestore/doc_snapshot_stream_subscription.dart';
import 'package:artbooking/types/firestore/document_map.dart';
import 'package:artbooking/types/firestore/document_snapshot_map.dart';
import 'package:artbooking/types/json_types.dart';
import 'package:artbooking/types/post.dart';
import 'package:artbooking/types/user/user_firestore.dart';
import 'package:beamer/beamer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_improved_scrolling/flutter_improved_scrolling.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:super_editor/super_editor.dart';
import 'package:unicons/unicons.dart';

class PostPage extends ConsumerStatefulWidget {
  const PostPage({
    Key? key,
    required this.postId,
  }) : super(key: key);

  final String postId;

  @override
  ConsumerState<PostPage> createState() => _PostPageState();
}

class _PostPageState extends ConsumerState<PostPage> {
  /// True if the post is being deleted.
  bool _deleting = false;

  /// True if the post is in the current authenticated user's favourites.
  bool _liked = false;

  /// True if the post is being loaded.
  bool _loading = false;

  /// True if the post is being saved.
  bool _saving = false;

  /// If true, bottom action bar will be visible.
  bool _showBottomActionBar = true;

  /// Previous Y position in scroll.
  /// Related to [_pageScrollController].
  double _previousOffset = 0.0;

  final List<PopupMenuEntry<EnumContentVisibility>> _postPopupMenuItems = [
    PopupMenuItemIcon(
      icon: PopupMenuIcon(UniconsLine.keyhole_square),
      textLabel: "make_private".tr(),
      value: EnumContentVisibility.private,
      selected: false,
      // selected: post.visibility == EnumContentVisibility.private,
    ),
    PopupMenuItemIcon(
      icon: PopupMenuIcon(UniconsLine.envelope_upload_alt),
      textLabel: "publish".tr(),
      value: EnumContentVisibility.public,
      selected: false,
      // selected: post.visibility == EnumContentVisibility.public,
    ),
  ];

  /// Post model.
  Post _post = Post.empty();

  /// Visible if the authenticated user has the right to edit this post.
  DocumentEditor _documentEditor = DocumentEditor(document: MutableDocument());

  /// Post's content.
  MutableDocument _document = MutableDocument();

  /// Input controller for post's title (metadata).
  final TextEditingController _titleController = TextEditingController();

  /// Input controller for post's description (metadata).
  final TextEditingController _descriptionController = TextEditingController();

  /// Page scroll controller.
  final ScrollController _pageScrollController = ScrollController();

  /// Listen to changes for this illustration's like status.
  DocSnapshotStreamSubscription? _likeSubscription;

  /// Post's document subcription.
  /// We use this stream to listen to document fields updates.
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _postSubscription;

  /// Used to add delay to post's metadata update.
  Timer? _metadataUpdateTimer;

  /// Used to add delay to post's content update.
  Timer? _contentUpdateTimer;

  @override
  void initState() {
    super.initState();

    var navPost = NavigationStateHelper.post;

    if (navPost != null && navPost.id == widget.postId) {
      _post = navPost;
      _titleController.text = _post.name;
      _descriptionController.text = _post.description;
      fetchPostContent();
      listenToDocumentChanges(
          FirebaseFirestore.instance.collection("posts").doc(widget.postId));
    } else {
      fetchPostMetadata().whenComplete(fetchPostContent);
    }
  }

  @override
  void dispose() {
    _metadataUpdateTimer?.cancel();
    _contentUpdateTimer?.cancel();
    _titleController.dispose();
    _descriptionController.dispose();
    _document.dispose();
    _postSubscription?.cancel();
    _likeSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final UserFirestore? userFirestore =
        ref.watch(AppState.userProvider).firestoreUser;
    final bool canManagePosts = userFirestore?.rights.canManagePosts ?? false;

    final bool authenticated =
        userFirestore != null && userFirestore.id.isNotEmpty;

    if (_deleting) {
      return deletingWidget();
    }

    final bool isMobileSize = Utilities.size.isMobileSize(context);

    return Scaffold(
      body: Stack(
        children: [
          ImprovedScrolling(
            scrollController: _pageScrollController,
            onScroll: onPageScroll,
            // We deactivate keyboard scrolling
            // because we can already navigate in the editor
            //if [canManagePost] is true.
            enableKeyboardScrolling: !canManagePosts,
            enableMMBScrolling: true,
            child: CustomScrollView(
              controller: _pageScrollController,
              slivers: [
                ApplicationBar(),
                PostPageHeader(
                  canManagePosts: canManagePosts,
                  descriptionController: _descriptionController,
                  isMobileSize: isMobileSize,
                  onLangChanged: updatePostLang,
                  onShowAddTagModal: onShowAddTagModal,
                  onTitleChanged: onTitleChanged,
                  onDeleteTag: onDeleteTag,
                  post: _post,
                  titleController: _titleController,
                  popupVisibilityItems: _postPopupMenuItems,
                  onVisibilityItemSelected: onVisibilityItemSelected,
                ),
                PostPageBody(
                  document: _document,
                  documentEditor: _documentEditor,
                  canManagePosts: canManagePosts,
                  isMobileSize: isMobileSize,
                  loading: _loading,
                  post: _post,
                ),
              ],
            ),
          ),
          if (_saving)
            Positioned(
              top: 120.0,
              right: 40.0,
              child: Lottie.asset(
                "assets/animations/dots.json",
                repeat: true,
                width: 100.0,
                height: 100.0,
              ),
            ),
          BottomActionBar(
            authenticated: authenticated,
            canManagePosts: canManagePosts,
            liked: _liked,
            onDelete: showDeleteConfirm,
            onShare: onSharePost,
            onToggleLike: onToggleLike,
            published: _post.visibility == EnumContentVisibility.public,
            show: _showBottomActionBar,
          ),
        ],
      ),
    );
  }

  Widget deletingWidget() {
    final double marginTop = MediaQuery.of(context).size.height / 3;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          ApplicationBar(),
          SliverPadding(
            padding: EdgeInsets.only(top: marginTop),
            sliver: LoadingView(
              title: Text(
                "post_deleting".tr() + "...",
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

  void copyPostLinkToClipboard() {
    final String link = "https://artbooking.fr/posts/${_post.id}";
    Clipboard.setData(ClipboardData(text: link));

    context.showFlashBar(
      duration: Duration(seconds: 5),
      content: Text("Link successfully copied!"),
    );
  }

  void fetchLike() async {
    final String? userId = ref.read(AppState.userProvider).firestoreUser?.id;
    if (userId == null || userId.isEmpty) {
      return;
    }

    try {
      _likeSubscription = await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("user_likes")
          .doc(_post.id)
          .snapshots()
          .listen((snapshot) {
        setState(() {
          _liked = snapshot.exists;
        });
      }, onDone: () {
        _likeSubscription?.cancel();
      });
    } catch (error) {
      Utilities.logger.e(error);
    }
  }

  void fetchPostContent() async {
    if (_post.id.isEmpty) {
      return;
    }

    setState(() => _loading = true);

    try {
      final Reference file =
          await FirebaseStorage.instance.ref(_post.storagePath);

      final Uint8List? uintList = await file.getData();
      if (uintList == null) {
        return;
      }

      String content = "";

      for (final uint in uintList) {
        content += String.fromCharCode(uint);
      }

      if (content.isEmpty) {
        content = "Start typing here...";
      }

      setState(() {
        _post = _post.copyWith(
          content: content,
        );

        _document = deserializeMarkdownToDocument(_post.content)
          ..addListener(() {
            _contentUpdateTimer?.cancel();
            _contentUpdateTimer = Timer(
              Duration(seconds: 1),
              onPostContentChange,
            );
          });

        _documentEditor = DocumentEditor(
          document: _document,
        );
      });
    } catch (error) {
      Utilities.logger.e(error);
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future fetchPostMetadata() async {
    setState(() => _loading = true);

    try {
      final DocumentMap query =
          FirebaseFirestore.instance.collection("posts").doc(widget.postId);

      listenToDocumentChanges(query);
      final DocumentSnapshotMap snapshot = await query.get();

      final Json? map = snapshot.data();
      if (!snapshot.exists || map == null) {
        return;
      }

      map["id"] = snapshot.id;
      _post = Post.fromMap(map);
      _titleController.text = _post.name;
    } catch (error) {
      Utilities.logger.e(error);
    } finally {
      setState(() => _loading = false);
    }
  }

  void listenToDocumentChanges(DocumentReference<Map<String, dynamic>> query) {
    _postSubscription?.cancel();
    _postSubscription = query.snapshots().skip(1).listen((snapshot) {
      final Json? map = snapshot.data();

      if (!snapshot.exists || map == null) {
        return;
      }

      setState(() {
        _post = Post.fromMap(map).copyWith(
          content: _post.content,
          id: _post.id,
        );

        if (_titleController.text != _post.name) {
          _titleController.text = _post.name;
        }
      });
    }, onError: (error) {
      Utilities.logger.e(error);
    }, onDone: () {
      _postSubscription?.cancel();
    });
  }

  void navigateBack() {
    final String? location = Beamer.of(context)
        .beamingHistory
        .last
        .history
        .last
        .routeInformation
        .location;

    if (location == null) {
      Beamer.of(context).beamToNamed(AtelierLocationContent.postsRoute);
      return;
    }

    if (location.contains("atelier")) {
      Beamer.of(context).beamToNamed(AtelierLocationContent.postsRoute);
      return;
    }

    Beamer.of(context).beamToNamed(HomeLocation.route);
  }

  void onAddTag(String rawTags) async {
    final String trimedRawTags = rawTags.trim();

    if (trimedRawTags.isEmpty) {
      return;
    }

    final List<String> tagArray = trimedRawTags.split(",");

    for (final String tag in tagArray) {
      final trimedTag = tag.trim();
      if (trimedTag.isEmpty) {
        continue;
      }

      _post.tags.add(trimedTag);
    }

    setState(() {
      _saving = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection("posts")
          .doc(_post.id)
          .update({
        "tags": _post.listToMapStringBool(_post.tags),
      });
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));

      for (final String tag in tagArray) {
        final trimedTag = tag.trim();
        if (trimedTag.isEmpty) {
          continue;
        }

        _post.tags.remove(trimedTag);
      }
    } finally {
      setState(() {
        _saving = false;
      });
    }
  }

  void onDeleteTag(String tag) async {
    _post.tags.remove(tag);

    setState(() {
      _saving = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection("posts")
          .doc(_post.id)
          .update({
        "tags": _post.listToMapStringBool(_post.tags),
      });
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
      _post.tags.add(tag);
    } finally {
      setState(() {
        _saving = false;
      });
    }
  }

  void onPageScroll(double offset) {
    final bool scrollingDown = offset - _previousOffset > 0;
    _previousOffset = offset;

    if (scrollingDown) {
      if (_showBottomActionBar) {
        setState(() => _showBottomActionBar = false);
      }

      return;
    }

    if (!_showBottomActionBar) {
      setState(() => _showBottomActionBar = true);
    }
  }

  void onPostContentChange() {
    _post = _post.copyWith(
      content: serializeDocumentToMarkdown(_document),
    );

    savePostContent();
    updateMetrics();
  }

  void onSharePost() {
    copyPostLinkToClipboard();
  }

  void onToggleLike() async {
    if (_liked) {
      return tryUnLike();
    }

    return tryLike();
  }

  void onShowAddTagModal() {
    showDialog(
      context: context,
      builder: (context) {
        return InputDialog.singleInput(
          titleValue: "tag_add".tr(),
          subtitleValue: "tag_add_description".tr(),
          submitButtonValue: "add".tr(),
          hintText: "tag_add_hint_text".tr(),
          onCancel: Beamer.of(context).popRoute,
          onSubmitted: (value) {
            Beamer.of(context).popRoute();
            onAddTag(value);
          },
        );
      },
    );
  }

  void onTitleChanged(String? value) {
    _metadataUpdateTimer?.cancel();
    _metadataUpdateTimer = Timer(const Duration(seconds: 1), savePostTitle);
  }

  void onVisibilityItemSelected(EnumContentVisibility visibility) {
    if (_post.visibility == visibility) {
      return;
    }

    updatePostVisibility(visibility);
  }

  void savePostContent() async {
    setState(() => _saving = true);

    try {
      final Reference ref =
          FirebaseStorage.instance.ref("posts/${_post.id}/content.md");

      final FullMetadata metadata = await ref.getMetadata();

      final UploadTask uploadTask = ref.putString(
        _post.content,
        metadata: SettableMetadata(customMetadata: metadata.customMetadata),
      );

      await uploadTask;
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    } finally {
      setState(() => _saving = false);
    }
  }

  void savePostTitle() async {
    setState(() => _saving = true);

    try {
      await FirebaseFirestore.instance
          .collection("posts")
          .doc(_post.id)
          .update({
        "name": _titleController.text,
        "description": _descriptionController.text,
      });
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    } finally {
      setState(() => _saving = false);
    }
  }

  void showDeleteConfirm() {
    showDialog(
      context: context,
      builder: (context) {
        return DeleteDialog(
          titleValue: "post_delete".tr(),
          descriptionValue: "post_delete_description".tr(),
          onValidate: tryDeletePost,
        );
      },
    );
  }

  void tryDeletePost() async {
    setState(() => _deleting = true);

    try {
      final response = await Utilities.cloud.fun("posts-deleteOne").call({
        "post_id": _post.id,
      });

      final data = PostResponse.fromJSON(response.data);

      if (data.success) {
        _deleting = false;
        navigateBack();
        return;
      }

      throw ErrorDescription("post_delete_failed".tr());
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
      setState(() => _deleting = false);
    }
  }

  void tryLike() async {
    try {
      final String? userId = ref.read(AppState.userProvider).firestoreUser?.id;

      await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("user_likes")
          .doc(_post.id)
          .set({
        "type": "post",
        "target_id": _post.id,
        "user_id": userId,
      });
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    }
  }

  void tryUnLike() async {
    try {
      final String? userId = ref.read(AppState.userProvider).firestoreUser?.id;

      await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("user_likes")
          .doc(_post.id)
          .delete();
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    }
  }

  void updatePostVisibility(EnumContentVisibility visibility) async {
    setState(() {
      _saving = true;
      _post = _post.copyWith(
        visibility: visibility,
      );
    });

    try {
      await FirebaseFirestore.instance
          .collection("posts")
          .doc(_post.id)
          .update({
        "visibility": visibility.name,
      });
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    } finally {
      setState(() => _saving = false);
    }
  }

  void updatePostLang(String newLanguage) async {
    setState(() => _saving = true);
    final String prevLanguage = _post.language;

    try {
      _post = _post.copyWith(language: newLanguage);

      await FirebaseFirestore.instance
          .collection("posts")
          .doc(_post.id)
          .update({
        "language": newLanguage,
      });
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));

      _post = _post.copyWith(language: prevLanguage);
    } finally {
      setState(() => _saving = false);
    }
  }

  /// Update post's character & word count.
  void updateMetrics() async {
    final regExp = RegExp(r"[\w-._]+");
    final Iterable<RegExpMatch> wordMatches = regExp.allMatches(_post.content);

    _post = _post.copyWith(
      characterCount: _post.content.length,
      wordCount: wordMatches.length,
    );

    setState(() => _saving = true);

    try {
      await FirebaseFirestore.instance
          .collection("posts")
          .doc(_post.id)
          .update({
        "character_count": _post.characterCount,
        "word_count": _post.wordCount,
      });
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    } finally {
      setState(() => _saving = false);
    }
  }
}
