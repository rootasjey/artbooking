// ignore: unused_import
import 'package:artbooking/components/buttons/dark_text_button.dart';
import 'package:artbooking/components/cards/create_post_card.dart';
import 'package:artbooking/components/cards/post_card.dart';
import 'package:artbooking/components/cards/shimmer_card.dart';
import 'package:artbooking/components/icons/animated_app_icon.dart';
import 'package:artbooking/components/popup_menu/popup_menu_item_icon.dart';
import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/router/locations/home_location.dart';
import 'package:artbooking/router/navigation_state_helper.dart';
import 'package:artbooking/screens/atelier/profile/popup_menu_button_section.dart';
import 'package:artbooking/types/enums/enum_post_item_action.dart';
import 'package:artbooking/types/enums/enum_section_action.dart';
import 'package:artbooking/types/enums/enum_section_data_mode.dart';
import 'package:artbooking/types/enums/enum_select_type.dart';
import 'package:artbooking/types/firestore/query_doc_snap_map.dart';
import 'package:artbooking/types/firestore/document_change_map.dart';
import 'package:artbooking/types/firestore/document_snapshot_map.dart';
import 'package:artbooking/types/firestore/query_map.dart';
import 'package:artbooking/types/firestore/query_snap_map.dart';
import 'package:artbooking/types/firestore/query_snapshot_stream_subscription.dart';
import 'package:artbooking/types/json_types.dart';
import 'package:artbooking/types/post.dart';
import 'package:artbooking/types/section.dart';
import 'package:beamer/beamer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

/// A news section showing last published posts.
class NewsSection extends StatefulWidget {
  const NewsSection({
    Key? key,
    required this.index,
    required this.section,
    this.onPopupMenuItemSelected,
    this.popupMenuEntries = const [],
    this.isLast = false,
    this.onShowIllustrationDialog,
    this.onUpdateSectionItems,
    this.usingAsDropTarget = false,
    this.editMode = false,
    this.isHover = false,
  }) : super(key: key);

  /// If true, the current authenticated user is the owner and
  /// this section can be edited.
  final bool editMode;

  final bool isHover;
  final bool isLast;

  final bool usingAsDropTarget;
  final int index;
  final List<PopupMenuItemIcon<EnumSectionAction>> popupMenuEntries;

  final void Function(
    EnumSectionAction action,
    int index,
    Section section,
  )? onPopupMenuItemSelected;

  final void Function({
    required Section section,
    required int index,
    required EnumSelectType selectType,
  })? onShowIllustrationDialog;

  final void Function(
    Section section,
    int index,
    List<String> items,
  )? onUpdateSectionItems;

  /// Section's position in the layout (e.g. 0 is the first).
  final Section section;

  @override
  State<NewsSection> createState() => _NewsSectionState();
}

class _NewsSectionState extends State<NewsSection> {
  /// True if fetching data.
  bool _loading = false;

  /// True if currently creating a new post.
  bool _creatingPost = false;

  /// Courcircuit initState.
  /// If first execution, do a whole data fetch.
  /// Otherwise, try a data diff. and udpdate only some UI parts.
  bool _firstExecution = true;

  List<Post> _posts = [];

  /// Used to know to flush current data and refetch.
  /// Otherwise, simply do a data diff. and update only some UI parts.
  var _currentMode = EnumSectionDataMode.sync;

  /// News posts collection subscription.
  /// We use this stream to listen to collection changes (add, update, delete).
  QuerySnapshotStreamSubscription? _postSubscription;

  @override
  initState() {
    super.initState();
    _currentMode = widget.section.dataFetchMode;
  }

  @override
  void dispose() {
    _posts.clear();
    _postSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.usingAsDropTarget) {
      checkData();
    }

    if (_loading) {
      return loadingWidget();
    }

    if (_creatingPost) {
      return creatingWidget();
    }

    final EdgeInsets outerPadding =
        widget.usingAsDropTarget ? const EdgeInsets.all(4.0) : EdgeInsets.zero;

    final BoxDecoration boxDecoration = widget.usingAsDropTarget
        ? BoxDecoration(
            borderRadius: BorderRadius.circular(4.0),
            border: Border.all(
              color: Theme.of(context).primaryColor,
              width: 3.0,
            ),
            color: Color(widget.section.backgroundColor),
          )
        : BoxDecoration(
            color: Color(widget.section.backgroundColor),
          );

    return Padding(
      padding: outerPadding,
      child: Stack(
        children: [
          Container(
            decoration: boxDecoration,
            padding: const EdgeInsets.only(
              left: 64.0,
              right: 12.0,
              top: 24.0,
              bottom: 24.0,
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 300.0,
                  child: titleSectionWidget(),
                ),
                Container(
                  padding: const EdgeInsets.only(right: 24.0, top: 32.0),
                  height: 320.0,
                  child: VerticalDivider(
                    color: Constants.colors.tertiary,
                    thickness: 4.0,
                  ),
                ),
                Container(
                  height: 336.0,
                  padding: const EdgeInsets.only(top: 34.0),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemExtent: 240.0,
                    children: getChildren(),
                  ),
                ),
              ],
            ),
          ),
          rightPopupMenuButton(),
        ],
      ),
    );
  }

  Widget creatingWidget() {
    return Center(
      child: Column(
        children: [
          AnimatedAppIcon(),
          Opacity(
            opacity: 0.8,
            child: Text(
              // "Creating new post...",
              "post_creating".tr() + "...",
              style: Utilities.fonts.body3(
                fontSize: 42.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Opacity(
            opacity: 0.4,
            child: Text(
              "fun_sentences.wood".tr(),
              style: Utilities.fonts.body(
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> getChildren() {
    int index = -1;

    final List<PopupMenuEntry<EnumPostItemAction>> popupMenuEntries =
        widget.editMode
            ? [
                PopupMenuItemIcon(
                  icon: Icon(UniconsLine.minus),
                  textLabel: "remove".tr(),
                  value: EnumPostItemAction.remove,
                ),
              ]
            : [];

    final List<Widget> children = [
      if (widget.editMode)
        CreatePostCard(
          borderColor: Constants.colors.tertiary,
          onTap: createNewPost,
        ),
    ];

    for (final Post post in _posts) {
      index++;
      final heroTag = "${widget.section.id}-${index}-${post.id}";

      children.add(
        PostCard(
          post: post,
          index: index,
          heroTag: heroTag,
          onTap: goToPostPage,
          popupMenuEntries: popupMenuEntries,
          onPopupMenuItemSelected: onPostItemSelected,
        ),
      );
    }

    return children;
  }

  List<PopupMenuItemIcon<EnumSectionAction>> getPopupMenuEntries() {
    final popupMenuEntries = widget.popupMenuEntries.sublist(0);

    if (widget.index == 0) {
      popupMenuEntries.removeWhere((x) => x.value == EnumSectionAction.moveUp);
    }

    if (widget.isLast) {
      popupMenuEntries.removeWhere(
        (x) => x.value == EnumSectionAction.moveDown,
      );
    }

    if (_currentMode == EnumSectionDataMode.chosen) {
      popupMenuEntries.add(
        PopupMenuItemIcon(
          icon: Icon(UniconsLine.plus),
          textLabel: "illustrations_select".tr(),
          value: EnumSectionAction.selectIllustrations,
        ),
      );
    }

    return popupMenuEntries;
  }

  Widget loadingWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 90.9,
        vertical: 24.0,
      ),
      child: Wrap(
        spacing: 24.0,
        runSpacing: 12.0,
        children: [
          ShimmerCard(),
          ShimmerCard(),
        ],
      ),
    );
  }

  Widget rightPopupMenuButton() {
    if (!widget.editMode) {
      return Container();
    }

    return PopupMenuButtonSection(
      show: widget.isHover,
      itemBuilder: (_) => getPopupMenuEntries(),
      onSelected: (EnumSectionAction action) {
        widget.onPopupMenuItemSelected?.call(
          action,
          widget.index,
          widget.section,
        );
      },
    );
  }

  Widget titleSectionWidget() {
    final title = widget.section.name;
    final description = widget.section.description;

    if (title.isEmpty && description.isEmpty) {
      return Container();
    }

    return Column(
      children: [
        InkWell(
          onTap: onTapTitleDescription,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title.isNotEmpty)
                Opacity(
                  opacity: 0.9,
                  child: Text(
                    title,
                    style: Utilities.fonts.body2(
                      fontSize: 78.0,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              if (description.isNotEmpty)
                Opacity(
                  opacity: 0.4,
                  child: Text(
                    description,
                    style: Utilities.fonts.body2(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// (BAD) Check for changes and fetch new data a change is detected.
  /// WARNING: This is anti-pattern to `setState()` inside of a `build()` method.
  void checkData() {
    if (_firstExecution) {
      _firstExecution = false;
      fetchPosts();
      return;
    }

    if (_currentMode != widget.section.dataFetchMode) {
      _currentMode = widget.section.dataFetchMode;
      _currentMode == EnumSectionDataMode.sync ? fetchPosts() : null;
    }

    if (_currentMode == EnumSectionDataMode.chosen) {
      // diffIllustration();
    }
  }

  void createNewPost() async {
    setState(() => _creatingPost = true);

    try {
      final HttpsCallableResult<dynamic> response =
          await Utilities.cloud.fun("posts-createOne").call({
        "language": context.locale.languageCode,
      });

      final bool success = response.data["success"];

      if (!success) {
        throw ErrorDescription("post_create_error".tr());
      }

      final String postId = response.data["post"]["id"];

      NavigationStateHelper.post = null;
      Beamer.of(context).beamToNamed(
        HomeLocation.postRoute.replaceFirst(":postId", postId),
        routeState: {
          "postId": postId,
        },
      );
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    } finally {
      setState(() => _creatingPost = false);
    }
  }

  void fetchPosts() {
    if (_loading) {
      return;
    }

    if (widget.section.dataFetchMode == EnumSectionDataMode.sync) {
      fetchSyncPosts();
      return;
    }
  }

  void fetchSyncPosts() async {
    try {
      final QueryMap query = await FirebaseFirestore.instance
          .collection("posts")
          .where("visibility", isEqualTo: "public")
          .orderBy("published_at", descending: true)
          .limit(4);

      listenToCollectionChanges(query);
      final QuerySnapMap snapshot = await query.get();

      if (snapshot.docs.isEmpty) {
        return;
      }

      for (final QueryDocSnapMap doc in snapshot.docs) {
        final Json map = doc.data();
        map["id"] = doc.id;
        _posts.add(Post.fromMap(map));
      }
    } catch (error) {
      Utilities.logger.e(error);
    } finally {
      setState(() => _loading = false);
    }
  }

  bool getCanDrag() {
    if (!widget.editMode) {
      return false;
    }

    return _currentMode == EnumSectionDataMode.chosen;
  }

  void goToPostPage(Post post, String heroTag) {
    NavigationStateHelper.post = post;
    Beamer.of(context).beamToNamed(
      HomeLocation.postRoute.replaceFirst(":postId", post.id),
      routeState: {
        "postId": post.id,
      },
    );
  }

  void listenToCollectionChanges(Query<Map<String, dynamic>> query) {
    _postSubscription?.cancel();
    _postSubscription = query.snapshots().skip(1).listen((snapshot) {
      for (DocumentChangeMap documentChange in snapshot.docChanges) {
        switch (documentChange.type) {
          case DocumentChangeType.added:
            onAddStreamingNews(documentChange);
            break;
          case DocumentChangeType.modified:
            onUpdateStreamingNews(documentChange);
            break;
          case DocumentChangeType.removed:
            onRemoveStreamingNews(documentChange);
            break;
        }
      }

      setState(() {});
    });
  }

  void onAddStreamingNews(DocumentChangeMap documentChange) {
    final DocumentSnapshotMap doc = documentChange.doc;
    final Json? map = doc.data();
    if (map == null) {
      return;
    }

    map["id"] = doc.id;
    _posts.add(Post.fromMap(map));
  }

  void onRemoveStreamingNews(DocumentChangeMap documentChange) {
    _posts.removeWhere((p) => p.id == documentChange.doc.id);
  }

  void onUpdateStreamingNews(DocumentChangeMap documentChange) {
    final DocumentSnapshotMap doc = documentChange.doc;
    final Json? newMap = doc.data();
    if (newMap == null) {
      return;
    }

    newMap["id"] = doc.id;

    final int index = _posts.indexWhere((p) => p.id == doc.id);
    _posts.replaceRange(index, index + 1, [Post.fromMap(newMap)]);
  }

  void onPostItemSelected(
    EnumPostItemAction action,
    int index,
    Post post,
  ) {
    switch (action) {
      case EnumPostItemAction.remove:
        setState(() {
          _posts.removeWhere((x) => x.id == post.id);
        });

        List<String> items = widget.section.items;
        items.removeWhere((x) => x == post.id);
        widget.onUpdateSectionItems?.call(widget.section, widget.index, items);

        break;
      default:
    }
  }

  void onTapTitleDescription() {
    widget.onPopupMenuItemSelected?.call(
      EnumSectionAction.rename,
      widget.index,
      widget.section,
    );
  }

  void setSyncDataMode() {
    widget.onPopupMenuItemSelected?.call(
      EnumSectionAction.setSyncDataMode,
      widget.index,
      widget.section,
    );
  }
}
