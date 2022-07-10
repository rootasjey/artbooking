import 'package:artbooking/components/animations/fade_in_y.dart';
import 'package:artbooking/screens/post/bottom_action_bar_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:unicons/unicons.dart';

class BottomActionBar extends StatelessWidget {
  const BottomActionBar({
    Key? key,
    this.canManagePosts = false,
    this.authenticated = false,
    this.onShare,
    this.onToggleLike,
    this.onDelete,
    this.show = true,
    this.liked = false,
    this.published = false,
  }) : super(key: key);

  /// True if the current user is authenticated.
  final bool authenticated;

  /// True if the current authenticated user have the necessary rights
  /// to edit or delete this post.
  final bool canManagePosts;

  /// True if the post is in the current authenticated user's favourites.
  final bool liked;

  /// True if the post is published.
  final bool published;

  /// If true, the bar will be displayed. Will show an empty container otherwise.
  final bool show;

  /// Callback fired to delete this post.
  final void Function()? onDelete;

  /// Callback fired to share this post.
  final void Function()? onShare;

  /// Callback fired to add or remove this post
  /// from the current user favourites.
  final void Function()? onToggleLike;

  @override
  Widget build(BuildContext context) {
    if (!show) {
      return Container();
    }

    return Positioned(
      bottom: 24.0,
      left: 0.0,
      right: 0.0,
      child: FadeInY(
        beginY: 12.0,
        duration: Duration(milliseconds: 500),
        child: Center(
          child: Card(
            elevation: 6.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32.0),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 6.0,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (authenticated && published)
                    BottomActionBarButton(
                      iconData:
                          liked ? FontAwesomeIcons.heart : UniconsLine.heart,
                      onPressed: onToggleLike,
                      tooltip: liked ? "unlike".tr() : "like".tr(),
                    ),
                  if (canManagePosts)
                    BottomActionBarButton(
                      iconData: UniconsLine.trash,
                      onPressed: onDelete,
                      tooltip: "delete".tr(),
                    ),
                  BottomActionBarButton(
                    iconData: UniconsLine.link,
                    onPressed: onShare,
                    tooltip: "copy_link".tr(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
