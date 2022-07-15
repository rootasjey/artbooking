import 'package:artbooking/components/icons/animated_app_icon.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/screens/illustrations/illustration_page_header.dart';
import 'package:artbooking/screens/illustrations/illustration_poster.dart';
import 'package:artbooking/types/illustration/illustration.dart';
import 'package:artbooking/types/user/user_firestore.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';

class IllustrationPageBody extends StatelessWidget {
  const IllustrationPageBody({
    Key? key,
    required this.loading,
    required this.illustration,
    this.isOwner = false,
    this.liked = false,
    this.onLike,
    this.onShare,
    this.onShowEditMetadataPanel,
    this.onGoToEditImagePage,
    this.updatingImage = false,
    this.heroTag = "",
    this.onTapUser,
  }) : super(key: key);

  /// True if the current authenticated user is the owner of this illustration.
  final bool isOwner;

  /// True if the current authenticated user has liked this illustration.
  final bool liked;

  /// True if this page is laoding.
  final bool loading;

  /// True if this illustration is being updated (new image upload).
  final bool updatingImage;

  /// Callback fired when illustration is liked.
  final Function()? onLike;

  /// Callback fired when illustration is shared.
  final Function()? onShare;

  /// Callback fired to show edit panel for illustration's metadata.
  final Function()? onShowEditMetadataPanel;

  /// Callback fired to edit image (crop, resize, ...).
  final Function()? onGoToEditImagePage;

  /// Callback fired when tapping on this illustration's owner.
  final void Function(UserFirestore)? onTapUser;

  /// Main data. The view is based on this illustration.
  final Illustration illustration;

  /// Custom hero tag (if `illustration.id` default tag is not unique).
  final String heroTag;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return SliverPadding(
        padding: const EdgeInsets.only(top: 80.0),
        sliver: SliverList(
          delegate: SliverChildListDelegate([
            Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                children: [
                  AnimatedAppIcon(
                    textTitle: "loading".tr(),
                  ),
                ],
              ),
            ),
          ]),
        ),
      );
    }

    final bool isMobileSize = Utilities.size.isMobileSize(context);

    final double left = isMobileSize ? 0.0 : 60.0;
    final double right = isMobileSize ? 0.0 : 60.0;

    return SliverPadding(
      padding: EdgeInsets.only(
        top: 60.0,
        left: left,
        right: right,
        bottom: 120.0,
      ),
      sliver: SliverList(
        delegate: SliverChildListDelegate.fixed([
          IllustrationPageHeader(
            show: !isMobileSize,
          ),
          IllustrationPoster(
            isOwner: isOwner,
            illustration: illustration,
            liked: liked,
            updatingImage: updatingImage,
            onShowEditMetadataPanel: onShowEditMetadataPanel,
            onGoToEditImagePage: onGoToEditImagePage,
            onLike: onLike,
            onShare: onShare,
            onTapUser: onTapUser,
            heroTag: heroTag,
          ),
        ]),
      ),
    );
  }
}
