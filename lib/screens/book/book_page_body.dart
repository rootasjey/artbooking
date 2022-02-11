import 'package:artbooking/components/cards/illustration_card.dart';
import 'package:artbooking/components/icons/animated_app_icon.dart';
import 'package:artbooking/screens/book/book_page.dart';
import 'package:artbooking/screens/book/book_page_body_empty.dart';
import 'package:artbooking/screens/book/book_page_body_error.dart';
import 'package:artbooking/types/enums/enum_illustration_item_action.dart';
import 'package:artbooking/types/illustration/illustration.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class BookPageBody extends StatelessWidget {
  const BookPageBody({
    Key? key,
    required this.illustrations,
    required this.loading,
    required this.multiSelectedItems,
    required this.popupMenuEntries,
    this.forceMultiSelect = false,
    this.hasError = false,
    this.onPopupMenuItemSelected,
    this.onLongPressIllustration,
    this.onTapIllustrationCard,
  }) : super(key: key);

  /// Why a map and not just a list?
  ///
  /// -> faster access & because it's already done.
  ///
  /// -> for [multiSelectedItems] allow instant access to know
  /// if an illustration is currently in multi-select.
  final MapStringIllustration illustrations;

  final bool loading;

  /// Currently selected illustrations.
  final MapStringIllustration multiSelectedItems;
  final List<PopupMenuEntry<EnumIllustrationItemAction>> popupMenuEntries;
  final bool forceMultiSelect;
  final bool hasError;

  final void Function(String, Illustration, bool)? onLongPressIllustration;
  final void Function(EnumIllustrationItemAction, int, Illustration, String)?
      onPopupMenuItemSelected;
  final void Function(String, Illustration)? onTapIllustrationCard;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.only(top: 100.0),
          child: AnimatedAppIcon(
            textTitle: "illustrations_loading".tr(),
          ),
        ),
      );
    }

    if (hasError) {
      return BookPageBodyError();
    }

    if (illustrations.isEmpty) {
      return BookPageBodyEmpty();
    }

    final selectionMode = forceMultiSelect || multiSelectedItems.isNotEmpty;

    return SliverPadding(
      padding: const EdgeInsets.all(40.0),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 300.0,
          mainAxisSpacing: 20.0,
          crossAxisSpacing: 20.0,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final illustration = illustrations.values.elementAt(index);
            final illustrationKey = illustrations.keys.elementAt(index);
            final selected = multiSelectedItems.containsKey(illustrationKey);

            return IllustrationCard(
              index: index,
              heroTag: illustrationKey,
              illustration: illustration,
              key: ValueKey(illustrationKey),
              illustrationKey: illustrationKey,
              selected: selected,
              selectionMode: selectionMode,
              onTap: () =>
                  onTapIllustrationCard?.call(illustrationKey, illustration),
              onPopupMenuItemSelected: onPopupMenuItemSelected,
              popupMenuEntries: popupMenuEntries,
              onLongPress: onLongPressIllustration,
            );
          },
          childCount: illustrations.length,
        ),
      ),
    );
  }
}
