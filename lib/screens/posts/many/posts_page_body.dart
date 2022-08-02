import 'package:artbooking/components/buttons/dark_elevated_button.dart';
import 'package:artbooking/components/cards/post_card.dart';
import 'package:artbooking/components/loading_view.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/router/locations/atelier_location.dart';
import 'package:artbooking/router/navigation_state_helper.dart';
import 'package:artbooking/types/enums/enum_content_visibility.dart';
import 'package:artbooking/types/enums/enum_post_item_action.dart';
import 'package:artbooking/types/post.dart';
import 'package:beamer/beamer.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class PostsPageBody extends StatelessWidget {
  const PostsPageBody({
    Key? key,
    required this.loading,
    required this.posts,
    required this.selectedTab,
    this.popupMenuEntries = const [],
    this.onDeletePost,
    this.onTap,
    this.onCreatePost,
    this.onPopupMenuItemSelected,
    this.isMobileSize = false,
  }) : super(key: key);

  /// If true, this widget adapt its layout to small screens.
  final bool isMobileSize;

  /// Main data. List of posts.
  final List<Post> posts;

  /// Data is currently loading if true.
  final bool loading;

  /// Callback fired to delete a post.
  final Function(Post, int)? onDeletePost;

  /// Callback fired to create a post.
  final Function()? onCreatePost;

  /// Callback fired after a post has been tapped.
  final Function(Post)? onTap;

  /// Currently selected tab (drafts or published).
  final EnumContentVisibility selectedTab;

  /// List of entries in post's popup menu.
  final List<PopupMenuEntry<EnumPostItemAction>> popupMenuEntries;

  /// Callback function when popup menu item entries are tapped.
  final void Function(
    EnumPostItemAction action,
    int index,
    Post post,
  )? onPopupMenuItemSelected;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return LoadingView(
        sliver: true,
        title: Text(
          "posts_loading".tr() + "...",
          style: Utilities.fonts.body(
            fontSize: 32.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    if (posts.isEmpty) {
      return SliverPadding(
        padding: EdgeInsets.symmetric(
          horizontal: isMobileSize ? 12.0 : 80.0,
          vertical: isMobileSize ? 24.0 : 69.0,
        ),
        sliver: SliverList(
          delegate: SliverChildListDelegate.fixed([
            Align(
              alignment: Alignment.topLeft,
              child: Opacity(
                opacity: 0.6,
                child: Icon(
                  UniconsLine.no_entry,
                  size: 80.0,
                ),
              ),
            ),
            Opacity(
              opacity: 0.6,
              child: Text(
                selectedTab == EnumContentVisibility.public
                    ? "post_published_empty_create".tr()
                    : "post_draft_empty_create".tr(),
                style: Utilities.fonts.body(
                  fontSize: 26.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: DarkElevatedButton(
                  onPressed: onCreatePost,
                  child: Text(
                    "post_create".tr(),
                  ),
                ),
              ),
            ),
          ]),
        ),
      );
    }

    final bool onPublishedPosts = selectedTab == EnumContentVisibility.public;
    final Color borderColor =
        onPublishedPosts ? Theme.of(context).primaryColor : Colors.grey;

    if (isMobileSize) {
      return SliverPadding(
        padding: const EdgeInsets.only(top: 24.0),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              final Post post = posts.elementAt(index);

              return PostCard(
                post: post,
                index: index,
                isWide: isMobileSize,
                heroTag: post.id,
                borderColor: borderColor,
                descriptionMaxLines: onPublishedPosts ? 5 : 3,
                onTap: (Post post, String heroTag) {
                  NavigationStateHelper.post = post;
                  Beamer.of(context).beamToNamed(
                    AtelierLocationContent.postRoute
                        .replaceFirst(":postId", post.id),
                    routeState: {
                      "postId": post.id,
                    },
                  );
                },
                popupMenuEntries: popupMenuEntries,
                onPopupMenuItemSelected: onPopupMenuItemSelected,
              );
            },
            childCount: posts.length,
          ),
        ),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.only(
        bottom: 300.0,
        left: isMobileSize ? 12.0 : 34.0,
        right: isMobileSize ? 12.0 : 34.0,
      ),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 280.0,
          mainAxisExtent: onPublishedPosts ? 300.0 : 220.0,
          crossAxisSpacing: 8.0,
        ),
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            final Post post = posts.elementAt(index);

            return PostCard(
              post: post,
              index: index,
              heroTag: post.id,
              borderColor: borderColor,
              descriptionMaxLines: onPublishedPosts ? 5 : 3,
              onTap: (Post post, String heroTag) {
                NavigationStateHelper.post = post;
                Beamer.of(context).beamToNamed(
                  AtelierLocationContent.postRoute
                      .replaceFirst(":postId", post.id),
                  routeState: {
                    "postId": post.id,
                  },
                );
              },
              popupMenuEntries: popupMenuEntries,
              onPopupMenuItemSelected: onPopupMenuItemSelected,
            );
          },
          childCount: posts.length,
        ),
      ),
    );
  }
}
