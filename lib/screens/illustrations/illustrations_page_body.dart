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
    this.onTapIllustrationCard,
    required this.likePopupMenuEntries,
    this.onPopupMenuItemSelected,
    required this.unlikePopupMenuEntries,
    this.onDoubleTap,
  }) : super(key: key);

  final bool loading;
  final List<Illustration> illustrations;

  final void Function(Illustration)? onTapIllustrationCard;
  final void Function(Illustration, int)? onDoubleTap;
  final void Function(
    EnumIllustrationItemAction,
    int,
    Illustration,
    String,
  )? onPopupMenuItemSelected;

  final List<PopupMenuEntry<EnumIllustrationItemAction>> likePopupMenuEntries;
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
            final illustration = illustrations.elementAt(index);

            return IllustrationCard(
              index: index,
              heroTag: illustration.id,
              illustration: illustration,
              onTap: () => onTapIllustrationCard?.call(illustration),
              onDoubleTap: () => onDoubleTap?.call(illustration, index),
              onTapLike: () => onDoubleTap?.call(illustration, index),
              onPopupMenuItemSelected: onPopupMenuItemSelected,
              popupMenuEntries: illustration.liked
                  ? unlikePopupMenuEntries
                  : likePopupMenuEntries,
            );
          },
          childCount: illustrations.length,
        ),
      ),
    );
  }
}
