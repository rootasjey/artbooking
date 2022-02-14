import 'package:artbooking/actions/illustrations.dart';
import 'package:artbooking/components/icons/animated_app_icon.dart';
import 'package:artbooking/components/cards/illustration_card.dart';
import 'package:artbooking/components/application_bar/application_bar.dart';
import 'package:artbooking/components/popup_menu/popup_menu_item_icon.dart';
import 'package:artbooking/components/buttons/text_rectangle_button.dart';
import 'package:artbooking/components/dialogs/themed_dialog.dart';
import 'package:artbooking/components/add_to_book_panel.dart';
import 'package:artbooking/components/texts/page_title.dart';
import 'package:artbooking/router/navigation_state_helper.dart';
import 'package:artbooking/types/enums/enum_illustration_item_action.dart';
import 'package:artbooking/globals/app_state.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/firestore/doc_snap_map.dart';
import 'package:artbooking/types/firestore/document_change_map.dart';
import 'package:artbooking/types/firestore/query_map.dart';
import 'package:artbooking/types/firestore/query_snapshot_stream_subscription.dart';
import 'package:artbooking/types/illustration/illustration.dart';
import 'package:beamer/beamer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash/src/flash_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:supercharged/supercharged.dart';
import 'package:unicons/unicons.dart';

class MyIllustrationsPage extends ConsumerStatefulWidget {
  @override
  _MyIllustrationsPageState createState() => _MyIllustrationsPageState();
}

class _MyIllustrationsPageState extends ConsumerState<MyIllustrationsPage> {
  late bool _isLoading;
  bool _descending = true;
  bool _hasNext = true;
  bool _isFabVisible = false;
  bool _isLoadingMore = false;
  bool _forceMultiSelect = false;

  DocumentSnapshot? _lastFirestoreDoc;

  final _illustrationsList = <Illustration>[];

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

  final _focusNode = FocusNode();

  int _limit = 20;

  Map<String, Illustration> _multiSelectedItems = Map();

  ScrollController _scrollController = ScrollController();

  QuerySnapshotStreamSubscription? _streamSubscription;

  @override
  initState() {
    super.initState();
    fetch();
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HeroControllerScope(
      controller: HeroController(),
      child: Scaffold(
        floatingActionButton: fab(),
        body: NotificationListener<ScrollNotification>(
          onNotification: onNotification,
          child: CustomScrollView(
            controller: _scrollController,
            slivers: <Widget>[
              ApplicationBar(),
              header(),
              body(),
            ],
          ),
        ),
      ),
    );
  }

  Widget body() {
    if (_isLoading) {
      return SliverList(
        delegate: SliverChildListDelegate.fixed([
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 100.0),
            child: AnimatedAppIcon(
              textTitle: "illustrations_loading".tr(),
            ),
          ),
        ]),
      );
    }

    if (_illustrationsList.isEmpty) {
      return emptyView();
    }

    return gridView();
  }

  Widget defaultActionsToolbar() {
    if (_multiSelectedItems.isNotEmpty) {
      return Container();
    }

    return Wrap(
      spacing: 12.0,
      runSpacing: 12.0,
      children: [
        multiSelectButton(),
        sortButton(),
      ],
    );
  }

  Widget emptyView() {
    return SliverPadding(
      padding: const EdgeInsets.only(
        top: 40.0,
        left: 50.0,
        bottom: 100.0,
      ),
      sliver: SliverList(
        delegate: SliverChildListDelegate.fixed([
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 12.0,
                ),
                child: Text(
                  "lonely_there".tr(),
                  style: TextStyle(
                    fontSize: 32.0,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 16.0,
                  // top: 24.0,
                ),
                child: Opacity(
                  opacity: 0.4,
                  child: Text(
                    "illustrations_no_upload".tr(),
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  ref
                      .read(AppState.uploadTaskListProvider.notifier)
                      .pickImage();
                },
                icon: Icon(UniconsLine.upload),
                label: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    "upload".tr(),
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ]),
      ),
    );
  }

  Widget fab() {
    if (!_isFabVisible) {
      return FloatingActionButton(
        onPressed: () {
          ref.read(AppState.uploadTaskListProvider.notifier).pickImage();
        },
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        child: Icon(UniconsLine.upload),
      );
    }

    return FloatingActionButton(
      onPressed: () {
        _scrollController.animateTo(
          0.0,
          duration: 1.seconds,
          curve: Curves.easeOut,
        );
      },
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      child: Icon(UniconsLine.arrow_up),
    );
  }

  Widget gridView() {
    final selectionMode = _forceMultiSelect || _multiSelectedItems.isNotEmpty;

    return SliverPadding(
      padding: const EdgeInsets.only(
        top: 40.0,
        left: 40.0,
        right: 40.0,
        bottom: 100.0,
      ),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 300.0,
          mainAxisSpacing: 20.0,
          crossAxisSpacing: 20.0,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final illustration = _illustrationsList.elementAt(index);
            final selected = _multiSelectedItems.containsKey(illustration.id);

            return IllustrationCard(
              index: index,
              heroTag: illustration.id,
              illustration: illustration,
              selected: selected,
              selectionMode: selectionMode,
              onTap: () => onTapIllustrationCard(illustration),
              onPopupMenuItemSelected: onPopupMenuItemSelected,
              popupMenuEntries: _popupMenuEntries,
              onLongPress: (key, illustration, selected) {
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
              },
            );
          },
          childCount: _illustrationsList.length,
        ),
      ),
    );
  }

  Widget header() {
    return SliverPadding(
      padding: const EdgeInsets.only(
        top: 60.0,
        left: 50.0,
        bottom: 24.0,
      ),
      sliver: SliverList(
        delegate: SliverChildListDelegate.fixed([
          PageTitle(
            renderSliver: false,
            titleValue: "illustrations".tr(),
            subtitleValue: "illustrations_subtitle".tr(),
            padding: const EdgeInsets.only(bottom: 16.0),
          ),
          defaultActionsToolbar(),
          multiSelectToolbar(),
        ]),
      ),
    );
  }

  Widget multiSelectAll() {
    return TextRectangleButton(
      icon: Icon(UniconsLine.layers),
      label: Text("select_all".tr()),
      primary: Colors.black38,
      onPressed: () {
        _illustrationsList.forEach((illustration) {
          _multiSelectedItems.putIfAbsent(illustration.id, () => illustration);
        });

        setState(() {});
      },
    );
  }

  Widget multiSelectButton() {
    return TextRectangleButton(
      onPressed: () {
        setState(() {
          _forceMultiSelect = !_forceMultiSelect;
        });
      },
      icon: Icon(UniconsLine.layers),
      label: Text('multi_select'.tr()),
      primary: _forceMultiSelect ? Colors.lightGreen : Colors.black38,
    );
  }

  Widget multiSelectClear() {
    return TextRectangleButton(
      icon: Icon(UniconsLine.ban),
      label: Text("clear_selection".tr()),
      primary: Colors.black38,
      onPressed: () {
        setState(() {
          _multiSelectedItems.clear();

          _forceMultiSelect = _multiSelectedItems.length > 0;
        });
      },
    );
  }

  Widget multiSelectCount() {
    return Opacity(
      opacity: 0.6,
      child: Text(
        "multi_items_selected".tr(
          args: [_multiSelectedItems.length.toString()],
        ),
        style: TextStyle(
          fontSize: 30.0,
        ),
      ),
    );
  }

  Widget multiSelectDelete() {
    return TextRectangleButton(
      icon: Icon(UniconsLine.trash),
      label: Text("delete".tr()),
      primary: Colors.black38,
      onPressed: confirmDeleteManyIllustrations,
    );
  }

  Widget multiSelectToolbar() {
    if (_multiSelectedItems.isEmpty) {
      return Container();
    }

    return Wrap(
      spacing: 12.0,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        multiSelectCount(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Container(
            height: 25.0,
            width: 2.0,
            color: Colors.black12,
          ),
        ),
        multiSelectClear(),
        multiSelectAll(),
        multiSelectDelete(),
      ],
    );
  }

  Widget sortButton() {
    return TextRectangleButton(
      onPressed: () {},
      icon: Icon(UniconsLine.sort),
      label: Text("sort".tr()),
      primary: Colors.black38,
    );
  }

  /// Fire when a new document has been created in Firestore.
  /// Add the corresponding document in the UI.
  void addStreamingDoc(DocumentChangeMap documentChange) {
    final data = documentChange.doc.data();

    if (data == null) {
      return;
    }

    setState(() {
      data['id'] = documentChange.doc.id;
      final illustration = Illustration.fromMap(data);
      _illustrationsList.insert(0, illustration);
    });
  }

  /// Show a dialog to confirm multiple illustrations deletion.
  void confirmDeleteManyIllustrations() async {
    showDialog(
      context: context,
      builder: (context) {
        return ThemedDialog(
          focusNode: _focusNode,
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
  void confirmDeleteOneIllustration(
    Illustration illustration,
    int index,
  ) async {
    showDialog(
      context: context,
      builder: (context) {
        return ThemedDialog(
          focusNode: _focusNode,
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

  void deleteSelection() async {
    _multiSelectedItems.entries.forEach((multiSelectItem) {
      _illustrationsList.removeWhere((item) => item.id == multiSelectItem.key);
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

      _illustrationsList.addAll(duplicatedItems);
    }
  }

  /// Fetch illustrations data from Firestore.
  void fetch() async {
    setState(() {
      _isLoading = true;
      _illustrationsList.clear();
    });

    try {
      final User? userAuth = FirebaseAuth.instance.currentUser;

      if (userAuth == null) {
        throw Exception("User is not authenticated.");
      }

      final QueryMap query = FirebaseFirestore.instance
          .collection('illustrations')
          .where('user_id', isEqualTo: userAuth.uid)
          .orderBy('created_at', descending: _descending)
          .limit(_limit);

      startListenningToData(query);
      final snapshot = await query.get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          _isLoading = false;
          _hasNext = false;
        });

        return;
      }

      for (DocSnapMap document in snapshot.docs) {
        final data = document.data();
        data['id'] = document.id;

        _illustrationsList.add(Illustration.fromMap(data));
      }

      setState(() {
        _lastFirestoreDoc = snapshot.docs.last;
        _hasNext = snapshot.docs.length == _limit;
      });
    } catch (error) {
      Utilities.logger.e(error);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Fetch more illustrations data from Firestore.
  void fetchMore() async {
    if (!_hasNext || _lastFirestoreDoc == null) {
      return;
    }

    _isLoadingMore = true;

    try {
      final User? userAuth = FirebaseAuth.instance.currentUser;

      if (userAuth == null) {
        throw Exception("User is not authenticated.");
      }

      final QueryMap query = await FirebaseFirestore.instance
          .collection('illustrations')
          .where('user_id', isEqualTo: userAuth.uid)
          .orderBy('created_at', descending: _descending)
          .limit(_limit)
          .startAfterDocument(_lastFirestoreDoc!);

      startListenningToData(query);
      final snapshot = await query.get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          _hasNext = false;
          _isLoadingMore = false;
        });

        return;
      }

      for (DocSnapMap document in snapshot.docs) {
        final data = document.data();
        data['id'] = document.id;

        _illustrationsList.add(Illustration.fromMap(data));
      }

      setState(() {
        _lastFirestoreDoc = snapshot.docs.last;
        _hasNext = snapshot.docs.length == _limit;
        _isLoadingMore = false;
      });
    } catch (error) {
      Utilities.logger.e(error);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  bool onNotification(ScrollNotification notification) {
    // FAB visibility
    if (notification.metrics.pixels < 50 && _isFabVisible) {
      setState(() {
        _isFabVisible = false;
      });
    } else if (notification.metrics.pixels > 50 && !_isFabVisible) {
      setState(() {
        _isFabVisible = true;
      });
    }

    if (notification.metrics.pixels < notification.metrics.maxScrollExtent) {
      return false;
    }

    if (_hasNext && !_isLoadingMore) {
      fetchMore();
    }

    return false;
  }

  void onTapIllustrationCard(Illustration illustration) {
    if (_multiSelectedItems.isEmpty && !_forceMultiSelect) {
      navigateToIllustrationPage(illustration);
      return;
    }

    multiSelectIllustration(illustration);
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

  void onPopupMenuItemSelected(
    EnumIllustrationItemAction action,
    int index,
    Illustration illustration,
    String illustrationKey,
  ) {
    switch (action) {
      case EnumIllustrationItemAction.delete:
        confirmDeleteOneIllustration(illustration, index);
        break;
      case EnumIllustrationItemAction.addToBook:
        showAddToBook(illustration);
        break;
      default:
        break;
    }
  }

  void deleteIllustration(Illustration illustration, int index) async {
    setState(() {
      _illustrationsList.removeAt(index);
    });

    final response = await IllustrationsActions.deleteOne(
      illustrationId: illustration.id,
    );

    if (response.success) {
      return;
    }

    setState(() {
      _illustrationsList.insert(index, illustration);
    });
  }

  /// Fire when a new document has been delete from Firestore.
  /// Delete the corresponding document from the UI.
  void removeStreamingDoc(DocumentChangeMap documentChange) {
    setState(() {
      _illustrationsList.removeWhere(
        (illustration) => illustration.id == documentChange.doc.id,
      );
    });
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

  /// Listen to the last Firestore query of this page.
  void startListenningToData(QueryMap query) {
    _streamSubscription = query.snapshots().skip(1).listen(
      (snapshot) {
        for (DocumentChangeMap documentChange in snapshot.docChanges) {
          switch (documentChange.type) {
            case DocumentChangeType.added:
              addStreamingDoc(documentChange);
              break;
            case DocumentChangeType.modified:
              updateStreamingDoc(documentChange);
              break;
            case DocumentChangeType.removed:
              removeStreamingDoc(documentChange);
              break;
          }
        }
      },
      onError: (error) {
        Utilities.logger.e(error);
      },
    );
  }

  /// Fire when a new document has been updated in Firestore.
  /// Update the corresponding document in the UI.
  void updateStreamingDoc(DocumentChangeMap documentChange) {
    try {
      final data = documentChange.doc.data();
      if (data == null) {
        return;
      }

      final int index = _illustrationsList.indexWhere(
        (illustration) => illustration.id == documentChange.doc.id,
      );

      data['id'] = documentChange.doc.id;
      final updatedIllustration = Illustration.fromMap(data);

      setState(() {
        _illustrationsList.removeAt(index);
        _illustrationsList.insert(index, updatedIllustration);
      });
    } on Exception catch (error) {
      Utilities.logger.e(
        "The document with the id ${documentChange.doc.id} "
        "doesn't exist in the illustrations list.",
      );

      Utilities.logger.e(error);
    }
  }
}
