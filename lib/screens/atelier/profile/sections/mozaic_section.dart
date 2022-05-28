import 'dart:math';

import 'package:artbooking/components/cards/illustration_card.dart';
import 'package:artbooking/components/cards/shimmer_card.dart';
import 'package:artbooking/components/popup_menu/popup_menu_item_icon.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/screens/atelier/profile/popup_menu_button_section.dart';
import 'package:artbooking/types/book/scale_factor.dart';
import 'package:artbooking/types/enums/enum_illustration_item_action.dart';
import 'package:artbooking/types/enums/enum_section_action.dart';
import 'package:artbooking/types/enums/enum_section_data_mode.dart';
import 'package:artbooking/types/enums/enum_select_type.dart';
import 'package:artbooking/types/firestore/query_doc_snap_map.dart';
import 'package:artbooking/types/illustration/illustration.dart';
import 'package:artbooking/types/illustration/sized_illustration.dart';
import 'package:artbooking/types/section.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flash/src/flash_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:unicons/unicons.dart';

/// A grid of illustrations with variable sized items..
class MozaicSection extends StatefulWidget {
  const MozaicSection({
    Key? key,
    required this.index,
    required this.section,
    required this.userId,
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
  final String userId;

  @override
  State<MozaicSection> createState() => _MozaicSectionState();
}

class _MozaicSectionState extends State<MozaicSection> {
  /// True if fetching data.
  bool _loading = false;

  /// Courcircuit initState.
  /// If first execution, do a whole data fetch.
  /// Otherwise, try a data diff. and udpdate only some UI parts.
  bool _firstExecution = true;

  /// Minimum amount of value to start an illustration resize.
  final double _resizeTreshold = 20.0;

  List<Illustration> _illustrations = [];

  /// Used to know to flush current data and refetch.
  /// Otherwise, simply do a data diff. and update only some UI parts.
  var _currentMode = EnumSectionDataMode.sync;

  @override
  initState() {
    super.initState();
    _currentMode = widget.section.dataFetchMode;
  }

  @override
  void dispose() {
    _illustrations.clear();
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
            padding: const EdgeInsets.symmetric(
              horizontal: 48.0,
              vertical: 32.0,
            ),
            child: Column(
              children: [
                titleSectionWidget(),
                maybeHelperText(),
                Padding(
                  padding: const EdgeInsets.only(top: 34.0),
                  child: mozaicBody(),
                ),
              ],
            ),
          ),
          rightPopupMenuButton(),
        ],
      ),
    );
  }

  Widget mozaicBody() {
    return StaggeredGrid.count(
      crossAxisCount: 6,
      mainAxisSpacing: 24.0,
      crossAxisSpacing: 24.0,
      children: getChildren(),
    );
  }

  Widget wrapInResponsiveCard({required Widget child}) {
    return Flexible(
      flex: 5,
      child: FractionallySizedBox(
        widthFactor: 0.6,
        child: AspectRatio(
          aspectRatio: 1.0,
          child: child,
        ),
      ),
    );
  }

  List<Widget> getChildren() {
    int index = 0;
    final double size = 200.0;

    final bool canDrag = getCanDragAndResize();
    final bool canResize = canDrag;
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

    List<Widget> children = [];

    for (final Illustration illustration in _illustrations) {
      final ScaleFactor scaleFactor =
          widget.section.complexItems[index].scaleFactor;

      final heroTag = "${widget.section.id}-${index}-${illustration.id}";

      children.add(StaggeredGridTile.count(
        crossAxisCellCount: scaleFactor.width,
        mainAxisCellCount: scaleFactor.height,
        child: IllustrationCard(
          canResize: canResize,
          canDrag: canDrag,
          onDrop: onDrop,
          onResizeEnd: onResizeEnd,
          onGrowUp: onGrowUp,
          dragGroupName: "${widget.section.id}-${widget.index}",
          heroTag: heroTag,
          illustration: illustration,
          index: index,
          size: size,
          onTap: () => navigateToIllustrationPage(illustration, heroTag),
          popupMenuEntries: popupMenuEntries,
          onPopupMenuItemSelected: onIllustrationItemSelected,
        ),
      ));

      index++;
    }

    children = addMaybePlaceholder(children, size);
    return children;
  }

  List<Widget> addMaybePlaceholder(
    List<Widget> children,
    double size,
  ) {
    if (!widget.editMode) {
      return children;
    }

    children.add(
      StaggeredGridTile.count(
        crossAxisCellCount: 1,
        mainAxisCellCount: 1,
        child: IllustrationCard(
          useAsPlaceholder: true,
          useIconPlaceholder: true,
          heroTag: "empty_${DateTime.now()}",
          illustration: Illustration.empty(),
          index: -1,
          size: size + 28.0,
          onTap: () => widget.onShowIllustrationDialog?.call(
            section: widget.section,
            index: widget.index,
            selectType: EnumSelectType.add,
          ),
        ),
      ),
    );

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

  Widget maybeHelperText() {
    if (widget.section.dataFetchMode != EnumSectionDataMode.chosen ||
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
        style: Utilities.fonts.body(
          fontSize: 16.0,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget rightPopupMenuButton() {
    if (!widget.isHover) {
      return Container();
    }

    if (!widget.editMode) {
      return Container();
    }

    return PopupMenuButtonSection(
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

    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 12.0),
        child: InkWell(
          onTap: onTapTitleDescription,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title.isNotEmpty)
                Opacity(
                  opacity: 0.8,
                  child: Text(
                    title,
                    style: Utilities.fonts.title(
                      fontSize: 32.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              if (description.isNotEmpty)
                Opacity(
                  opacity: 0.6,
                  child: Text(
                    description,
                    style: Utilities.fonts.body(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// (BAD) Check for changes and fetch new data a change is detected.
  /// WARNING: This is anti-pattern to `setState()` inside of a `build()` method.
  void checkData() {
    if (_firstExecution) {
      _firstExecution = false;
      fetchIllustrations();
      return;
    }

    if (_currentMode != widget.section.dataFetchMode) {
      _currentMode = widget.section.dataFetchMode;
      _currentMode == EnumSectionDataMode.sync ? fetchIllustrations() : null;
    }

    if (_currentMode == EnumSectionDataMode.chosen) {
      diffIllustration();
    }
  }

  /// Update UI without re-loading the whole component.
  void diffIllustration() async {
    if (_loading) {
      return;
    }

    _loading = true;

    final illustrationIds = _illustrations.map((x) => x.id).toList();
    var initialIllustrations = widget.section.items;
    if (listEquals(illustrationIds, initialIllustrations)) {
      _loading = false;
      return;
    }

    // Ignore illustrations which are still in the list.
    final illustrationsToFetch = initialIllustrations.sublist(0)
      ..removeWhere((x) => illustrationIds.contains(x));

    // Remove illustrations which are not in the list anymore.
    _illustrations.removeWhere((x) => !initialIllustrations.contains(x.id));

    if (illustrationsToFetch.isEmpty) {
      _loading = false;
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
      _loading = false;
    });
  }

  /// Fetch only chosen illustrations.
  /// When this section's data fetch mode is equals to 'chosen'.
  void fetchChosenIllustrations() async {
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
        return Illustration.empty(
          id: id,
          userId: widget.userId,
        );
      }

      data["id"] = snapshot.id;
      return Illustration.fromMap(data);
    } catch (error) {
      Utilities.logger.e(error);
      return Illustration.empty(
        id: id,
        userId: widget.userId,
      );
    }
  }

  /// Fetch last user's public illustrations
  /// when this section's data fetch mode is equals to 'sync'.
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
          .limit(5)
          .get();

      if (illustrationsSnapshot.docs.isEmpty) {
        return;
      }

      for (QueryDocSnapMap document in illustrationsSnapshot.docs) {
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
    if (_loading) {
      return;
    }

    if (widget.section.dataFetchMode == EnumSectionDataMode.sync) {
      fetchSyncIllustrations();
      return;
    }

    fetchChosenIllustrations();
  }

  bool getCanDragAndResize() {
    if (!widget.editMode) {
      return false;
    }

    return _currentMode == EnumSectionDataMode.chosen;
  }

  void navigateToIllustrationPage(Illustration illustration, String heroTag) {
    Utilities.navigation.profileToIllustration(
      context,
      illustration: illustration,
      heroTag: heroTag,
      userId: widget.userId,
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

  void onResizeEnd(
    Size endSize,
    Size originalSize,
    DragEndDetails details,
    int index,
  ) {
    final int widthFactor = originalSize.width ~/ endSize.width;
    final int heightFactor = originalSize.height ~/ endSize.height;

    final SizedIllustration sizedIllustration =
        widget.section.complexItems.elementAt(index);
    final ScaleFactor scaleFactor = sizedIllustration.scaleFactor;

    int newWidthScaleFactor = scaleFactor.width;
    int newHeightScaleFactor = scaleFactor.height;

    if ((originalSize.width - endSize.width) > _resizeTreshold) {
      newWidthScaleFactor = scaleFactor.width ~/ widthFactor;
      newWidthScaleFactor = newWidthScaleFactor == scaleFactor.width
          ? (newWidthScaleFactor - 1)
          : newWidthScaleFactor;

      newWidthScaleFactor = max(1, newWidthScaleFactor);
    }

    if ((originalSize.height - endSize.height) > _resizeTreshold) {
      newHeightScaleFactor = scaleFactor.height ~/ heightFactor;
      newHeightScaleFactor = newHeightScaleFactor == scaleFactor.height
          ? (newHeightScaleFactor - 1)
          : newHeightScaleFactor;

      newHeightScaleFactor = max(1, newHeightScaleFactor);
    }

    final newSizedIllustration = sizedIllustration.copyWith(
      scaleFactor: ScaleFactor(
        width: newWidthScaleFactor,
        height: newHeightScaleFactor,
      ),
    );

    setState(() {
      widget.section.complexItems[index] = newSizedIllustration;
    });

    widget.onUpdateSectionItems?.call(
      widget.section,
      widget.index,
      widget.section.items,
    );
  }

  void onGrowUp(int index) {
    final SizedIllustration sizedIllustration =
        widget.section.complexItems.elementAt(index);

    final ScaleFactor currentScaleFactor = sizedIllustration.scaleFactor;
    final int newWidth = min(currentScaleFactor.width + 1, 4);
    final int newHeight = min(currentScaleFactor.height + 1, 4);

    final newSizedIllustration = sizedIllustration.copyWith(
      scaleFactor: ScaleFactor(
        width: newWidth,
        height: newHeight,
      ),
    );

    setState(() {
      widget.section.complexItems[index] = newSizedIllustration;
    });

    widget.onUpdateSectionItems?.call(
      widget.section,
      widget.index,
      widget.section.items,
    );
  }
}
