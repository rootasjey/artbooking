import 'package:artbooking/actions/illustrations.dart';
import 'package:artbooking/components/application_bar/application_bar.dart';
import 'package:artbooking/components/popup_menu/popup_menu_item_icon.dart';
import 'package:artbooking/components/dialogs/themed_dialog.dart';
import 'package:artbooking/components/add_to_book_panel.dart';
import 'package:artbooking/router/navigation_state_helper.dart';
import 'package:artbooking/screens/dashboard/illustrations/my_illustrations_page_body.dart';
import 'package:artbooking/screens/dashboard/illustrations/my_illustrations_page_fab.dart';
import 'package:artbooking/screens/dashboard/illustrations/my_illustrations_page_header.dart';
import 'package:artbooking/types/enums/enum_illustration_item_action.dart';
import 'package:artbooking/globals/app_state.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/enums/enum_visibility_tab.dart';
import 'package:artbooking/types/firestore/doc_snap_map.dart';
import 'package:artbooking/types/firestore/document_change_map.dart';
import 'package:artbooking/types/firestore/query_map.dart';
import 'package:artbooking/types/firestore/query_snapshot_stream_subscription.dart';
import 'package:artbooking/types/illustration/illustration.dart';
import 'package:beamer/beamer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flash/src/flash_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
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

  /// Last fetched illustration document.
  DocumentSnapshot? _lastDocument;

  final int _limit = 20;

  final _illustrations = <Illustration>[];
  final List<PopupMenuEntry<EnumIllustrationItemAction>> _popupMenuEntries = [
    PopupMenuItemIcon(
      value: EnumIllustrationItemAction.addToBook,
      icon: Icon(UniconsLine.book_medical),
      textLabel: "add_to_book".tr(),
    ),
    PopupMenuItemIcon(
      value: EnumIllustrationItemAction.delete,
      icon: Icon(UniconsLine.trash),
      textLabel: "delete".tr(),
    ),
  ];

  final _popupFocusNode = FocusNode();

  Map<String, Illustration> _multiSelectedItems = Map();
  ScrollController _scrollController = ScrollController();
  QuerySnapshotStreamSubscription? _illustrationSubscription;

  var _selectedTab = EnumVisibilityTab.active;

  @override
  initState() {
    super.initState();
    loadPreferences();
    fetchIllustrations();
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
        body: NotificationListener<ScrollNotification>(
          onNotification: onScrollNotification,
          child: CustomScrollView(
            controller: _scrollController,
            slivers: <Widget>[
              ApplicationBar(),
              MyIllustrationsPageHeader(
                multiSelectedItems: _multiSelectedItems,
                multiSelectActive: _forceMultiSelect,
                uploadIllustration: uploadIllustration,
                onClearSelection: onClearSelection,
                onSelectAll: onSelectAll,
                onTriggerMultiSelect: onTriggerMultiSelect,
                onConfirmDeleteGroup: confirmDeleteGroup,
                selectedTab: _selectedTab,
                onChangedTab: onChangedTab,
              ),
              MyIllustrationsPageBody(
                forceMultiSelect: _forceMultiSelect,
                illustrations: _illustrations,
                loading: _loading,
                multiSelectedItems: _multiSelectedItems,
                onLongPressIllustration: onLongPressIllustration,
                onTapIllustration: onTapIllustration,
                onPopupMenuItemSelected: onPopupMenuItemSelected,
                popupMenuEntries: _popupMenuEntries,
                uploadIllustration: uploadIllustration,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Show a dialog to confirm multiple illustrations deletion.
  void confirmDeleteGroup() async {
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
                  "illustrations_delete".tr().toUpperCase(),
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
                    "illustrations_delete_description".tr(),
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
          body: SingleChildScrollView(),
          textButtonValidation: "delete".tr(),
          onCancel: Beamer.of(context).popRoute,
          onValidate: () {
            deleteSelection();
            Beamer.of(context).popRoute();
          },
        );
      },
    );
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
                  "illustration_delete".tr().toUpperCase(),
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
                    "illustration_delete_description".tr(),
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
          body: SingleChildScrollView(),
          textButtonValidation: "delete".tr(),
          onCancel: Beamer.of(context).popRoute,
          onValidate: () {
            deleteIllustration(illustration, index);
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

  void deleteSelection() async {
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
          .where("visibility", isNotEqualTo: "archived")
          .limit(_limit);
    }

    return FirebaseFirestore.instance
        .collection("illustrations")
        .where("user_id", isEqualTo: userId)
        .where("visibility", isEqualTo: "archived")
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
          .where("visibility", isNotEqualTo: "archived")
          .limit(_limit)
          .startAfterDocument(lastDocument);
    }

    return FirebaseFirestore.instance
        .collection("illustrations")
        .where("user_id", isEqualTo: userId)
        .where("visibility", isEqualTo: "archived")
        .limit(_limit)
        .startAfterDocument(lastDocument);
  }

  /// Fetch illustrations data from Firestore.
  void fetchIllustrations() async {
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

      for (DocSnapMap document in snapshot.docs) {
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

      for (DocSnapMap document in snapshot.docs) {
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
      setState(() => _loading = false);
    }
  }

  void loadPreferences() {
    _selectedTab = Utilities.storage.getIllustrationsTab();
  }

  /// Listen to tillustrations'events.
  void listenIllustrationsEvents(QueryMap query) {
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
      "dashboard/illustrations/${illustration.id}",
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

    fetchIllustrations();
    Utilities.storage.saveIllustrationsTab(selectedTab);
  }

  void onClearSelection() {
    setState(() {
      _multiSelectedItems.clear();

      _forceMultiSelect = _multiSelectedItems.length > 0;
    });
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
    try {
      final data = documentChange.doc.data();
      if (data == null) {
        return;
      }

      final int index = _illustrations.indexWhere(
        (illustration) => illustration.id == documentChange.doc.id,
      );

      data['id'] = documentChange.doc.id;
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

  void showAddToBook(Illustration illustration) {
    int flex = Utilities.size.isMobileSize(context) ? 5 : 3;

    showCustomModalBottomSheet(
      context: context,
      builder: (context) => AddToBookPanel(
        scrollController: ModalScrollController.of(context),
        illustration: illustration,
      ),
      containerWidget: (context, animation, child) {
        return SafeArea(
          child: Row(
            children: [
              Spacer(),
              Expanded(
                flex: flex,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Material(
                    clipBehavior: Clip.antiAlias,
                    borderRadius: BorderRadius.circular(12.0),
                    child: child,
                  ),
                ),
              ),
              Spacer(),
            ],
          ),
        );
      },
    );
  }

  void uploadIllustration() {
    ref.read(AppState.uploadTaskListProvider.notifier).pickImage();
  }
}
