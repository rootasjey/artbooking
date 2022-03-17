import 'package:artbooking/components/cards/illustration_card.dart';
import 'package:artbooking/components/cards/shimmer_card.dart';
import 'package:artbooking/components/popup_menu/popup_menu_item_icon.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/enums/enum_illustration_item_action.dart';
import 'package:artbooking/types/enums/enum_section_action.dart';
import 'package:artbooking/types/enums/enum_section_data_mode.dart';
import 'package:artbooking/types/enums/enum_select_type.dart';
import 'package:artbooking/types/firestore/doc_snap_map.dart';
import 'package:artbooking/types/illustration/illustration.dart';
import 'package:artbooking/types/section.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flash/src/flash_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

/// A 3x2 illustration grid.
class IllustrationRowSection extends StatefulWidget {
  const IllustrationRowSection({
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
    this.isOwner = false,
  }) : super(key: key);

  final bool isLast;

  /// True if the current authenticated user is the owner.
  final bool isOwner;
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
  State<IllustrationRowSection> createState() => _IllustrationRowSectionState();
}

class _IllustrationRowSectionState extends State<IllustrationRowSection> {
  /// True if fetching data.
  bool _loading = false;

  /// Courcircuit initState.
  /// If first execution, do a whole data fetch.
  /// Otherwise, try a data diff. and udpdate only some UI parts.
  bool _firstExecution = true;

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
              horizontal: 12.0,
              vertical: 24.0,
            ),
            child: Center(
              child: Column(
                children: [
                  titleSectionWidget(),
                  maybeHelperText(),
                  Container(
                    height: 220.0,
                    padding: const EdgeInsets.only(top: 34.0),
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemExtent: 200.0,
                      children: getChildren(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          rightPopupMenuButton(),
        ],
      ),
    );
  }

  List<Widget> getChildren() {
    int index = -1;
    final size = 200.0;

    final bool canDrag = getCanDrag();
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

    final children = _illustrations.map((Illustration illustration) {
      index++;

      final heroTag = "${widget.section.id}-${index}-${illustration.id}";

      return IllustrationCard(
        canDrag: canDrag,
        onDrop: onDrop,
        dragGroupName: "${widget.section.id}-${widget.index}",
        heroTag: heroTag,
        illustration: illustration,
        index: index,
        size: size,
        onTap: () => navigateToIllustrationPage(illustration, heroTag),
        padding: const EdgeInsets.only(right: 24.0),
        popupMenuEntries: popupMenuEntries,
        onPopupMenuItemSelected: onIllustrationItemSelected,
      );
    }).toList();

    if (widget.isOwner && (children.length % 3 != 0 && children.length < 6) ||
        children.isEmpty) {
      children.add(
        IllustrationCard(
          useAsPlaceHolder: true,
          heroTag: "empty_${DateTime.now()}",
          illustration: Illustration.empty(),
          index: index,
          size: size,
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
        style: Utilities.fonts.style(
          fontSize: 16.0,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget rightPopupMenuButton() {
    if (!widget.isOwner) {
      return Container();
    }

    final popupMenuEntries = getPopupMenuEntries();

    return Positioned(
      top: 12.0,
      right: 12.0,
      child: PopupMenuButton(
        child: Card(
          elevation: 2.0,
          color: Theme.of(context).backgroundColor,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(UniconsLine.ellipsis_h),
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
            children: [
              if (title.isNotEmpty)
                Opacity(
                  opacity: 0.6,
                  child: Text(
                    title,
                    style: Utilities.fonts.style(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              if (description.isNotEmpty)
                Opacity(
                  opacity: 0.4,
                  child: Text(
                    description,
                    style: Utilities.fonts.style(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(
          width: 200.0,
          child: Divider(
            color: Theme.of(context).secondaryHeaderColor,
            thickness: 4.0,
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
      // _illustrations.clear();
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
    if (_loading) {
      return;
    }

    if (widget.section.dataFetchMode == EnumSectionDataMode.sync) {
      fetchSyncIllustrations();
      return;
    }

    fetchChosenIllustrations();
  }

  bool getCanDrag() {
    if (!widget.isOwner) {
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
}
