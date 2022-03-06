import 'package:artbooking/components/cards/illustration_card.dart';
import 'package:artbooking/components/loading_view.dart';
import 'package:artbooking/components/popup_menu/popup_menu_item_icon.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/router/locations/atelier_location.dart';
import 'package:artbooking/router/navigation_state_helper.dart';
import 'package:artbooking/types/enums/enum_illustration_item_action.dart';
import 'package:artbooking/types/enums/enum_section_action.dart';
import 'package:artbooking/types/enums/enum_section_data_mode.dart';
import 'package:artbooking/types/enums/enum_select_type.dart';
import 'package:artbooking/types/firestore/doc_snap_map.dart';
import 'package:artbooking/types/illustration/illustration.dart';
import 'package:artbooking/types/section.dart';
import 'package:beamer/beamer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flash/src/flash_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

/// A 3x2 illustration grid.
class IllustrationGridSection extends StatefulWidget {
  const IllustrationGridSection({
    Key? key,
    required this.userId,
    this.onPopupMenuItemSelected,
    this.popupMenuEntries = const [],
    required this.index,
    required this.section,
    this.isLast = false,
    this.onShowIllustrationDialog,
    this.onUpdateSectionItems,
  }) : super(key: key);

  final bool isLast;
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
  final String userId;

  @override
  State<IllustrationGridSection> createState() =>
      _IllustrationGridSectionState();
}

class _IllustrationGridSectionState extends State<IllustrationGridSection> {
  bool _loading = false;
  bool _firstExecution = true;

  List<Illustration> _illustrations = [];
  var _currentMode = EnumSectionDataMode.sync;

  @override
  initState() {
    super.initState();
    _currentMode = widget.section.dataMode;
  }

  @override
  void dispose() {
    _illustrations.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    handleFetch();

    if (_loading) {
      return LoadingView(title: Text("loading".tr()));
    }

    final popupMenuEntries = filterPopupMenuEntries();

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 90.9,
          vertical: 24.0,
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                children: [
                  Opacity(
                    opacity: 0.6,
                    child: Text(
                      widget.section.name,
                      style: Utilities.fonts.style(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 200.0,
                    child: Divider(
                      color: Theme.of(context).secondaryHeaderColor,
                      thickness: 4.0,
                    ),
                  ),
                  maybeHelperText(),
                  Padding(
                    padding: const EdgeInsets.only(top: 34.0),
                    child: GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      mainAxisSpacing: 24.0,
                      crossAxisSpacing: 24.0,
                      children: getChildren(),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 0.0,
              child: PopupMenuButton(
                icon: Opacity(
                  opacity: 0.8,
                  child: Icon(
                    UniconsLine.ellipsis_h,
                  ),
                ),
                itemBuilder: (_) => popupMenuEntries,
                onSelected: (EnumSectionAction action) {
                  widget.onPopupMenuItemSelected?.call(
                    action,
                    widget.index,
                    widget.section,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> getChildren() {
    int index = -1;
    final bool canDrag = _currentMode == EnumSectionDataMode.chosen;
    final onDrop = canDrag ? onDropIllustration : null;
    final List<PopupMenuEntry<EnumIllustrationItemAction>> popupMenuEntries =
        canDrag
            ? [
                PopupMenuItemIcon(
                  icon: Icon(UniconsLine.minus),
                  textLabel: "remove".tr(),
                  value: EnumIllustrationItemAction.remove,
                ),
              ]
            : [];

    final children = _illustrations.map((illustration) {
      index++;

      return IllustrationCard(
        canDrag: canDrag,
        onDrop: onDrop,
        heroTag: "${widget.section.id}-${index}-${illustration.id}",
        illustration: illustration,
        index: index,
        onTap: () => navigateToIllustrationPage(illustration),
        popupMenuEntries: popupMenuEntries,
        onPopupMenuItemSelected: onIllustrationItemSelected,
      );
    }).toList();

    if (children.length % 3 != 0 && children.length < 6) {
      children.add(
        IllustrationCard(
          asPlaceHolder: true,
          heroTag: "empty_${DateTime.now()}",
          illustration: Illustration.empty(),
          index: index,
          onTap: () => widget.onShowIllustrationDialog?.call(
            section: widget.section,
            index: widget.index,
            selectType: EnumSelectType.add,
          ),
        ),
      );
    }

    return children;
  }

  Widget maybeHelperText() {
    if (widget.section.dataMode != EnumSectionDataMode.chosen ||
        _illustrations.isNotEmpty) {
      return Container();
    }

    return Container(
      width: 500.0,
      padding: const EdgeInsets.all(24.0),
      child: Text.rich(
        TextSpan(
          text: "illustrations_pick_description".tr(),
          children: [
            TextSpan(
              text: ' ${"illustrations_sync_description".tr()} ',
              recognizer: TapGestureRecognizer()..onTap = setSyncDataMode,
              style: TextStyle(
                backgroundColor: Colors.amber.shade100,
              ),
            ),
          ],
        ),
        style: Utilities.fonts.style(
          fontSize: 16.0,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Update UI without reloading the whole component.
  void diffIllustration() async {
    final illustrationIds = _illustrations.map((x) => x.id).toList();
    var initialIllustrations = widget.section.items;
    if (listEquals(illustrationIds, initialIllustrations)) {
      return;
    }

    // Ignore illustrations which are still in the list.
    final illustrationsToFetch = initialIllustrations.sublist(0)
      ..removeWhere((x) => illustrationIds.contains(x));

    // Remove illustrations which are not in the list anymore.
    _illustrations.removeWhere((x) => !initialIllustrations.contains(x.id));

    if (illustrationsToFetch.isEmpty) {
      return;
    }

    // Fetch new illustrations.
    final List<Future<Illustration>> futures = [];
    for (final id in illustrationsToFetch) {
      futures.add(fetchIllustration(id));
    }

    final futuresResult = await Future.wait(futures);
    setState(() {
      _illustrations.addAll(futuresResult);
    });
  }

  /// Fetch only chosen illustrations.
  /// When this section's data fetch mode is equals to 'chosen'.
  void fetchChosenIllustration() async {
    setState(() {
      _loading = true;
      _illustrations.clear();
    });

    final List<Future<Illustration>> futures = [];
    for (final id in widget.section.items) {
      futures.add(fetchIllustration(id));
    }

    final futuresResult = await Future.wait(futures);
    setState(() {
      _illustrations.addAll(futuresResult);
      _loading = false;
    });
  }

  Future<Illustration> fetchIllustration(String id) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("illustrations")
          .doc(id)
          .get();

      final data = snapshot.data();
      if (!snapshot.exists || data == null) {
        return Illustration.empty();
      }

      data["id"] = snapshot.id;
      return Illustration.fromMap(data);
    } catch (error) {
      Utilities.logger.e(error);
      return Illustration.empty();
    }
  }

  /// Fetch user's public last illustrations.
  /// When this section's data fetch mode is equals to 'sync'.
  void fetchSyncIllustrations() async {
    setState(() {
      _loading = true;
      _illustrations.clear();
    });

    try {
      final illustrationsSnapshot = await FirebaseFirestore.instance
          .collection("illustrations")
          .where("user_id", isEqualTo: widget.userId)
          .orderBy("user_custom_index", descending: true)
          .where("visibility", isEqualTo: "public")
          .limit(6)
          .get();

      if (illustrationsSnapshot.docs.isEmpty) {
        return;
      }

      for (DocSnapMap document in illustrationsSnapshot.docs) {
        final data = document.data();
        data["id"] = document.id;
        _illustrations.add(Illustration.fromMap(data));
      }
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void fetchIllustrations() {
    if (widget.section.dataMode == EnumSectionDataMode.sync) {
      fetchSyncIllustrations();
      return;
    }

    fetchChosenIllustration();
  }

  void handleFetch() {
    if (_firstExecution) {
      _firstExecution = false;
      fetchIllustrations();
      return;
    }

    if (_currentMode != widget.section.dataMode) {
      _currentMode = widget.section.dataMode;
      _currentMode == EnumSectionDataMode.sync ? fetchIllustrations() : null;
    }

    if (_currentMode == EnumSectionDataMode.chosen) {
      diffIllustration();
    }
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

  void onDropIllustration(int dropTargetIndex, List<int> dragIndexes) {
    final int firstDragIndex = dragIndexes.first;
    if (dropTargetIndex == firstDragIndex) {
      return;
    }

    if (dropTargetIndex < 0 ||
        firstDragIndex < 0 ||
        dropTargetIndex >= _illustrations.length ||
        firstDragIndex > _illustrations.length) {
      return;
    }

    final dropTargetIllustration = _illustrations.elementAt(dropTargetIndex);
    final dragIllustration = _illustrations.elementAt(firstDragIndex);

    setState(() {
      _illustrations[firstDragIndex] = dropTargetIllustration;
      _illustrations[dropTargetIndex] = dragIllustration;
    });

    final List<String> items = _illustrations.map((x) => x.id).toList();
    widget.onUpdateSectionItems?.call(widget.section, widget.index, items);
  }

  void onIllustrationItemSelected(
    EnumIllustrationItemAction action,
    int index,
    Illustration illustration,
    String key,
  ) {
    switch (action) {
      case EnumIllustrationItemAction.remove:
        setState(() {
          _illustrations.removeWhere((x) => x.id == illustration.id);
        });

        List<String> items = widget.section.items;
        items.removeWhere((x) => x == illustration.id);
        widget.onUpdateSectionItems?.call(widget.section, widget.index, items);

        break;
      default:
    }
  }

  void setSyncDataMode() {
    widget.onPopupMenuItemSelected?.call(
      EnumSectionAction.setSyncDataMode,
      widget.index,
      widget.section,
    );
  }

  List<PopupMenuItemIcon<EnumSectionAction>> filterPopupMenuEntries() {
    var popupMenuEntries = widget.popupMenuEntries.sublist(0);

    if (widget.index == 0) {
      popupMenuEntries = popupMenuEntries.toList();
      popupMenuEntries.removeWhere((x) => x.value == EnumSectionAction.moveUp);
    }

    if (widget.isLast) {
      popupMenuEntries = popupMenuEntries.toList();
      popupMenuEntries
          .removeWhere((x) => x.value == EnumSectionAction.moveDown);
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
}