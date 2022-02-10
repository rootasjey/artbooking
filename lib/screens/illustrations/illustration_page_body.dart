import 'package:artbooking/components/icons/animated_app_icon.dart';
import 'package:artbooking/screens/illustrations/illustration_page_header.dart';
import 'package:artbooking/screens/illustrations/illustration_poster.dart';
import 'package:artbooking/types/illustration/illustration.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';

class IllustrationPageBody extends StatelessWidget {
  const IllustrationPageBody({
    Key? key,
    required this.isLoading,
    required this.illustration,
    this.isOwner = false,
    this.liked = false,
    this.onLike,
    this.onShare,
    this.onShowEditMetadataPanel,
    this.onGoToEditImagePage,
    this.updatingImage = false,
  }) : super(key: key);

  final bool isLoading;
  final bool isOwner;
  final bool liked;
  final bool updatingImage;
  final Function()? onLike;
  final Function()? onShare;
  final Function()? onShowEditMetadataPanel;
  final Function()? onGoToEditImagePage;
  final Illustration illustration;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
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

    return SliverPadding(
      padding: const EdgeInsets.only(
        top: 60.0,
        left: 60.0,
        right: 60.0,
        bottom: 120.0,
      ),
      sliver: SliverList(
        delegate: SliverChildListDelegate.fixed([
          IllustrationPageHeader(),
          IllustrationPoster(
            isOwner: isOwner,
            illustration: illustration,
            liked: liked,
            updatingImage: updatingImage,
            onShowEditMetadataPanel: onShowEditMetadataPanel,
            onGoToEditImagePage: onGoToEditImagePage,
            onLike: onLike,
            onShare: onShare,
          ),
        ]),
      ),
    );
  }
}
