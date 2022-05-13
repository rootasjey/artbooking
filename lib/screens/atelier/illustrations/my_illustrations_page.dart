import 'dart:async';

import 'package:artbooking/actions/illustrations.dart';
import 'package:artbooking/components/application_bar/application_bar.dart';
import 'package:artbooking/components/buttons/visibility_button.dart';
import 'package:artbooking/components/custom_scroll_behavior.dart';
import 'package:artbooking/components/popup_menu/popup_menu_item_icon.dart';
import 'package:artbooking/components/dialogs/themed_dialog.dart';
import 'package:artbooking/components/dialogs/add_to_books_dialog.dart';
import 'package:artbooking/router/locations/atelier_location.dart';
import 'package:artbooking/router/navigation_state_helper.dart';
import 'package:artbooking/screens/atelier/illustrations/my_illustrations_page_body.dart';
import 'package:artbooking/screens/atelier/illustrations/my_illustrations_page_fab.dart';
import 'package:artbooking/screens/atelier/illustrations/my_illustrations_page_header.dart';
import 'package:artbooking/types/enums/enum_content_visibility.dart';
import 'package:artbooking/types/enums/enum_illustration_item_action.dart';
import 'package:artbooking/globals/app_state.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/enums/enum_visibility_tab.dart';
import 'package:artbooking/types/firestore/query_doc_snap_map.dart';
import 'package:artbooking/types/firestore/document_change_map.dart';
import 'package:artbooking/types/firestore/query_map.dart';
import 'package:artbooking/types/firestore/query_snapshot_stream_subscription.dart';
import 'package:artbooking/types/illustration/illustration.dart';
import 'package:artbooking/types/json_types.dart';
import 'package:beamer/beamer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flash/src/flash_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_improved_scrolling/flutter_improved_scrolling.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicons/unicons.dart';

class MyIllustrationsPage extends ConsumerStatefulWidget {
  @override
  _MyIllustrationsPageState createState() => _MyIllustrationsPageState();
}

class _MyIllustrationsPageState extends ConsumerState<MyIllustrationsPage> {
  bool _forceMultiSelect = false;
  bool _hasNext = true;
  bool _loading = false;
  bool _loadingMore = false;
  bool _showFab = false;

  /// If true, illustration cards will be limited to 3 in a single row.
  bool _layoutThreeInRow = false;

  /// Last fetched illustration document.
  DocumentSnapshot? _lastDocument;

  /// /// Amount of offset to jump when dragging an element to the edge.
  final double _jumpOffset = 200.0;

  /// Distance to the edge where the scroll viewer starts to jump.
  final double _edgeDistance = 200.0;

  final int _limit = 20;

  final _illustrations = <Illustration>[];

  final _popupMenuEntries = <PopupMenuEntry<EnumIllustrationItemAction>>[
    PopupMenuItemIcon(
      icon: Icon(UniconsLine.book_medical),
      textLabel: "add_to_book".tr(),
      value: EnumIllustrationItemAction.addToBook,
    ),
    PopupMenuItemIcon(
      icon: Icon(UniconsLine.trash),
      textLabel: "delete".tr(),
      value: EnumIllustrationItemAction.delete,
    ),
    PopupMenuItemIcon(
      icon: Icon(UniconsLine.eye),
      textLabel: "visibility_change".tr(),
      value: EnumIllustrationItemAction.updateVisibility,
    ),
  ];

  final _popupFocusNode = FocusNode();

  final String _layoutKey = "illustrations_three_in_a_row";

  Map<String, Illustration> _multiSelectedItems = Map();
  ScrollController _scrollController = ScrollController();
  QuerySnapshotStreamSubscription? _illustrationSubscription;

  var _selectedTab = EnumVisibilityTab.active;

  @override
  initState() {
    super.initState();
    loadPreferences();
    fetchData();
  }

  @override
  void dispose() {
    _illustrationSubscription?.cancel();
    _scrollController.dispose();
    _popupFocusNode.dispose();
    _multiSelectedItems.clear();
    _illustrations.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HeroControllerScope(
      controller: HeroController(),
      child: Scaffold(
        floatingActionButton: MyIllustrationsPageFab(
          show: _showFab,
          scrollController: _scrollController,
        ),
        body: ImprovedScrolling(
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
                  multiSelectedItems: _multiSelectedItems,
                  multiSelectActive: _forceMultiSelect,
                  onUploadIllustration: uploadIllustration,
                  onClearSelection: onClearSelection,
                  onSelectAll: onSelectAll,
                  onTriggerMultiSelect: onTriggerMultiSelect,
                  onConfirmDeleteGroup: confirmDeleteGroup,
                  selectedTab: _selectedTab,
                  onChangedTab: onChangedTab,
                  limitThreeInRow: _layoutThreeInRow,
                  onUpdateLayout: onUpdateLayout,
                  onChangeGroupVisibility: showGroupVisibilityDialog,
                  onAddGroupToBook: showAddGroupToBook,
                ),
                MyIllustrationsPageBody(
                  forceMultiSelect: _forceMultiSelect,
                  illustrations: _illustrations,
                  loading: _loading,
                  multiSelectedItems: _multiSelectedItems,
                  onDragUpdateIllustration: onDragUpdateIllustration,
                  onDropIllustration: onDropIllustration,
                  onGoToActiveTab: onGoToActiveTab,
                  onPopupMenuItemSelected: onPopupMenuItemSelected,
                  onTapIllustration: onTapIllustration,
                  popupMenuEntries: _popupMenuEntries,
                  selectedTab: _selectedTab,
                  limitThreeInRow: _layoutThreeInRow,
                  uploadIllustration: uploadIllustration,
                ),
                SliverPadding(padding: const EdgeInsets.only(bottom: 300.0)),
              ],
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
                  style: Utilities.fonts.style(
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
                    style: Utilities.fonts.style(
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
                        style: Utilities.fonts.style(
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

  /// Return query to fetch illustrations according to the selected tab.
  /// It's either active illustrations or archvied ones.
  QueryMap getFetchQuery() {
    final String? userId = ref.read(AppState.userProvider).firestoreUser?.id;

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

    final String? userId = ref.read(AppState.userProvider).firestoreUser?.id;

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

  /// Fetch illustrations and layout (limit 3 cards in a row?).
  void fetchData() {
    Future.wait([
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

      listenIllustrationsEvents(query);
      final snapshot = await query.get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          _loading = false;
          _hasNext = false;
        });

        return;
      }

      for (QueryDocSnapMap document in snapshot.docs) {
        final data = document.data();
        data["id"] = document.id;
        _illustrations.add(Illustration.fromMap(data));
      }

      setState(() {
        _lastDocument = snapshot.docs.last;
        _hasNext = snapshot.docs.length == _limit;
      });
    } catch (error) {
      Utilities.logger.e(error);
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> fetchLayout() async {
    try {
      final String? userId = ref.read(AppState.userProvider).firestoreUser?.id;
      final snapshot = await FirebaseFirestore.instance
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

      listenIllustrationsEvents(query);
      final snapshot = await query.get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          _hasNext = false;
          _loadingMore = false;
        });

        return;
      }

      for (QueryDocSnapMap document in snapshot.docs) {
        final data = document.data();
        data['id'] = document.id;

        _illustrations.add(Illustration.fromMap(data));
      }

      setState(() {
        _lastDocument = snapshot.docs.last;
        _hasNext = snapshot.docs.length == _limit;
        _loadingMore = false;
      });
    } catch (error) {
      Utilities.logger.e(error);
    } finally {
      _loadingMore = false;
    }
  }

  void loadPreferences() {
    _selectedTab = Utilities.storage.getIllustrationsTab();
  }

  /// Listen to tillustrations'events.
  void listenIllustrationsEvents(QueryMap query) {
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
    Beamer.of(context).beamToNamed(
      AtelierLocationContent.illustrationRoute.replaceFirst(
        ":illustrationId",
        illustration.id,
      ),
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

  void onDragUpdateIllustration(DragUpdateDetails details) async {
    final position = details.globalPosition;

    if (position.dy < _edgeDistance) {
      if (_scrollController.offset <= 0) {
        return;
      }

      await _scrollController.animateTo(
        _scrollController.offset - _jumpOffset,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );

      return;
    }

    final windowHeight = MediaQuery.of(context).size.height;
    if (windowHeight - _edgeDistance < position.dy) {
      if (_scrollController.position.atEdge && _scrollController.offset != 0) {
        return;
      }

      await _scrollController.animateTo(
        _scrollController.offset + _jumpOffset,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
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
      setState(() {
        _showFab = false;
      });
    } else if (notification.metrics.pixels > 50 && !_showFab) {
      setState(() {
        _showFab = true;
      });
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
                        style: Utilities.fonts.style(
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
                      style: Utilities.fonts.style(
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
