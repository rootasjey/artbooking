import 'package:artbooking/components/cards/illustration_card.dart';
import 'package:artbooking/components/icons/animated_app_icon.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/screens/book/book_page_body_empty.dart';
import 'package:artbooking/screens/book/book_page_body_error.dart';
import 'package:artbooking/types/book/book_illustration.dart';
import 'package:artbooking/types/enums/enum_illustration_item_action.dart';
import 'package:artbooking/types/illustration/illustration.dart';
import 'package:artbooking/types/illustration_map.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class BookPageBody extends StatelessWidget {
  const BookPageBody({
    Key? key,
    required this.bookIllustrations,
    required this.illustrationMap,
    required this.loading,
    required this.multiSelectedItems,
    required this.popupMenuEntries,
    this.forceMultiSelect = false,
    this.hasError = false,
    this.onPopupMenuItemSelected,
    this.onTapIllustrationCard,
    this.isOwner = false,
    this.onUploadToThisBook,
    this.onBrowseIllustrations,
    this.onDropIllustration,
    this.onDragUpdateBook,
  }) : super(key: key);

  /// Why a map and not just a list?
  ///
  /// -> faster access & because it's already done.
  ///
  /// -> for [multiSelectedItems] allow instant access to know
  /// if an illustration is currently in multi-select.
  final IllustrationMap illustrationMap;

  final List<BookIllustration> bookIllustrations;

  /// True if the page is currently loading.
  final bool loading;

  /// True if the current authenticated user is the owner of this book.
  final bool isOwner;

  /// Currently selected illustrations.
  final IllustrationMap multiSelectedItems;
  final List<PopupMenuEntry<EnumIllustrationItemAction>> popupMenuEntries;
  final bool forceMultiSelect;
  final bool hasError;

  final void Function(
    EnumIllustrationItemAction,
    int,
    Illustration,
    String,
  )? onPopupMenuItemSelected;

  final void Function(String, Illustration)? onTapIllustrationCard;

  /// Upload a new illustration and add it to this book.
  final void Function()? onUploadToThisBook;

  /// Navigate to user's illustrations.
  final void Function()? onBrowseIllustrations;

  /// Callback when drag and dropping item on this illustration card.
  final void Function(int, List<int>)? onDropIllustration;

  /// Callback when dragging a book around.
  final void Function(DragUpdateDetails details)? onDragUpdateBook;

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

    if (bookIllustrations.isEmpty) {
      return BookPageBodyEmpty(
        onBrowseIllustrations: onBrowseIllustrations,
        onUploadToThisBook: onUploadToThisBook,
        isOwner: isOwner,
      );
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
            final bookIllustration = bookIllustrations.elementAt(index);
            final key = Utilities.generateIllustrationKey(bookIllustration);
            final Illustration? illustration = illustrationMap[key];
            final bool selected = multiSelectedItems.containsKey(key);

            if (illustration == null) {
              return Container();
            }

            final void Function() onTap = () => onTapIllustrationCard?.call(
                  key,
                  illustration,
                );

            return IllustrationCard(
              borderRadius: BorderRadius.circular(16.0),
              index: index,
              heroTag: key,
              illustration: illustration,
              key: ValueKey(key),
              illustrationKey: key,
              selected: selected,
              selectionMode: selectionMode,
              canDrag: isOwner,
              onDragUpdate: onDragUpdateBook,
              onDrop: onDropIllustration,
              onTap: onTap,
              onPopupMenuItemSelected: isOwner ? onPopupMenuItemSelected : null,
              popupMenuEntries: isOwner ? popupMenuEntries : [],
            );
          },
          childCount: bookIllustrations.length,
        ),
      ),
    );
  }
}
