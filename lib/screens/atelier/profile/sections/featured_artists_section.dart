import 'package:artbooking/components/avatar/better_avatar.dart';
import 'package:artbooking/components/cards/shimmer_card.dart';
import 'package:artbooking/components/popup_menu/popup_menu_icon.dart';
import 'package:artbooking/components/popup_menu/popup_menu_item_icon.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/router/locations/home_location.dart';
import 'package:artbooking/screens/atelier/profile/popup_menu_button_section.dart';
import 'package:artbooking/types/enums/enum_artist_item_action.dart';
import 'package:artbooking/types/enums/enum_illustration_item_action.dart';
import 'package:artbooking/types/enums/enum_section_action.dart';
import 'package:artbooking/types/enums/enum_section_data_mode.dart';
import 'package:artbooking/types/enums/enum_select_type.dart';
import 'package:artbooking/types/illustration/illustration.dart';
import 'package:artbooking/types/popup_item_section.dart';
import 'package:artbooking/types/section.dart';
import 'package:artbooking/types/user/user_firestore.dart';
import 'package:avatar_stack/avatar_stack.dart';
import 'package:avatar_stack/positions.dart';
import 'package:beamer/beamer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

/// A 3x2 illustration grid.
class FeaturedArtistsSection extends StatefulWidget {
  const FeaturedArtistsSection({
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
  State<FeaturedArtistsSection> createState() => _FeaturedArtistsSectionState();
}

class _FeaturedArtistsSectionState extends State<FeaturedArtistsSection> {
  /// True if fetching data.
  bool _loading = false;

  /// Courcircuit initState.
  /// If first execution, do a whole data fetch.
  /// Otherwise, try a data diff. and udpdate only some UI parts.
  bool _firstExecution = true;

  List<UserFirestore> _users = [];

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
    _users.clear();
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

    final bool isMobileSize = Utilities.size.isMobileSize(context);

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
                  titleWidget(isMobileSize),
                  maybeHelperText(),
                  SizedBox(
                    height: 200.0,
                    child: WidgetStack(
                      buildInfoWidget: (int additionalItems) {
                        return CircleAvatar(
                          child: Text("+$additionalItems"),
                        );
                      },
                      positions: RestrictedPositions(
                        maxCoverage: 0.7,
                        minCoverage: 0.6,
                        align: StackAlign.center,
                      ),
                      stackedWidgets: getChildren(),
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
    final size = 100.0;

    final bool canDrag = getCanDrag();
    final onDrop = canDrag ? onDropAvatar : null;
    final List<PopupMenuEntry<EnumArtistItemAction>> popupMenuEntries = canDrag
        ? [
            PopupMenuItemIcon(
              icon: PopupMenuIcon(UniconsLine.minus),
              textLabel: "remove".tr(),
              value: EnumArtistItemAction.remove,
            ),
          ]
        : [];

    final List<Widget> children = [];

    for (final UserFirestore artist in _users) {
      children.add(BetterAvatar(
        index: index,
        showTitleOnHover: true,
        canDrag: canDrag,
        onDrop: onDrop,
        size: size,
        id: artist.id,
        dragGroupName: "${widget.section.id}-${widget.index}",
        popupMenuEntries: popupMenuEntries,
        onPopupMenuItemSelected: onArtistItemSelected,
        title: artist.name,
        image: NetworkImage(
          artist.getProfilePicture(),
        ),
        onTap: () => goToArtistPage(artist),
      ));
    }

    if (widget.editMode && (children.length < 6 || children.isEmpty)) {
      children.add(
        Align(
          alignment: Alignment.topCenter,
          child: BetterAvatar(
            size: 100.0,
            image: AssetImage(""),
            useAsPlaceholder: true,
            onTap: () => widget.onPopupMenuItemSelected?.call(
              EnumSectionAction.selectArtists,
              widget.index,
              widget.section,
            ),
          ),
        ),
      );
    }

    return children;
  }

  void onArtistItemSelected(
    EnumArtistItemAction action,
    int index,
    String artistId,
  ) {
    switch (action) {
      case EnumArtistItemAction.remove:
        setState(() {
          _users.removeWhere((x) => x.id == artistId);
        });

        List<String> items = widget.section.items;
        items.removeWhere((x) => x == artistId);
        widget.onUpdateSectionItems?.call(widget.section, widget.index, items);

        break;
      default:
    }
  }

  List<PopupMenuItemSection> getPopupMenuEntries() {
    final List<PopupMenuItemSection> popupMenuEntries =
        widget.popupMenuEntries.sublist(0);

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
          icon: PopupMenuIcon(UniconsLine.plus),
          textLabel: "artists_select".tr(),
          value: EnumSectionAction.selectArtists,
          delay: Duration(milliseconds: popupMenuEntries.length * 25),
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
        _users.isNotEmpty) {
      return Container();
    }

    return Container(
      width: 500.0,
      padding: const EdgeInsets.all(24.0),
      child: Text(
        "artists_pick_description".tr(),
        style: Utilities.fonts.body(
          fontSize: 16.0,
          fontWeight: FontWeight.w600,
        ),
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

  Widget titleWidget(bool isMobileSize) {
    final String title = widget.section.name;
    final String description = widget.section.description;

    if (title.isEmpty && description.isEmpty) {
      return Container();
    }

    return Container(
      padding: const EdgeInsets.only(bottom: 36.0),
      child: InkWell(
        onTap: widget.editMode ? onTapTitleDescription : null,
        child: Column(
          children: [
            if (title.isNotEmpty)
              Opacity(
                opacity: 0.8,
                child: Text(
                  title,
                  style: Utilities.fonts.title2(
                    fontSize: isMobileSize ? 36.0 : 62.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            if (description.isNotEmpty)
              Opacity(
                opacity: 0.4,
                child: Text(
                  description,
                  style: Utilities.fonts.body3(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// (BAD) Check for changes and fetch new data a change is detected.
  /// WARNING: This is anti-pattern to `setState()` inside of a `build()` method.
  void checkData() {
    if (_firstExecution) {
      _firstExecution = false;
      fetchAvatars();
      return;
    }

    if (_currentMode != widget.section.dataFetchMode) {
      _currentMode = widget.section.dataFetchMode;
      _currentMode == EnumSectionDataMode.sync ? fetchAvatars() : null;
    }

    if (_currentMode == EnumSectionDataMode.chosen) {
      diffData();
    }
  }

  /// Update UI without re-loading the whole component.
  void diffData() async {
    if (_loading) {
      return;
    }

    _loading = true;

    final userIds = _users.map((x) => x.id).toList();
    var initialUserIds = widget.section.items;
    if (listEquals(userIds, initialUserIds)) {
      _loading = false;
      return;
    }

    // Ignore illustrations which are still in the list.
    final usersToFetch = initialUserIds.sublist(0)
      ..removeWhere((x) => userIds.contains(x));

    // Remove illustrations which are not in the list anymore.
    _users.removeWhere((x) => !initialUserIds.contains(x.id));

    if (usersToFetch.isEmpty) {
      _loading = false;
      return;
    }

    // Fetch new illustrations.
    final List<Future<UserFirestore>> futures = [];
    for (final id in usersToFetch) {
      futures.add(fetchAvatar(id));
    }

    final futuresResult = await Future.wait(futures);
    setState(() {
      _users.addAll(futuresResult);
      _loading = false;
    });
  }

  /// Fetch only chosen illustrations.
  /// When this section's data fetch mode is equals to 'chosen'.
  void fetchChosenAvatars() async {
    setState(() {
      _loading = true;
      _users.clear();
    });

    final List<Future<UserFirestore>> futures = [];
    for (final id in widget.section.items) {
      futures.add(fetchAvatar(id));
    }

    final futuresResult = await Future.wait(futures);
    setState(() {
      _users.addAll(futuresResult);
      _loading = false;
    });
  }

  Future<UserFirestore> fetchAvatar(String id) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(id)
          .collection("user_public_fields")
          .doc("base")
          .get();

      final map = snapshot.data();
      if (!snapshot.exists || map == null) {
        return UserFirestore.empty();
      }

      // data["id"] = snapshot.id;
      return UserFirestore.fromMap(map);
    } catch (error) {
      Utilities.logger.e(error);
      return UserFirestore.empty();
    }
  }

  void fetchAvatars() {
    if (_loading) {
      return;
    }

    fetchChosenAvatars();
  }

  bool getCanDrag() {
    if (!widget.editMode) {
      return false;
    }

    return _currentMode == EnumSectionDataMode.chosen;
  }

  void goToArtistPage(UserFirestore artist) {
    Beamer.of(context).beamToNamed(
      HomeLocation.profileRoute.replaceFirst(":userId", artist.id),
      routeState: {
        "userId": artist.id,
      },
    );
  }

  void onDropAvatar(int dropTargetIndex, List<int> dragIndexes) {
    final int firstDragIndex = dragIndexes.first;
    if (dropTargetIndex == firstDragIndex) {
      return;
    }

    if (dropTargetIndex < 0 ||
        firstDragIndex < 0 ||
        dropTargetIndex >= _users.length ||
        firstDragIndex > _users.length) {
      return;
    }

    final dropTargetIllustration = _users.elementAt(dropTargetIndex);
    final dragIllustration = _users.elementAt(firstDragIndex);

    setState(() {
      _users[firstDragIndex] = dropTargetIllustration;
      _users[dropTargetIndex] = dragIllustration;
    });

    final List<String> items = _users.map((x) => x.id).toList();
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
          _users.removeWhere((x) => x.id == illustration.id);
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
}
