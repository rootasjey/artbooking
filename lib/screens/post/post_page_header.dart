import 'package:artbooking/components/buttons/lang_popup_menu_button.dart';
import 'package:artbooking/components/popup_menu/popup_menu_item_icon.dart';
import 'package:artbooking/components/user_avatar_extended.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/enums/enum_content_visibility.dart';
import 'package:artbooking/types/post.dart';
import 'package:beamer/beamer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:unicons/unicons.dart';

class PostPageHeader extends StatelessWidget {
  const PostPageHeader({
    Key? key,
    required this.descriptionController,
    required this.onLangChanged,
    required this.onShowAddTagModal,
    required this.post,
    required this.titleController,
    this.canManagePosts = false,
    this.isMobileSize = false,
    this.onTitleChanged,
    this.onDeleteTag,
    this.popupVisibilityItems = const [],
    this.onVisibilityItemSelected,
  }) : super(key: key);

  /// The current authenticated user can edit & delete this post if true.
  final bool canManagePosts;

  /// The UI adapts to small screen size if true.
  final bool isMobileSize;

  /// List of popup items to manage post's visibility.
  final List<PopupMenuEntry<EnumContentVisibility>> popupVisibilityItems;

  /// Main data of this page.
  /// A post about a subject.
  final Post post;

  /// Callback fired to delete a tag from a post.
  final void Function(String)? onDeleteTag;

  /// Callback fired showing a modal to add a tag.
  final void Function() onShowAddTagModal;

  /// Callback fired when title is updated.
  final void Function(String?)? onTitleChanged;

  /// Callback fired when language is updated.
  final void Function(String) onLangChanged;

  /// Callback fired when a visibility popup menu item is selected..
  final void Function(
    EnumContentVisibility visibility,
  )? onVisibilityItemSelected;

  /// Controller related to the description edition.
  final TextEditingController descriptionController;

  /// Controller related to the title edition.
  final TextEditingController titleController;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: 56,
            horizontal: isMobileSize ? 12.0 : 24.0,
          ),
          width: 600.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isMobileSize)
                IconButton(
                  tooltip: "back".tr(),
                  onPressed: () => Beamer.of(context).beamBack(),
                  icon: Icon(UniconsLine.arrow_left),
                ),
              titleWidget(),
              descriptionWidget(),
              dateWidget(),
              tagsWidget(),
              pubAndLangWidgets(context),
              authorsWidget(),
            ],
          ),
        ),
      ),
    );
  }

  Widget authorsWidget() {
    if (post.userIds.isEmpty || post.userIds.first.isEmpty) {
      return Container();
    }

    return UserAvatarExtended(
      userId: post.userIds.first,
      padding: const EdgeInsets.only(top: 24.0),
    );
  }

  Widget dateWidget() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Wrap(
        spacing: 12.0,
        runSpacing: 12.0,
        children: [
          publishedAtWidget(),
          updatedAtWidget(),
        ],
      ),
    );
  }

  Widget descriptionWidget() {
    if (!canManagePosts && post.description.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
        child: Opacity(
          opacity: 0.6,
          child: Text(
            post.description,
            style: Utilities.fonts.body(
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Opacity(
        opacity: 0.6,
        child: TextField(
          controller: descriptionController,
          style: Utilities.fonts.body(
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
          ),
          maxLines: null,
          onChanged: onTitleChanged,
          decoration: InputDecoration(
            hintText: "post_description".tr() + "...",
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget pubAndLangWidgets(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Row(
        children: [
          pubWidget(context),
          Container(
            height: 40.0,
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: VerticalDivider(
              width: 2.0,
              thickness: 2.0,
            ),
          ),
          LangPopupMenuButton(
            outlined: true,
            lang: post.language,
            onLangChanged: onLangChanged,
          ),
        ],
      ),
    );
  }

  Widget pubWidget(BuildContext context) {
    if (!canManagePosts) {
      return Container();
    }

    final Color baseColor =
        Theme.of(context).textTheme.bodyText2?.color?.withOpacity(0.4) ??
            Colors.black;

    return PopupMenuButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6.0),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12.0,
          vertical: 6.0,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3.0),
          border: Border.all(
            color: baseColor.withOpacity(0.3),
            width: 2.0,
          ),
        ),
        child: Text(
          post.visibility == EnumContentVisibility.public
              ? "published".tr()
              : "visibility_private".tr(),
          style: Utilities.fonts.body(
            color: baseColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      onSelected: onVisibilityItemSelected,
      itemBuilder: (_) => popupVisibilityItems.map(
        (final PopupMenuEntry<EnumContentVisibility> item) {
          final popupMenuItemIcon =
              item as PopupMenuItemIcon<EnumContentVisibility>;

          final bool selected = post.visibility == popupMenuItemIcon.value;
          final Color? selectedColor =
              selected ? Theme.of(context).secondaryHeaderColor : null;

          return popupMenuItemIcon.copyWith(
            selected: selected,
            selectedColor: selectedColor,
          );
        },
      ).toList(),
    );
  }

  Widget titleWidget({bool canEdit = false}) {
    if (!canEdit) {
      return Text(
        post.name,
        style: Utilities.fonts.title3(
          fontSize: 64.0,
          fontWeight: FontWeight.w700,
        ),
      );
    }

    return Hero(
      tag: post.id,
      child: Material(
        color: Colors.transparent,
        child: TextField(
          controller: titleController,
          style: Utilities.fonts.title3(
            fontSize: 64.0,
            fontWeight: FontWeight.w700,
          ),
          maxLines: null,
          onChanged: onTitleChanged,
          decoration: InputDecoration(
            hintText: "post_title".tr(),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget tagsWidget() {
    final List<Widget> children = [];

    for (final String tag in post.tags) {
      children.add(
        Chip(
          label: Opacity(
            opacity: 0.8,
            child: Text(
              tag,
              style: Utilities.fonts.body4(
                fontSize: isMobileSize ? 14.0 : 16.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          onDeleted: canManagePosts ? () => onDeleteTag?.call(tag) : null,
        ),
      );
    }

    if (canManagePosts) {
      children.add(
        ActionChip(
          tooltip: "tag_add".tr(),
          elevation: 2.0,
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (post.tags.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Opacity(
                    opacity: 0.8,
                    child: Text(
                      "tag_add".tr().toLowerCase(),
                      style: Utilities.fonts.body(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              Icon(UniconsLine.plus, size: 16.0),
            ],
          ),
          onPressed: onShowAddTagModal,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Wrap(
        spacing: 12.0,
        runSpacing: 12.0,
        children: children,
      ),
    );
  }

  Widget publishedAtWidget() {
    final DateTime publishedAt = post.publishedAt;
    final Duration publishedAtDiff = DateTime.now().difference(publishedAt);
    final String publishedAtStr = publishedAtDiff.inDays > 20
        ? Jiffy(publishedAt).yMMMEd
        : Jiffy(publishedAt).fromNow();

    return Opacity(
      opacity: 0.6,
      child: Text(
        publishedAtStr,
        style: Utilities.fonts.body3(
          fontSize: 14.0,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget updatedAtWidget() {
    final DateTime updatedAt = post.updatedAt;
    final bool updateSameOrBeforePub =
        Jiffy(updatedAt).isSameOrBefore(post.publishedAt);

    final bool updatePubDiff =
        updatedAt.difference(post.publishedAt).inMinutes < 30;

    final bool dateTooClose = updateSameOrBeforePub || updatePubDiff;

    if (post.visibility == EnumContentVisibility.public && dateTooClose) {
      return Container();
    }

    if (updatedAt.difference(post.createdAt).inMinutes < 10) {
      return Container();
    }

    final Duration updatedAtDiff = DateTime.now().difference(updatedAt);
    final String updatedAtStr = updatedAtDiff.inDays > 20
        ? Jiffy(updatedAt).format("dd/MM/yy")
        : Jiffy(updatedAt).fromNow();

    return Opacity(
      opacity: 0.5,
      child: Text(
        "(" + "date_last_update".tr() + ": $updatedAtStr)",
        style: Utilities.fonts.body3(
          fontSize: 14.0,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
