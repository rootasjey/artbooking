import 'package:artbooking/components/cards/illustration_card.dart';
import 'package:artbooking/components/icons/animated_app_icon.dart';
import 'package:artbooking/screens/illustrations/illustrations_page_empty.dart';
import 'package:artbooking/types/enums/enum_illustration_item_action.dart';
import 'package:artbooking/types/illustration/illustration.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class IllustrationsPageBody extends StatelessWidget {
  const IllustrationsPageBody({
    Key? key,
    required this.loading,
    required this.illustrations,
    required this.likePopupMenuEntries,
    required this.unlikePopupMenuEntries,
    this.onTapIllustrationCard,
    this.onPopupMenuItemSelected,
    this.onDoubleTap,
    this.isMobileSize = false,
  }) : super(key: key);

  /// If true, this widget adapts its layout to small screens.
  final bool isMobileSize;

  /// The page is fetching illustrations if true.
  final bool loading;

  /// List of illustrations.
  final List<Illustration> illustrations;

  /// Callback fired when an illustration card is tapped.
  final void Function(Illustration)? onTapIllustrationCard;

  /// Callback fired when an illustration card is double tapped.
  final void Function(Illustration, int)? onDoubleTap;

  /// Callback fired when a popup item is selected.
  final void Function(
    EnumIllustrationItemAction,
    int,
    Illustration,
    String,
  )? onPopupMenuItemSelected;

  /// List of popup items if the illustration is NOT in
  /// the current authenticated user's favorites.
  final List<PopupMenuEntry<EnumIllustrationItemAction>> likePopupMenuEntries;

  /// List of popup items if the illustration is in
  /// the current authenticated user's favorites.
  final List<PopupMenuEntry<EnumIllustrationItemAction>> unlikePopupMenuEntries;

  @override
  Widget build(BuildContext context) {
    if (loading) {
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

    if (illustrations.isEmpty) {
      return IllustrationsPageEmpty();
    }

    return SliverPadding(
      padding: EdgeInsets.only(
        top: 40.0,
        left: isMobileSize ? 12.0 : 40.0,
        right: isMobileSize ? 12.0 : 40.0,
        bottom: 100.0,
      ),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: isMobileSize ? 150.0 : 300.0,
          mainAxisSpacing: isMobileSize ? 4.0 : 20.0,
          crossAxisSpacing: isMobileSize ? 4.0 : 20.0,
        ),
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            final Illustration illustration = illustrations.elementAt(index);

            final void Function()? _onDoubleTap = onDoubleTap != null
                ? () => onDoubleTap?.call(illustration, index)
                : null;

            final List<PopupMenuEntry<EnumIllustrationItemAction>>
                popupMenuEntries = illustration.liked
                    ? unlikePopupMenuEntries
                    : likePopupMenuEntries;

            return IllustrationCard(
              borderRadius: isMobileSize
                  ? BorderRadius.zero
                  : BorderRadius.circular(16.0),
              elevation: 3.0,
              index: index,
              heroTag: illustration.id,
              illustration: illustration,
              onTap: () => onTapIllustrationCard?.call(illustration),
              onDoubleTap: _onDoubleTap,
              onTapLike: _onDoubleTap,
              onPopupMenuItemSelected: onPopupMenuItemSelected,
              popupMenuEntries: popupMenuEntries,
              size: isMobileSize ? 150.0 : 300.0,
              useBottomSheet: isMobileSize,
              margin: EdgeInsets.zero,
            );
          },
          childCount: illustrations.length,
        ),
      ),
    );
  }
}
