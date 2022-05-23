import 'dart:async';
import 'dart:typed_data';

import 'package:artbooking/components/application_bar/application_bar.dart';
import 'package:artbooking/components/buttons/lang_popup_menu_button.dart';
import 'package:artbooking/components/dialogs/delete_dialog.dart';
import 'package:artbooking/components/user_avatar_extended.dart';
import 'package:artbooking/components/dialogs/input_dialog.dart';
import 'package:artbooking/components/loading_view.dart';
import 'package:artbooking/components/popup_menu/popup_menu_item_icon.dart';
import 'package:artbooking/globals/app_state.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/router/locations/atelier_location.dart';
import 'package:artbooking/router/locations/home_location.dart';
import 'package:artbooking/router/navigation_state_helper.dart';
import 'package:artbooking/types/cloud_functions/post_response.dart';
import 'package:artbooking/types/enums/enum_content_visibility.dart';
import 'package:artbooking/types/enums/enum_post_item_action.dart';
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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jiffy/jiffy.dart';
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
  /// True if the post is being loaded.
  bool _loading = false;

  /// True if the post is being saved.
  bool _saving = false;

  bool _deleting = false;

  /// Post model.
  var _post = Post.empty();

  /// Visible if the authenticated user has the right to edit this post.
  var _documentEditor = DocumentEditor(document: MutableDocument());

  /// Post's content.
  var _document = MutableDocument();

  /// Input controller for post's title (metadata).
  final _titleController = TextEditingController();

  /// Input controller for post's description (metadata).
  final _descriptionController = TextEditingController();

  final _pagePadding = const EdgeInsets.symmetric(
    vertical: 56,
    horizontal: 24,
  );

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final UserFirestore? userFirestore =
        ref.watch(AppState.userProvider).firestoreUser;
    final canManagePosts = userFirestore?.rights.canManagePosts ?? false;

    if (_deleting) {
      return deletingWidget();
    }

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              ApplicationBar(),
              header(canEdit: canManagePosts),
              body(canEdit: canManagePosts),
            ],
          ),
          Positioned(
            top: 100.0,
            right: 46.0,
            child: PopupMenuButton(
              icon: Icon(UniconsLine.setting),
              tooltip: "post_settings".tr(),
              itemBuilder: (_) => [
                PopupMenuItemIcon(
                  value: EnumPostItemAction.delete,
                  icon: Icon(UniconsLine.trash_alt),
                  textLabel: "delete".tr(),
                ),
              ],
              onSelected: (EnumPostItemAction action) {
                switch (action) {
                  case EnumPostItemAction.delete:
                    showDeleteConfirm();
                    break;
                  default:
                }
              },
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
        ],
      ),
    );
  }

  Widget authorsWidget() {
    if (_post.userIds.isEmpty || _post.userIds.first.isEmpty) {
      return Container();
    }

    return UserAvatarExtended(
      userId: _post.userIds.first,
      padding: const EdgeInsets.only(top: 24.0),
    );
  }

  Widget body({bool canEdit = false}) {
    if (_post.content.isEmpty) {
      return SliverToBoxAdapter();
    }

    if (_loading) {
      return LoadingView(
        title: Text(
          "loading".tr(),
        ),
      );
    }

    if (!canEdit) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: _pagePadding,
          child: SingleColumnDocumentLayout(
            presenter: SingleColumnLayoutPresenter(
              document: _document,
              componentBuilders: defaultComponentBuilders,
              pipeline: [
                SingleColumnStylesheetStyler(stylesheet: defaultStylesheet),
              ],
            ),
            componentBuilders: defaultComponentBuilders,
          ),
        ),
      );
    }

    return SliverToBoxAdapter(
      child: SuperEditor(
        editor: _documentEditor,
        stylesheet: defaultStylesheet.copyWith(
          documentPadding: const EdgeInsets.symmetric(
            vertical: 56,
            horizontal: 24,
          ),
        ),
      ),
    );
  }

  Widget dateWidget() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Wrap(
        spacing: 12.0,
        runSpacing: 12.0,
        children: [
          publishedAtWidget(),
          updatedAtWidget(),
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

  Widget descriptionWidget({bool canEdit = false}) {
    if (!canEdit && _post.description.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text(
          _post.description,
          style: Utilities.fonts.title3(
            fontSize: 14.0,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Opacity(
        opacity: 0.6,
        child: TextField(
          controller: _descriptionController,
          style: Utilities.fonts.body(
            fontSize: 14.0,
            fontWeight: FontWeight.w700,
          ),
          maxLines: null,
          onChanged: onTitleChanged,
          decoration: InputDecoration(
            hintText: "post_description".tr() + "...",
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget header({bool canEdit = false}) {
    return SliverToBoxAdapter(
      child: Center(
        child: Container(
          padding: _pagePadding,
          width: 600.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                tooltip: "back".tr(),
                onPressed: () => Beamer.of(context).beamBack(),
                icon: Icon(UniconsLine.arrow_left),
              ),
              titleWidget(canEdit: canEdit),
              descriptionWidget(canEdit: canEdit),
              dateWidget(),
              tagsWidget(canEdit: canEdit),
              pubAndLangWidgets(canEdit: canEdit),
              authorsWidget(),
            ],
          ),
        ),
      ),
    );
  }

  Widget pubAndLangWidgets({bool canEdit = false}) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Row(
        children: [
          pubWidget(canEdit: canEdit),
          Container(
            height: 40.0,
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: VerticalDivider(
              width: 2.0,
              thickness: 2.0,
            ),
          ),
          LangPopupMenuButton(
            outlined: true,
            lang: _post.language,
            onLangChanged: updatePostLang,
          ),
        ],
      ),
    );
  }

  Widget pubWidget({bool canEdit = false}) {
    if (!canEdit) {
      return Container();
    }

    final Color baseColor =
        Theme.of(context).textTheme.bodyText2?.color?.withOpacity(0.4) ??
            Colors.black;

    return PopupMenuButton(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12.0,
          vertical: 6.0,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3.0),
          border: Border.all(
            color: baseColor.withOpacity(0.3),
            width: 2.0,
          ),
        ),
        child: Text(
          _post.visibility == EnumContentVisibility.public
              ? "published".tr()
              : "visibility_private".tr(),
          style: Utilities.fonts.body(
            color: baseColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      onSelected: (EnumContentVisibility visibility) {
        if (_post.visibility == visibility) {
          return;
        }

        updatePostVisibility(visibility);
      },
      itemBuilder: (_) => [
        PopupMenuItemIcon(
          icon: Icon(UniconsLine.keyhole_square),
          textLabel: "make_private".tr(),
          value: EnumContentVisibility.private,
          selected: _post.visibility == EnumContentVisibility.private,
        ),
        PopupMenuItemIcon(
          icon: Icon(UniconsLine.envelope_upload_alt),
          textLabel: "publish".tr(),
          value: EnumContentVisibility.public,
          selected: _post.visibility == EnumContentVisibility.public,
        ),
      ],
    );
  }

  Widget titleWidget({bool canEdit = false}) {
    if (!canEdit) {
      return Text(
        _post.name,
        style: Utilities.fonts.title3(
          fontSize: 64.0,
          fontWeight: FontWeight.w700,
        ),
      );
    }

    return Hero(
      tag: _post.id,
      child: Material(
        color: Colors.transparent,
        child: TextField(
          controller: _titleController,
          style: Utilities.fonts.title3(
            fontSize: 64.0,
            fontWeight: FontWeight.w700,
          ),
          maxLines: null,
          onChanged: onTitleChanged,
          decoration: InputDecoration(
            hintText: "post_title".tr(),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget tagsWidget({bool canEdit = false}) {
    final children = <Widget>[];

    for (final String tag in _post.tags) {
      children.add(
        Chip(
          label: Opacity(
            opacity: 0.8,
            child: Text(
              tag,
              style: Utilities.fonts.body3(),
            ),
          ),
          onDeleted: canEdit ? () => onDeleteTag(tag) : null,
        ),
      );
    }

    if (canEdit) {
      children.add(
        ActionChip(
          tooltip: "tag_add".tr(),
          elevation: 2.0,
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_post.tags.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Opacity(
                    opacity: 0.8,
                    child: Text(
                      "tag_add".tr().toLowerCase(),
                      style: Utilities.fonts.body(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              Icon(UniconsLine.plus, size: 16.0),
            ],
          ),
          onPressed: showAddTagModal,
        ),
      );
    }

    return Wrap(
      spacing: 12.0,
      runSpacing: 12.0,
      children: children,
    );
  }

  Widget publishedAtWidget() {
    final publishedAt = _post.publishedAt;
    final publishedAtDiff = DateTime.now().difference(publishedAt);
    final publishedAtStr = publishedAtDiff.inDays > 20
        ? Jiffy(publishedAt).yMMMEd
        : Jiffy(publishedAt).fromNow();

    return Opacity(
      opacity: 0.8,
      child: Text(
        publishedAtStr,
        style: Utilities.fonts.body3(
          fontSize: 16.0,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget updatedAtWidget() {
    final updatedAt = _post.updatedAt;
    final bool updateSameOrBeforePub =
        Jiffy(updatedAt).isSameOrBefore(_post.publishedAt);

    final bool updatePubDiff =
        updatedAt.difference(_post.publishedAt).inMinutes < 30;

    final bool dateTooClose = updateSameOrBeforePub || updatePubDiff;

    if (_post.visibility == EnumContentVisibility.public && dateTooClose) {
      return Container();
    }

    if (updatedAt.difference(_post.createdAt).inMinutes < 10) {
      return Container();
    }

    final updatedAtDiff = DateTime.now().difference(updatedAt);
    final updatedAtStr = updatedAtDiff.inDays > 20
        ? Jiffy(updatedAt).format("dd/MM/yy")
        : Jiffy(updatedAt).fromNow();

    return Opacity(
      opacity: 0.8,
      child: Text(
        "(" + "date_last_update".tr() + ": $updatedAtStr)",
        style: Utilities.fonts.body3(
          fontSize: 16.0,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
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

  void onPostContentChange() {
    _post = _post.copyWith(
      content: serializeDocumentToMarkdown(_document),
    );

    savePostContent();
    updateMetrics();
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

  void onTitleChanged(String value) {
    _metadataUpdateTimer?.cancel();
    _metadataUpdateTimer = Timer(const Duration(seconds: 1), savePostTitle);
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

  void showAddTagModal() {
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

  void navigateBack() {
    final location = Beamer.of(context)
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
}
