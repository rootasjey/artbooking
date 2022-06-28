import 'dart:io';

import 'package:artbooking/components/buttons/circle_button.dart';
import 'package:artbooking/components/dialogs/themed_dialog.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/enums/enum_content_visibility.dart';
import 'package:artbooking/types/enums/enum_share_content_type.dart';
import 'package:artbooking/types/json_types.dart';
import 'package:artbooking/types/user/user_firestore.dart';
import 'package:beamer/beamer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unicons/unicons.dart';
import 'package:url_launcher/url_launcher.dart';

class ShareDialog extends StatefulWidget {
  const ShareDialog({
    Key? key,
    required this.name,
    required this.username,
    required this.imageProvider,
    required this.shareContentType,
    required this.itemId,
    required this.imageUrl,
    required this.extension,
    required this.visibility,
    this.userId = "",
    this.onShowVisibilityDialog,
  }) : super(key: key);

  /// Define if we're sharing a book or an illustration.
  final EnumShareContentType shareContentType;

  final EnumContentVisibility visibility;

  /// Thumbnail to display in the dialog.
  final ImageProvider imageProvider;

  final String extension;

  /// Id of the book/illustraton.
  final String itemId;

  /// Thumbnail URL (for book or illustration).
  final String imageUrl;

  /// Name of the book/illustration.
  final String name;
  final String userId;

  /// Owner of this book/illustration.
  final String username;

  // final void Function()? onShowVisibilityDialog;
  final Future<EnumContentVisibility?>? Function()? onShowVisibilityDialog;

  @override
  State<ShareDialog> createState() => _ShareDialogState();
}

class _ShareDialogState extends State<ShareDialog> {
  String _username = "";

  /// Current content's visibility.
  /// Take the initial value of [widget.visibility] in `initState()`.
  var _contentVisibility = EnumContentVisibility.public;

  @override
  void initState() {
    super.initState();

    _contentVisibility = widget.visibility;
    _username = widget.username;
    if (widget.username.isEmpty && widget.userId.isNotEmpty) {
      fetchUsername();
    }
  }

  @override
  Widget build(BuildContext context) {
    final double size = 310.0;
    final Color? textColor = Theme.of(context).textTheme.bodyText2?.color;

    return ThemedDialog(
      showDivider: true,
      title: Text.rich(
        TextSpan(
          text: "share".tr() + ": ",
          children: [
            TextSpan(
              text: "${widget.name}",
              style: Utilities.fonts.body(
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
          ],
          style: Utilities.fonts.body(
            color: textColor?.withOpacity(0.4),
            fontWeight: FontWeight.w700,
          ),
        ),
        maxLines: 1,
      ),
      onValidate: Beamer.of(context).popRoute,
      onCancel: Beamer.of(context).popRoute,
      textButtonValidation: "close".tr(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Column(
            children: [
              Container(
                child: Card(
                  color: Theme.of(context).backgroundColor,
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    side: BorderSide.none,
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: Ink.image(
                    image: widget.imageProvider,
                    fit: BoxFit.cover,
                    width: size,
                    height: size,
                    child: InkWell(
                      onTap: () {},
                    ),
                  ),
                ),
              ),
              Container(
                child: Opacity(
                  opacity: 0.6,
                  child: Text.rich(
                    TextSpan(
                      text: "by".tr().toLowerCase(),
                      children: [
                        TextSpan(
                          text: " ${_username}",
                          style: Utilities.fonts.body(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    style: Utilities.fonts.body(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              visibilityWidget(context),
            ],
          ),
        ),
      ),
      footer: footerWidget(),
    );
  }

  Widget footerWidget() {
    if (_contentVisibility != EnumContentVisibility.public) {
      return Container();
    }

    return Padding(
      padding: const EdgeInsets.only(
        top: 12.0,
        bottom: 24.0,
      ),
      child: Wrap(
        spacing: 16.0,
        runSpacing: 16.0,
        alignment: WrapAlignment.center,
        children: [
          CircleButton(
            onTap: onShareOnTwitter,
            elevation: 2.0,
            tooltip: "twitter",
            backgroundColor: Colors.black87,
            icon: Icon(UniconsLine.twitter, color: Colors.white),
          ),
          CircleButton(
            onTap: () => onCopyLink(context),
            elevation: 2.0,
            tooltip: "copy_link".tr(),
            backgroundColor: Colors.black87,
            icon: Icon(UniconsLine.link, color: Colors.white),
          ),
          if (Platform.isAndroid || Platform.isIOS)
            CircleButton(
              onTap: () => onShareMore(context),
              elevation: 2.0,
              tooltip: "more".tr(),
              backgroundColor: Colors.black87,
              icon: Icon(UniconsLine.ellipsis_h, color: Colors.white),
            ),
        ],
      ),
    );
  }

  Widget visibilityWidget(BuildContext context) {
    if (_contentVisibility == EnumContentVisibility.public) {
      return Container();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
        children: [
          Chip(
            backgroundColor: Theme.of(context).secondaryHeaderColor,
            label: Text(
              "share_visibility_issue"
                      ".${widget.shareContentType.name}"
                      ".${_contentVisibility.name}"
                  .tr(),
            ),
            labelStyle: Utilities.fonts.body(
              color: Colors.white,
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: ActionChip(
              elevation: 2.0,
              avatar: Icon(UniconsLine.eye, size: 16.0),
              label: Text("illustration_edit_visibility".tr()),
              labelStyle: Utilities.fonts.body(
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
              ),
              onPressed: () async {
                if (widget.onShowVisibilityDialog == null) {
                  return;
                }

                final Future<EnumContentVisibility?>? visibilityFutureResult =
                    widget.onShowVisibilityDialog?.call();

                if (visibilityFutureResult == null) {
                  return;
                }

                final EnumContentVisibility? visibilityResult =
                    await visibilityFutureResult;

                if (visibilityResult == null) {
                  return;
                }

                setState(() {
                  _contentVisibility = visibilityResult;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Fetch author from Firestore doc public data (fast).
  Future<bool> fetchUsername() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.userId)
          .collection("user_public_fields")
          .doc("base")
          .get();

      final Json? data = snapshot.data();

      if (!snapshot.exists || data == null) {
        return false;
      }

      data["id"] = widget.userId;
      final user = UserFirestore.fromMap(data);

      setState(() {
        _username = user.name;
      });

      return true;
    } catch (error) {
      Utilities.logger.e(error);
      return false;
    }
  }

  void onCopyLink(BuildContext context) {
    final String type = widget.shareContentType == EnumShareContentType.book
        ? "books"
        : "illustrations";

    Clipboard.setData(
      ClipboardData(text: "https://artbooking.fr/${type}/${widget.itemId}"),
    );

    showFlash(
      context: context,
      duration: Duration(seconds: 3),
      builder: (context, controller) {
        return Flash(
          behavior: FlashBehavior.floating,
          position: FlashPosition.bottom,
          controller: controller,
          child: FlashBar(
            title: Text(
              "share".tr(),
              style: Utilities.fonts.body(
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).primaryColor,
              ),
            ),
            content: Text(
              "copy_link_success".tr(),
              style: Utilities.fonts.body(
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      },
    );
  }

  void onShareOnTwitter() {
    final String type = widget.shareContentType == EnumShareContentType.book
        ? "books"
        : "illustrations";

    final String base = "https://twitter.com/intent/tweet";
    final String hashtags = "artbooking,art,illustrations,books";
    final String text = "share_illustration_tweet_text".tr(
      args: [widget.name, _username],
    );
    final String url = "https://artbooking.fr/${type}/${widget.itemId}";
    final String via = "artbookingapp";

    final Uri uri = Uri.parse(
      "$base?text=$text&url=$url&hashtags=$hashtags&via=$via",
    );

    launchUrl(uri);
  }

  void onShareMore(BuildContext context) {}
}
