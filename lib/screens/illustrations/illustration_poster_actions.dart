import 'package:artbooking/components/buttons/heart_button.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class IllustrationPosterActions extends StatelessWidget {
  const IllustrationPosterActions({
    Key? key,
    this.isOwner = false,
    this.liked = false,
    this.onLike,
    this.onShare,
    this.onEdit,
    this.onEditImage,
    this.updatingImage = false,
  }) : super(key: key);

  final bool isOwner;
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
            if (onLike != null)
              HeartButton(
                asIconButton: true,
                liked: liked,
                tooltip: liked ? "unlike".tr() : "like".tr(),
                onTap: onLike,
              ),
            if (onShare != null)
              IconButton(
                tooltip: "share".tr(),
                icon: Icon(UniconsLine.share),
                onPressed: onShare,
              ),
            ...getOwnerActions(),
          ],
        ),
      ),
    );
  }

  List<Widget> getOwnerActions() {
    if (!isOwner) {
      return [];
    }

    return [
      IconButton(
        tooltip: "edit_illustration_texts".tr(),
        icon: Icon(UniconsLine.edit_alt),
        onPressed: onEdit,
      ),
      IconButton(
        tooltip: "edit_image".tr(),
        icon: Icon(UniconsLine.image_edit),
        onPressed: updatingImage ? null : onEditImage,
      ),
    ];
  }
}
