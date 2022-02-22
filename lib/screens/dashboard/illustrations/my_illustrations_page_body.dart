import 'package:artbooking/components/cards/illustration_card.dart';
import 'package:artbooking/components/icons/animated_app_icon.dart';
import 'package:artbooking/screens/dashboard/illustrations/my_illustrations_page_empty.dart';
import 'package:artbooking/types/enums/enum_illustration_item_action.dart';
import 'package:artbooking/types/enums/enum_visibility_tab.dart';
import 'package:artbooking/types/illustration/illustration.dart';
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
    this.limitThreeInRow = false,
    this.onDropIllustration,
    this.onGoToActiveTab,
    this.onPopupMenuItemSelected,
    this.onTapIllustration,
    this.uploadIllustration,
  }) : super(key: key);

  final bool loading;
  final bool forceMultiSelect;
  final bool limitThreeInRow;

  final EnumVisibilityTab selectedTab;

  final void Function(Illustration)? onTapIllustration;
  final void Function(
    EnumIllustrationItemAction,
    int,
    Illustration,
    String,
  )? onPopupMenuItemSelected;

  final void Function()? onGoToActiveTab;
  final void Function()? uploadIllustration;

  final List<Illustration> illustrations;
  final List<PopupMenuEntry<EnumIllustrationItemAction>> popupMenuEntries;

  final Map<String?, Illustration> multiSelectedItems;

  /// Callback when drag and dropping item on this illustration card.
  final void Function(int, List<int>)? onDropIllustration;

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

    final selectionMode = forceMultiSelect || multiSelectedItems.isNotEmpty;

    return SliverPadding(
      padding: getGridPadding(),
      sliver: SliverGrid(
        gridDelegate: getGridDelegate(),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final illustration = illustrations.elementAt(index);
            final selected = multiSelectedItems.containsKey(illustration.id);

            return IllustrationCard(
              index: index,
              heroTag: illustration.id,
              illustration: illustration,
              selected: selected,
              selectionMode: selectionMode,
              onTap: () => onTapIllustration?.call(illustration),
              onPopupMenuItemSelected: onPopupMenuItemSelected,
              popupMenuEntries: popupMenuEntries,
              onDrop: (dropIndexes) => onDropIllustration?.call(
                index,
                dropIndexes,
              ),
            );
          },
          childCount: illustrations.length,
        ),
      ),
    );
  }

  EdgeInsets getGridPadding() {
    if (limitThreeInRow) {
      return const EdgeInsets.symmetric(
        horizontal: 120.0,
        vertical: 40.0,
      );
    }

    return const EdgeInsets.only(
      top: 40.0,
      left: 40.0,
      right: 40.0,
      bottom: 100.0,
    );
  }

  SliverGridDelegate getGridDelegate() {
    if (limitThreeInRow) {
      return SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 40.0,
        crossAxisSpacing: 40.0,
      );
    }

    return SliverGridDelegateWithMaxCrossAxisExtent(
      maxCrossAxisExtent: 300.0,
      mainAxisSpacing: 20.0,
      crossAxisSpacing: 20.0,
    );
  }
}
