import 'package:artbooking/components/cards/illustration_card.dart';
import 'package:artbooking/components/icons/animated_app_icon.dart';
import 'package:artbooking/screens/atelier/illustrations/my_illustrations_page_empty.dart';
import 'package:artbooking/types/enums/enum_illustration_item_action.dart';
import 'package:artbooking/types/enums/enum_visibility_tab.dart';
import 'package:artbooking/types/illustration/illustration.dart';
import 'package:artbooking/types/illustration/popup_entry_illustration.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class MyIllustrationsPageBody extends StatelessWidget {
  const MyIllustrationsPageBody({
    Key? key,
    required this.loading,
    required this.illustrations,
    required this.multiSelectedItems,
    required this.forceMultiSelect,
    required this.popupMenuEntries,
    required this.selectedTab,
    this.authenticated = false,
    this.isOwner = false,
    this.likePopupMenuEntries = const [],
    this.limitThreeInRow = false,
    this.onDoubleTap,
    this.onDragIllustrationCompleted,
    this.onDragIllustrationEnd,
    this.onDragIllustrationStarted,
    this.onDragIllustrationUpdate,
    this.onDraggableIllustrationCanceled,
    this.onDropIllustration,
    this.onGoToActiveTab,
    this.onPopupMenuItemSelected,
    this.onTapIllustration,
    this.uploadIllustration,
    this.unlikePopupMenuEntries = const [],
    this.isMobileSize = false,
  }) : super(key: key);

  /// If true, the current user is authenticated.
  final bool authenticated;

  /// If true, the UI is in multi-select mode.
  final bool forceMultiSelect;

  /// If true, this widget adapts its layout to small screens.
  final bool isMobileSize;

  /// True if the current authenticated user is the owner of these books.
  final bool isOwner;

  /// If true, this composant is currently loading.
  final bool loading;

  /// If true, the layout will be limited to 3 illustration in a single row.
  final bool limitThreeInRow;

  /// Selected illustrations tab.
  final EnumVisibilityTab selectedTab;

  /// Callback fired when an illustration card receives a double tap event.
  final void Function(Illustration illustration, int index)? onDoubleTap;

  /// Callback fired when an illustration card receives a tap event.
  final void Function(Illustration)? onTapIllustration;

  /// Callback fired after selecting a popup menu item.
  final void Function(
    EnumIllustrationItemAction,
    int,
    Illustration,
    String,
  )? onPopupMenuItemSelected;

  /// Will navigate to active illustrations tab.
  final void Function()? onGoToActiveTab;

  /// Callback fired to start an illustration upload.
  final void Function()? uploadIllustration;

  /// Callback when illustration dragging is completed.
  final void Function()? onDragIllustrationCompleted;

  /// Callback when illustration dragging has ended.
  final void Function(DraggableDetails)? onDragIllustrationEnd;

  /// Callback when illustration dragging has been canceled.
  final void Function(Velocity, Offset)? onDraggableIllustrationCanceled;

  /// Callback when illustration dragging has started.
  final void Function()? onDragIllustrationStarted;

  /// Callback when dragging an illustration around.
  final void Function(DragUpdateDetails details)? onDragIllustrationUpdate;

  /// Callback when drag and dropping item on this illustration card.
  final void Function(int, List<int>)? onDropIllustration;

  /// Illustration list.
  final List<Illustration> illustrations;

  /// Owner popup menu entries.
  final List<PopupMenuEntry<EnumIllustrationItemAction>> popupMenuEntries;

  /// Available items for authenticated user
  /// and the illustration target is not liked yet.
  final List<PopupEntryIllustration> likePopupMenuEntries;

  /// Available items for authenticated user
  /// and the illustration target is already liked.
  final List<PopupEntryIllustration> unlikePopupMenuEntries;

  /// Group of illustration selected.
  final Map<String?, Illustration> multiSelectedItems;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 100.0),
          child: AnimatedAppIcon(
            textTitle: "illustrations_loading".tr(),
          ),
        ),
      );
    }

    if (illustrations.isEmpty) {
      return MyIllustrationsPageEmpty(
        uploadIllustration: uploadIllustration,
        selectedTab: selectedTab,
        onGoToActiveTab: onGoToActiveTab,
        limitThreeInRow: limitThreeInRow,
      );
    }

    final bool selectionMode =
        forceMultiSelect || multiSelectedItems.isNotEmpty;

    return SliverPadding(
      padding: getGridPadding(),
      sliver: SliverGrid(
        gridDelegate: getGridDelegate(),
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            final Illustration illustration = illustrations.elementAt(index);
            final bool selected = multiSelectedItems.containsKey(
              illustration.id,
            );

            final void Function()? _onDoubleTap = onDoubleTap != null
                ? () => onDoubleTap?.call(illustration, index)
                : null;

            final List<PopupEntryIllustration> illustrationPopupMenuEntries =
                isOwner
                    ? popupMenuEntries
                    : illustration.liked
                        ? unlikePopupMenuEntries
                        : likePopupMenuEntries;

            return IllustrationCard(
              borderRadius: BorderRadius.circular(isMobileSize ? 24.0 : 16.0),
              canDrag: isOwner,
              elevation: 8.0,
              heroTag: illustration.id,
              illustration: illustration,
              index: index,
              onDoubleTap: authenticated ? _onDoubleTap : null,
              onDragCompleted: onDragIllustrationCompleted,
              onDragEnd: onDragIllustrationEnd,
              onDraggableCanceled: onDraggableIllustrationCanceled,
              onDragStarted: onDragIllustrationStarted,
              onDragUpdate: onDragIllustrationUpdate,
              onDrop: onDropIllustration,
              onTapLike: authenticated ? _onDoubleTap : null,
              onTap: () => onTapIllustration?.call(illustration),
              onPopupMenuItemSelected: onPopupMenuItemSelected,
              popupMenuEntries:
                  authenticated ? illustrationPopupMenuEntries : [],
              selected: selected,
              selectionMode: selectionMode,
            );
          },
          childCount: illustrations.length,
        ),
      ),
    );
  }

  EdgeInsets getGridPadding() {
    if (limitThreeInRow) {
      return EdgeInsets.symmetric(
        horizontal: isMobileSize ? 12.0 : 120.0,
        vertical: 40.0,
      );
    }

    return EdgeInsets.only(
      top: 40.0,
      left: isMobileSize ? 12.0 : 40.0,
      right: isMobileSize ? 12.0 : 40.0,
      bottom: 100.0,
    );
  }

  SliverGridDelegate getGridDelegate() {
    if (limitThreeInRow) {
      return SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: isMobileSize ? 12.0 : 40.0,
        crossAxisSpacing: isMobileSize ? 12.0 : 40.0,
      );
    }

    return SliverGridDelegateWithMaxCrossAxisExtent(
      maxCrossAxisExtent: isMobileSize ? 100.0 : 300.0,
      mainAxisSpacing: isMobileSize ? 8.0 : 20.0,
      crossAxisSpacing: isMobileSize ? 8.0 : 20.0,
    );
  }
}
