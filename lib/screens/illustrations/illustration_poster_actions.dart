import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class IllustrationPosterActions extends StatelessWidget {
  const IllustrationPosterActions({
    Key? key,
    this.onLike,
    this.onShare,
    this.onEdit,
  }) : super(key: key);

  final Function()? onLike;
  final Function()? onShare;
  final Function()? onEdit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 32.0,
        left: 12.0,
        right: 12.0,
      ),
      child: Opacity(
        opacity: 0.8,
        child: Wrap(
          spacing: 16.0,
          alignment: WrapAlignment.center,
          children: [
            IconButton(
              tooltip: "like".tr(),
              icon: Icon(UniconsLine.heart),
              onPressed: onLike,
            ),
            IconButton(
              tooltip: "share".tr(),
              icon: Icon(UniconsLine.share),
              onPressed: onShare,
            ),
            IconButton(
              tooltip: "edit".tr(),
              icon: Icon(UniconsLine.edit),
              onPressed: onEdit,
            ),
          ],
        ),
      ),
    );
  }
}
