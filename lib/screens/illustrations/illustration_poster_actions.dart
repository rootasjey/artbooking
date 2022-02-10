import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class IllustrationPosterActions extends StatelessWidget {
  const IllustrationPosterActions({
    Key? key,
    this.liked = false,
    this.onLike,
    this.onShare,
    this.onEdit,
    this.onEditImage,
    this.updatingImage = false,
  }) : super(key: key);

  final bool liked;

  final Function()? onLike;
  final Function()? onShare;
  final Function()? onEdit;
  final Function()? onEditImage;

  /// True if the image is being updated
  /// after a transformation (crop, rotate, flip).
  final bool updatingImage;

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
              tooltip: liked ? "unlike".tr() : "like".tr(),
              icon: Icon(UniconsLine.heart),
              color: liked ? Theme.of(context).secondaryHeaderColor : null,
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
            IconButton(
              tooltip: "edit_image".tr(),
              icon: Icon(UniconsLine.crop_alt),
              onPressed: updatingImage ? null : onEditImage,
            ),
          ],
        ),
      ),
    );
  }
}
