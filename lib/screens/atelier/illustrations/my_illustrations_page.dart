import 'dart:async';

import 'package:artbooking/actions/illustrations.dart';
import 'package:artbooking/components/application_bar/application_bar.dart';
import 'package:artbooking/components/buttons/visibility_button.dart';
import 'package:artbooking/components/custom_scroll_behavior.dart';
import 'package:artbooking/components/popup_menu/popup_menu_icon.dart';
import 'package:artbooking/components/popup_menu/popup_menu_item_icon.dart';
import 'package:artbooking/components/dialogs/themed_dialog.dart';
import 'package:artbooking/components/dialogs/add_to_books_dialog.dart';
import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/router/locations/atelier_location.dart';
import 'package:artbooking/router/locations/home_location.dart';
import 'package:artbooking/router/navigation_state_helper.dart';
import 'package:artbooking/screens/atelier/illustrations/my_illustrations_page_body.dart';
import 'package:artbooking/screens/atelier/illustrations/my_illustrations_page_fab.dart';
import 'package:artbooking/screens/atelier/illustrations/my_illustrations_page_header.dart';
import 'package:artbooking/types/enums/enum_content_visibility.dart';
import 'package:artbooking/types/enums/enum_illustration_item_action.dart';
import 'package:artbooking/globals/app_state.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/enums/enum_visibility_tab.dart';
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
import 'package:desktop_drop/desktop_drop.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:flash/src/flash_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_improved_scrolling/flutter_improved_scrolling.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicons/unicons.dart';

class MyIllustrationsPage extends ConsumerStatefulWidget {
  MyIllustrationsPage({this.userId = ""});

  /// User's illustrations page, if provided.
  /// If [userId] is empty, the app will use the current authenticated user's id.
  final String userId;

  @override
  _MyIllustrationsPageState createState() => _MyIllustrationsPageState();
}

class _MyIllustrationsPageState extends ConsumerState<MyIllustrationsPage> {
  /// If true, multiple illustrations can be select for group actions.
  bool _forceMultiSelect = false;

  /// Disable file drop when navigating to a new page.
  bool _enableFileDrop = true;

  /// If true, there are more books to fetch.
  bool _hasNext = true;

  /// If true, a file is being dragged on the app window.
  bool _isDraggingFile = false;

  /// If true, an illustration is being dragged and we can auto-scroll on edges.
  bool _isDraggingIllustration = false;

  /// If true, illustration cards will be limited to 3 in a single row.
  bool _layoutThreeInRow = false;

  /// Loading the current page if true.
  bool _loading = false;

  /// Loading the next page if true.
  bool _loadingMore = false;

  /// Show the page floating action button if true.
  bool _showFab = false;

  var _selectedTab = EnumVisibilityTab.active;

  /// Last fetched illustration document.
  DocumentSnapshot? _lastDocument;

  /// Max illustrations to fetch per page.
  final int _limit = 20;

  final _popupFocusNode = FocusNode();

  final List<String> _allowedExt = ["jpg", "jpeg", "png", "webp", "tiff"];
  final List<Illustration> _illustrations = [];

  /// Available items for authenticated user and the illustration is not liked yet.
  final List<PopupEntryIllustration> _likePopupMenuEntries = [
    PopupMenuItemIcon(
      value: EnumIllustrationItemAction.like,
      icon: PopupMenuIcon(UniconsLine.heart),
      textLabel: "like".tr(),
    ),
  ];

  /// Items when the current authenticated user own these illustrations.
  final List<PopupEntryIllustration> _popupMenuEntries = [
    PopupMenuItemIcon(
      icon: PopupMenuIcon(UniconsLine.book_medical),
      textLabel: "add_to_book".tr(),
      value: EnumIllustrationItemAction.addToBook,
    ),
    PopupMenuItemIcon(
      icon: PopupMenuIcon(UniconsLine.trash),
      textLabel: "delete".tr(),
      value: EnumIllustrationItemAction.delete,
    ),
    PopupMenuItemIcon(
      icon: PopupMenuIcon(UniconsLine.eye),
      textLabel: "visibility_change".tr(),
      value: EnumIllustrationItemAction.updateVisibility,
    ),
  ];

  /// Available items for authenticated user
  /// and the illustration is already liked.
  final List<PopupEntryIllustration> _unlikePopupMenuEntries = [
    PopupMenuItemIcon(
      value: EnumIllustrationItemAction.unlike,
      icon: PopupMenuIcon(UniconsLine.heart_break),
      textLabel: "unlike".tr(),
    ),
  ];

  /// Group of selected illustrations.
  final Map<String, Illustration> _multiSelectedItems = Map();
  final String _layoutKey = "illustrations_three_in_a_row";

  /// Subscribe to illustration collection updates.
  QuerySnapshotStreamSubscription? _illustrationSubscription;

  /// Page scroll controller.
  final _scrollController = ScrollController();

  /// This illustration page owner's name.
  /// Used when the current authenticated user is different
  /// from the owner of this illustrations page. We can then dispay the artist.
  String _username = "";

  /// Monitors periodically scroll when dragging illustration card on edges.
  Timer? _scrollTimer;
  BeamerDelegate? _beamer;

  @override
  initState() {
    super.initState();
    loadPreferences();
    fetchData();

    // NOTE: Beamer state isn't ready on 1st frame.
    // So we use [addPostFrameCallback] to access the state in the next frame.
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      _beamer = Beamer.of(context);
      Beamer.of(context).addListener(onRouteUpdate);
    });
  }

  @override
  void dispose() {
    _illustrationSubscription?.cancel();
    _scrollController.dispose();
    _popupFocusNode.dispose();
    _multiSelectedItems.clear();
    _illustrations.clear();
    _scrollTimer?.cancel();
    _beamer?.removeListener(onRouteUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String authUserId =
        ref.watch(AppState.userProvider).firestoreUser?.id ?? "";

    final bool isOwner = (widget.userId == authUserId) ||
        (widget.userId.isEmpty && authUserId.isNotEmpty);

    final List<PopupEntryIllustration> popupMenuEntries =
        isOwner ? _popupMenuEntries : [];

    final bool authenticated = authUserId.isNotEmpty;

    return HeroControllerScope(
      controller: HeroController(),
      child: Scaffold(
        floatingActionButton: MyIllustrationsPageFab(
          show: _showFab,
          scrollController: _scrollController,
          isOwner: isOwner,
        ),
        body: Listener(
          // for auto-scoll on dragging on edges.
          onPointerMove: onPointerMove,
          child: DropTarget(
            // for file drop -> upload illustration.
            enable: _enableFileDrop && isOwner,
            onDragEntered: onDragFileEntered,
            onDragDone: onDragFileDone,
            onDragExited: onDragFileExited,
            child: Stack(
              children: [
                Container(
                  decoration: _isDraggingFile
                      ? BoxDecoration(
                          border: Border.all(
                            color: Constants.colors.tertiary,
                            width: 4.0,
                          ),
                          borderRadius: BorderRadius.circular(4.0),
                        )
                      : null,
                  child: ImprovedScrolling(
                    scrollController: _scrollController,
                    enableKeyboardScrolling: true,
                    onScroll: onScroll,
                    child: ScrollConfiguration(
                      behavior: CustomScrollBehavior(),
                      child: CustomScrollView(
                        controller: _scrollController,
                        slivers: <Widget>[
                          ApplicationBar(),
                          MyIllustrationsPageHeader(
                            isOwner: isOwner,
                            limitThreeInRow: _layoutThreeInRow,
                            multiSelectActive: _forceMultiSelect,
                            multiSelectedItems: _multiSelectedItems,
                            onAddGroupToBook: showAddGroupToBook,
                            onChangeGroupVisibility: showGroupVisibilityDialog,
                            onChangedTab: onChangedTab,
                            onClearSelection: onClearSelection,
                            onConfirmDeleteGroup: confirmDeleteGroup,
                            onGoToUserProfile: onGoToUserProfile,
                            onSelectAll: onSelectAll,
                            onTriggerMultiSelect: onTriggerMultiSelect,
                            onUpdateLayout: onUpdateLayout,
                            onUploadIllustration: uploadIllustration,
                            selectedTab: _selectedTab,
                            showBackButton: widget.userId.isNotEmpty,
                            username: _username,
                          ),
                          MyIllustrationsPageBody(
                            authenticated: authenticated,
                            forceMultiSelect: _forceMultiSelect,
                            illustrations: _illustrations,
                            isOwner: isOwner,
                            likePopupMenuEntries: _likePopupMenuEntries,
                            limitThreeInRow: _layoutThreeInRow,
                            loading: _loading,
                            multiSelectedItems: _multiSelectedItems,
                            onDoubleTap: onDoubleTapIllustrationItem,
                            onDragIllustrationCompleted:
                                onDragIllustrationCompleted,
                            onDragIllustrationEnd: onDragIllustrationEnd,
                            onDragIllustrationStarted:
                                onDragIllustrationStarted,
                            onDraggableIllustrationCanceled:
                                onDraggableIllustrationCanceled,
                            onDropIllustration: onDropIllustration,
                            onGoToActiveTab: onGoToActiveTab,
                            onPopupMenuItemSelected: onPopupMenuItemSelected,
                            onTapIllustration: onTapIllustration,
                            popupMenuEntries: popupMenuEntries,
                            selectedTab: _selectedTab,
                            unlikePopupMenuEntries: _unlikePopupMenuEntries,
                            uploadIllustration: uploadIllustration,
                          ),
                          SliverPadding(
                            padding: const EdgeInsets.only(bottom: 300.0),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                dropHint(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget dropHint() {
    if (!_isDraggingFile) {
      return Container();
    }

    return Positioned(
      bottom: 24.0,
      left: 0.0,
      right: 0.0,
      child: Align(
        alignment: Alignment.center,
        child: SizedBox(
          width: 500.0,
          child: Card(
            elevation: 6.0,
            color: Constants.colors.tertiary,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "Drop the file here to upload a new illustration",
                      style: Utilities.fonts.body(
                        color: Colors.black,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    UniconsLine.tear,
                    color: Colors.black,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Show a dialog to confirm multiple illustrations deletion.
  void confirmDeleteGroup() {
    if (_multiSelectedItems.isEmpty) {
      context.showErrorBar(content: Text("multi_select_no_item".tr()));
      return;
    }

    final Illustration illustration = _multiSelectedItems.values.first;
    final int index = _illustrations.indexWhere((x) => x.id == illustration.id);
    confirmDeleteIllustration(illustration, index);
  }

  /// Show a dialog to confirm single illustration deletion.
  void confirmDeleteIllustration(
    Illustration illustration,
    int index,
  ) async {
    showDialog(
      context: context,
      builder: (context) {
        return ThemedDialog(
          focusNode: _popupFocusNode,
          title: Column(
            children: [
              Opacity(
                opacity: 0.8,
                child: Text(
                  "illustration_delete_plural"
                      .plural(
                        _multiSelectedItems.length,
                      )
                      .toUpperCase(),
                  style: Utilities.fonts.body(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                width: 300.0,
                padding: const EdgeInsets.only(top: 8.0),
                child: Opacity(
                  opacity: 0.4,
                  child: Text(
                    "illustration_delete_description_plural".plural(
                      _multiSelectedItems.length,
                    ),
                    textAlign: TextAlign.center,
                    style: Utilities.fonts.body(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_multiSelectedItems.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.only(left: 24.0),
                    width: 300.0,
                    child: Opacity(
                      opacity: 0.6,
                      child: Text(
                        "multi_items_selected".plural(
                          _multiSelectedItems.length,
                        ),
                        style: Utilities.fonts.body(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          textButtonValidation: "delete".tr(),
          onCancel: Beamer.of(context).popRoute,
          onValidate: () {
            if (_multiSelectedItems.isEmpty) {
              deleteIllustration(illustration, index);
            } else {
              _multiSelectedItems.putIfAbsent(
                illustration.id,
                () => illustration,
              );

              deleteGroup();
            }

            Beamer.of(context).popRoute();
          },
        );
      },
    );
  }

  void deleteIllustration(Illustration illustration, int index) async {
    setState(() {
      _illustrations.removeAt(index);
    });

    final response = await IllustrationsActions.deleteOne(
      illustrationId: illustration.id,
    );

    if (response.success) {
      return;
    }

    setState(() {
      _illustrations.insert(index, illustration);
    });
  }

  void deleteGroup() async {
    _multiSelectedItems.entries.forEach((multiSelectItem) {
      _illustrations.removeWhere((item) => item.id == multiSelectItem.key);
    });

    final duplicatedItems = _multiSelectedItems.values.toList();
    final illustrationIds = _multiSelectedItems.keys.toList();

    setState(() {
      _multiSelectedItems.clear();
      _forceMultiSelect = false;
    });

    final response = await IllustrationsActions.deleteMany(
      illustrationIds: illustrationIds,
    );

    if (response.hasErrors) {
      context.showErrorBar(
        content: Text("illustrations_delete_error".tr()),
      );

      _illustrations.addAll(duplicatedItems);
    }
  }

  /// Fetch illustrations and layout (limit 3 cards in a row?).
  void fetchData() {
    Future.wait([
      fetchUser(),
      fetchLayout(),
      fetchIllustrations(),
    ]);
  }

  /// Fetch illustrations data from Firestore.
  Future<void> fetchIllustrations() async {
    setState(() {
      _loading = true;
      _illustrations.clear();
    });

    try {
      final QueryMap query = getFetchQuery();
      final QuerySnapMap snapshot = await query.get();

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

      listenIllustrationsEvents(getListenQuery());
    } catch (error) {
      Utilities.logger.e(error);
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> fetchLayout() async {
    try {
      final String userId = getUserId();

      final DocumentSnapshotMap snapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("user_settings")
          .doc("layout")
          .get();

      final Json? data = snapshot.data();
      if (!snapshot.exists || data == null) {
        return;
      }

      setState(() {
        _layoutThreeInRow = data[_layoutKey] ?? false;
      });
    } catch (error) {
      Utilities.logger.e(error);
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
    if (!_hasNext || _lastDocument == null) {
      return;
    }

    _loadingMore = true;

    try {
      final QueryMap? query = getFetchMoreQuery();
      if (query == null) {
        return;
      }

      final QuerySnapMap snapshot = await query.get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          _hasNext = false;
          _loadingMore = false;
        });

        return;
      }

      for (QueryDocSnapMap document in snapshot.docs) {
        final Json data = document.data();
        data["id"] = document.id;

        _illustrations.add(Illustration.fromMap(data));
      }

      setState(() {
        _lastDocument = snapshot.docs.last;
        _hasNext = snapshot.docs.length == _limit;
        _loadingMore = false;
      });

      listenIllustrationsEvents(getListenQuery());
    } catch (error) {
      Utilities.logger.e(error);
    } finally {
      _loadingMore = false;
    }
  }

  /// Fetch user's data. This illustrations page owner.
  /// (Launched if the the page is not owned by the current user)
  Future<void> fetchUser() async {
    if (widget.userId.isEmpty) {
      return;
    }

    if (getIsOwner()) {
      return;
    }

    try {
      final DocumentSnapshotMap snapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.userId)
          .collection("user_public_fields")
          .doc("base")
          .get();

      final Json? map = snapshot.data();
      if (!snapshot.exists || map == null) {
        return;
      }

      _username = map["name"];
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    }
  }

  /// Return query to fetch illustrations according to the selected tab.
  /// It's either active illustrations or archvied ones.
  QueryMap getFetchQuery() {
    final String userId = getUserId();

    if (!getIsOwner()) {
      return FirebaseFirestore.instance
          .collection("illustrations")
          .where("user_id", isEqualTo: userId)
          .where("visibility", isEqualTo: "public")
          .orderBy("user_custom_index", descending: true)
          .limit(_limit);
    }

    if (_selectedTab == EnumVisibilityTab.active) {
      return FirebaseFirestore.instance
          .collection("illustrations")
          .where("user_id", isEqualTo: userId)
          .where("visibility", whereIn: ["public", "private"])
          .orderBy("user_custom_index", descending: true)
          .limit(_limit);
    }

    return FirebaseFirestore.instance
        .collection("illustrations")
        .where("user_id", isEqualTo: userId)
        .where("visibility", isEqualTo: "archived")
        .orderBy("user_custom_index", descending: true)
        .limit(_limit);
  }

  /// Return query to fetch more illustrations according to the selected tab.
  /// It's either active illustrations or archvied ones.
  QueryMap? getFetchMoreQuery() {
    final lastDocument = _lastDocument;
    if (lastDocument == null) {
      return null;
    }

    final String userId = getUserId();

    if (!getIsOwner()) {
      return FirebaseFirestore.instance
          .collection("illustrations")
          .where("user_id", isEqualTo: userId)
          .where("visibility", isEqualTo: "public")
          .orderBy("user_custom_index", descending: true)
          .limit(_limit)
          .startAfterDocument(lastDocument);
    }

    if (_selectedTab == EnumVisibilityTab.active) {
      return FirebaseFirestore.instance
          .collection("illustrations")
          .where("user_id", isEqualTo: userId)
          .where("visibility", whereIn: ["public", "private"])
          .orderBy("user_custom_index", descending: true)
          .limit(_limit)
          .startAfterDocument(lastDocument);
    }

    return FirebaseFirestore.instance
        .collection("illustrations")
        .where("user_id", isEqualTo: userId)
        .where("visibility", isEqualTo: "archived")
        .orderBy("user_custom_index", descending: true)
        .limit(_limit)
        .startAfterDocument(lastDocument);
  }

  /// Return the query to listen changes to.
  QueryMap? getListenQuery() {
    final DocumentSnapshot? lastDocument = _lastDocument;
    if (lastDocument == null) {
      return null;
    }

    final String userId = getUserId();

    if (!getIsOwner()) {
      return FirebaseFirestore.instance
          .collection("illustrations")
          .where("user_id", isEqualTo: userId)
          .where("visibility", isEqualTo: "public")
          .orderBy("user_custom_index", descending: true)
          .endAtDocument(lastDocument);
    }

    if (_selectedTab == EnumVisibilityTab.active) {
      return FirebaseFirestore.instance
          .collection("illustrations")
          .where("user_id", isEqualTo: userId)
          .where("visibility", whereIn: ["public", "private"])
          .orderBy("user_custom_index", descending: true)
          .endAtDocument(lastDocument);
    }

    return FirebaseFirestore.instance
        .collection("illustrations")
        .where("user_id", isEqualTo: userId)
        .where("visibility", isEqualTo: "archived")
        .orderBy("user_custom_index", descending: true)
        .endAtDocument(lastDocument);
  }

  /// Return either the user's id page parameter
  /// or the current authenticated user's id.
  String getUserId() {
    if (widget.userId.isNotEmpty) {
      return widget.userId;
    }

    return ref.read(AppState.userProvider).firestoreUser?.id ?? "";
  }

  /// Return true if the current authenticated user is the owner
  /// of this illustrations page.
  bool getIsOwner() {
    final authUserId = ref.read(AppState.userProvider).firestoreUser?.id ?? "";

    if (widget.userId.isEmpty && authUserId.isNotEmpty) {
      return true;
    }

    return authUserId == widget.userId;
  }

  void loadPreferences() {
    _selectedTab = Utilities.storage.getIllustrationsTab();
  }

  /// Listen to tillustrations'events.
  void listenIllustrationsEvents(QueryMap? query) {
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

  void multiSelectIllustration(Illustration illustration) {
    final selected = _multiSelectedItems.containsKey(illustration.id);

    if (selected) {
      setState(() {
        _multiSelectedItems.remove(illustration.id);
        _forceMultiSelect = _multiSelectedItems.length > 0;
      });

      return;
    }

    setState(() {
      _multiSelectedItems.putIfAbsent(illustration.id, () => illustration);
    });
  }

  void navigateToIllustrationPage(Illustration illustration) {
    NavigationStateHelper.illustration = illustration;

    String route = HomeLocation.userIllustrationRoute
        .replaceFirst(":userId", getUserId())
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

  /// Fire when a new illustration is created in the collection.
  /// Add the corresponding document in the UI.
  void onAddStreamingIllustration(DocumentChangeMap documentChange) {
    final data = documentChange.doc.data();

    if (data == null) {
      return;
    }

    setState(() {
      data['id'] = documentChange.doc.id;
      final illustration = Illustration.fromMap(data);
      _illustrations.insert(0, illustration);
    });
  }

  void onChangedTab(EnumVisibilityTab selectedTab) {
    setState(() {
      _selectedTab = selectedTab;
    });

    fetchData();
    Utilities.storage.saveIllustrationsTab(selectedTab);
  }

  void onClearSelection() {
    setState(() {
      _multiSelectedItems.clear();
      _forceMultiSelect = _multiSelectedItems.length > 0;
    });
  }

  void onDoubleTapIllustrationItem(Illustration illustration, int index) {
    onLike(illustration, index);
  }

  /// Callback event fired when files are dropped on this page.
  /// Try to upload them as image and create correspondig illustrations.
  void onDragFileDone(DropDoneDetails dropDoneDetails) async {
    final List<FilePickerCross> files = [];

    for (final file in dropDoneDetails.files) {
      final int length = await file.length();

      if (length > 25000000) {
        context.showErrorBar(
          content: Text(
            "illustration_upload_size_limit".tr(
              args: [file.name, length.toString(), "25"],
            ),
          ),
        );
        continue;
      }

      final int dotIndex = file.path.lastIndexOf(".");
      final String extension = file.path.substring(dotIndex + 1);

      if (!_allowedExt.contains(extension)) {
        context.showErrorBar(
          content: Text(
            "illustration_upload_invalid_extension".tr(
              args: [file.name, _allowedExt.join(", ")],
            ),
          ),
        );
        continue;
      }

      final FilePickerCross filePickerCross = FilePickerCross(
        await file.readAsBytes(),
        path: file.path,
        type: FileTypeCross.image,
        fileExtension: extension,
      );

      files.add(filePickerCross);
    }

    ref.read(AppState.uploadTaskListProvider.notifier).handleDropFiles(files);
  }

  /// Callback event fired when a pointer enters this page with files.
  void onDragFileEntered(DropEventDetails dropEventDetails) {
    setState(() => _isDraggingFile = true);
  }

  /// Callback event fired when a pointer exits this page with files.
  void onDragFileExited(DropEventDetails dropEventDetails) {
    setState(() => _isDraggingFile = false);
  }

  void onDragIllustrationCompleted() {
    _isDraggingIllustration = false;
  }

  void onDragIllustrationEnd(DraggableDetails p1) {
    _isDraggingIllustration = false;
  }

  void onDragIllustrationStarted() {
    _isDraggingIllustration = true;
  }

  void onDraggableIllustrationCanceled(Velocity velocity, Offset offset) {
    _isDraggingIllustration = false;
  }

  void onDropIllustration(int dropIndex, List<int> dragIndexes) async {
    final int firstDragIndex = dragIndexes.first;
    if (dropIndex == firstDragIndex) {
      return;
    }

    if (dropIndex < 0 ||
        firstDragIndex < 0 ||
        dropIndex >= _illustrations.length ||
        firstDragIndex > _illustrations.length) {
      return;
    }

    final Illustration dropIllustration = _illustrations.elementAt(dropIndex);
    final dragIllustration = _illustrations.elementAt(firstDragIndex);

    final int dropUserCustomIndex = dropIllustration.userCustomIndex;
    final int dragUserCustomIndex = dragIllustration.userCustomIndex;

    final Illustration newDropIllustration = dropIllustration.copyWith(
      userCustomIndex: dragUserCustomIndex,
    );

    final Illustration newDragIllustration = dragIllustration.copyWith(
      userCustomIndex: dropUserCustomIndex,
    );

    setState(() {
      _illustrations[firstDragIndex] = newDropIllustration;
      _illustrations[dropIndex] = newDragIllustration;
    });

    try {
      await FirebaseFirestore.instance
          .collection("illustrations")
          .doc(newDragIllustration.id)
          .update({
        "user_custom_index": newDragIllustration.userCustomIndex,
      });

      await FirebaseFirestore.instance
          .collection("illustrations")
          .doc(newDropIllustration.id)
          .update({
        "user_custom_index": newDropIllustration.userCustomIndex,
      });
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    }
  }

  void onGoToActiveIllustrations() {
    onChangedTab(EnumVisibilityTab.active);
  }

  void onGoToActiveTab() {
    onChangedTab(EnumVisibilityTab.active);
  }

  void onGoToUserProfile() {
    Beamer.of(context).beamToNamed(
      HomeLocation.profileRoute.replaceFirst(":userId", widget.userId),
      routeState: {
        "userId": widget.userId,
      },
    );
  }

  void onLike(Illustration illustration, int index) {
    if (illustration.liked) {
      return tryUnLike(illustration, index);
    }

    return tryLike(illustration, index);
  }

  void onLongPressIllustration(key, illustration, selected) {
    if (selected) {
      setState(() {
        _multiSelectedItems.remove(illustration.id);
      });

      return;
    }

    setState(() {
      _multiSelectedItems.putIfAbsent(
        illustration.id,
        () => illustration,
      );
    });
  }

  bool onScrollNotification(ScrollNotification notification) {
    // FAB visibility
    if (notification.metrics.pixels < 50 && _showFab) {
      setState(() => _showFab = false);
    } else if (notification.metrics.pixels > 50 && !_showFab) {
      setState(() => _showFab = true);
    }

    if (notification.metrics.pixels < notification.metrics.maxScrollExtent) {
      return false;
    }

    if (_hasNext && !_loadingMore) {
      fetchMoreIllustrations();
    }

    return false;
  }

  void onTapIllustration(Illustration illustration) {
    if (_multiSelectedItems.isEmpty && !_forceMultiSelect) {
      navigateToIllustrationPage(illustration);
      return;
    }

    multiSelectIllustration(illustration);
  }

  /// Callback fired when a pointer is down and moves.
  void onPointerMove(PointerMoveEvent pointerMoveEvent) {
    if (!_isDraggingIllustration) {
      _scrollTimer?.cancel();
      return;
    }

    final int duration = 50;

    /// Amount of offset to jump when dragging an element to the edge.
    final double jumpOffset = 42.0;
    final double dy = pointerMoveEvent.position.dy;

    /// Distance to the edge where the scroll viewer starts to jump.
    final double scrollTreshold = 100.0;

    if (dy < scrollTreshold && _scrollController.offset > 0) {
      _scrollTimer?.cancel();
      _scrollTimer = Timer.periodic(
        Duration(milliseconds: duration),
        (Timer timer) {
          _scrollController.animateTo(
            _scrollController.offset - jumpOffset,
            duration: Duration(milliseconds: duration),
            curve: Curves.easeIn,
          );

          if (_scrollController.position.outOfRange) {
            _scrollTimer?.cancel();
          }
        },
      );

      return;
    }

    final double windowHeight = MediaQuery.of(context).size.height;
    final bool pointerIsAtBottom = dy >= windowHeight - scrollTreshold;
    final bool scrollIsAtBottomEdge =
        _scrollController.offset >= _scrollController.position.maxScrollExtent;

    if (pointerIsAtBottom && !scrollIsAtBottomEdge) {
      _scrollTimer?.cancel();
      _scrollTimer = Timer.periodic(
        Duration(milliseconds: duration),
        (Timer timer) {
          _scrollController.animateTo(
            _scrollController.offset + jumpOffset,
            duration: Duration(milliseconds: duration),
            curve: Curves.easeIn,
          );

          if (_scrollController.position.outOfRange) {
            _scrollTimer?.cancel();
          }
        },
      );
      return;
    }

    _scrollTimer?.cancel();
  }

  void onPopupMenuItemSelected(
    EnumIllustrationItemAction action,
    int index,
    Illustration illustration,
    String illustrationKey,
  ) {
    switch (action) {
      case EnumIllustrationItemAction.delete:
        confirmDeleteIllustration(illustration, index);
        break;
      case EnumIllustrationItemAction.addToBook:
        showAddToBook(illustration);
        break;
      case EnumIllustrationItemAction.updateVisibility:
        showVisibilityDialog(illustration, index);
        break;
      default:
        break;
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

  /// Callback fired when route changes.
  void onRouteUpdate() {
    final String? stringLocation = Beamer.of(context)
        .beamingHistory
        .last
        .history
        .last
        .routeInformation
        .location;

    _enableFileDrop =
        stringLocation == AtelierLocationContent.illustrationsRoute;
  }

  /// Callback when the page scrolls up and down.
  void onScroll(double scrollOffset) {
    if (scrollOffset < 50 && _showFab) {
      setState(() => _showFab = false);
      return;
    }

    if (scrollOffset > 50 && !_showFab) {
      setState(() => _showFab = true);
    }

    if (_scrollController.position.atEdge &&
        scrollOffset > 50 &&
        _hasNext &&
        !_loadingMore) {
      fetchMoreIllustrations();
    }
  }

  void onSelectAll() {
    _illustrations.forEach((illustration) {
      _multiSelectedItems.putIfAbsent(illustration.id, () => illustration);
    });

    setState(() {});
  }

  void onTriggerMultiSelect() {
    setState(() {
      _forceMultiSelect = !_forceMultiSelect;
    });
  }

  void onUpdateLayout() async {
    try {
      setState(() {
        _layoutThreeInRow = !_layoutThreeInRow;
      });

      final String? userId = ref.read(AppState.userProvider).firestoreUser?.id;
      await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("user_settings")
          .doc("layout")
          .update({
        _layoutKey: _layoutThreeInRow,
      });
    } catch (error) {
      Utilities.logger.e(error);
    }
  }

  /// Fire when a new document has been updated in Firestore.
  /// Update the corresponding document in the UI.
  void onUpdateStreamingIllustration(DocumentChangeMap documentChange) {
    final data = documentChange.doc.data();
    if (!documentChange.doc.exists || data == null) {
      return;
    }

    final int index = _illustrations.indexWhere(
      (illustration) => illustration.id == documentChange.doc.id,
    );

    if (index < 0) {
      return;
    }

    data["id"] = documentChange.doc.id;
    final updatedIllustration = Illustration.fromMap(data);

    setState(() {
      _illustrations.removeAt(index);
      _illustrations.insert(index, updatedIllustration);
    });
  }

  void showAddGroupToBook() {
    if (_multiSelectedItems.isEmpty) {
      context.showErrorBar(content: Text("multi_select_no_item".tr()));
      return;
    }

    final Illustration illustration = _multiSelectedItems.values.first;
    showAddToBook(illustration);
  }

  void showAddToBook(Illustration illustration) {
    showDialog(
      context: context,
      builder: (context) {
        return AddToBooksDialog(
          illustrations: [illustration] + _multiSelectedItems.values.toList(),
          onComplete: () {
            onClearSelection();
          },
        );
      },
    );
  }

  void showGroupVisibilityDialog() {
    if (_multiSelectedItems.isEmpty) {
      context.showErrorBar(content: Text("multi_select_no_item".tr()));
      return;
    }

    final Illustration illustration = _multiSelectedItems.values.first;
    final int index = _illustrations.indexWhere((x) => x.id == illustration.id);
    showVisibilityDialog(illustration, index);
  }

  void showVisibilityDialog(Illustration illustration, int index) {
    final width = 310.0;

    showDialog(
      context: context,
      builder: (context) => ThemedDialog(
        showDivider: true,
        titleValue: "illustration_visibility_change".plural(
          _multiSelectedItems.length,
        ),
        textButtonValidation: "close".tr(),
        onValidate: Beamer.of(context).popRoute,
        onCancel: Beamer.of(context).popRoute,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_multiSelectedItems.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.only(left: 16.0),
                    width: width,
                    child: Opacity(
                      opacity: 0.6,
                      child: Text(
                        "multi_items_selected".plural(
                          _multiSelectedItems.length,
                        ),
                        style: Utilities.fonts.body(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.only(left: 16.0),
                  width: width,
                  child: Opacity(
                    opacity: 0.6,
                    child: Text(
                      "illustration_visibility_choose".plural(
                        _multiSelectedItems.length,
                      ),
                      style: Utilities.fonts.body(
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ),
                VisibilityButton(
                  maxWidth: width,
                  group: _multiSelectedItems.isNotEmpty,
                  visibility: illustration.visibility,
                  onChangedVisibility: (visibility) {
                    if (_multiSelectedItems.isEmpty) {
                      updateVisibility(illustration, visibility, index);
                    } else {
                      _multiSelectedItems.putIfAbsent(
                        illustration.id,
                        () => illustration,
                      );

                      updateGroupVisibility(visibility);
                    }

                    Beamer.of(context).popRoute();
                    onClearSelection();
                  },
                  padding: const EdgeInsets.only(
                    left: 16.0,
                    top: 12.0,
                    bottom: 32.0,
                  ),
                ),
              ],
            ),
          ),
        ),
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

  void uploadIllustration() {
    ref.read(AppState.uploadTaskListProvider.notifier).pickImage();
  }

  void updateGroupVisibility(EnumContentVisibility visibility) {
    for (var illustration in _multiSelectedItems.values) {
      final int index = _illustrations.indexWhere(
        (x) => x.id == illustration.id,
      );

      updateVisibility(illustration, visibility, index);
    }
  }

  void updateVisibility(
    Illustration illustration,
    EnumContentVisibility visibility,
    int index,
  ) async {
    bool removedIllustration = false;

    if (_selectedTab == EnumVisibilityTab.active &&
        visibility == EnumContentVisibility.archived) {
      _illustrations.removeAt(index);
      removedIllustration = true;
    }

    if (_selectedTab == EnumVisibilityTab.archived &&
        visibility != EnumContentVisibility.archived) {
      _illustrations.removeAt(index);
      removedIllustration = true;
    }

    setState(() {});

    try {
      final response =
          await Utilities.cloud.fun("illustrations-updateVisibility").call({
        "illustration_id": illustration.id,
        "visibility": visibility.name,
      });

      if (response.data['success'] as bool) {
        return;
      }

      throw Error();
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));

      if (removedIllustration) {
        setState(() {
          _illustrations.insert(index, illustration);
        });
      }
    }
  }
}
