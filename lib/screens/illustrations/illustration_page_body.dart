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
    this.onLike,
    this.onShare,
    this.onEdit,
  }) : super(key: key);

  final bool isLoading;
  final Function()? onLike;
  final Function()? onShare;
  final Function()? onEdit;
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
            illustration: illustration,
            onEdit: onEdit,
            onLike: onLike,
            onShare: onShare,
          ),
        ]),
      ),
    );
  }
}
