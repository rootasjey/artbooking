import 'dart:io';

import 'package:artbooking/components/buttons/circle_button.dart';
import 'package:artbooking/components/dialogs/themed_dialog.dart';
import 'package:artbooking/components/loading_view.dart';
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
    required this.shareContentType,
    required this.visibility,
    required this.imageProvider,
    required this.extension,
    required this.imageUrl,
    required this.itemId,
    required this.name,
    required this.username,
    this.asBottomSheet = false,
    this.onShareImage,
    this.onShareText,
    this.onShowVisibilityDialog,
    this.tryDownloadAndShare,
    this.userId = "",
  }) : super(key: key);

  /// If true, this widget will take a suitable layout for bottom sheet.
  /// Otherwise, it will have a dialog layout.
  final bool asBottomSheet;

  /// Define if we're sharing a book or an illustration.
  final EnumShareContentType shareContentType;

  /// Current content visibility.
  final EnumContentVisibility visibility;

  /// Thumbnail to display in the dialog.
  final ImageProvider imageProvider;

  /// Callback fired to share an illustration's image.
  final Future<void> Function()? onShareImage;

  /// Callback fired to share an illustration's url.
  final void Function()? onShareText;

  /// Callback fired to show visibility dialog.
  final Future<EnumContentVisibility?>? Function()? onShowVisibilityDialog;

  /// Callback fired to process image download and share.
  final Future<void> Function()? tryDownloadAndShare;

  /// Content's extension if any.
  final String extension;

  /// Id of the book/illustraton.
  final String itemId;

  /// Thumbnail URL (for book or illustration).
  final String imageUrl;

  /// Name of the book/illustration.
  final String name;

  /// Useful to fetch user's `name` if not provided.
  final String userId;

  /// Owner of this book/illustration.
  final String username;

  @override
  State<ShareDialog> createState() => _ShareDialogState();
}

class _ShareDialogState extends State<ShareDialog> {
  /// Downloading image to prepare sharing, if true.
  bool _tryingToShareImage = false;

  /// Current content's visibility.
  /// Take the initial value of [widget.visibility] in `initState()`.
  EnumContentVisibility _contentVisibility = EnumContentVisibility.public;

  /// Content's owner name.
  String _username = "";

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
    if (widget.asBottomSheet) {
      return mobileLayout();
    }

    return ThemedDialog(
      showDivider: true,
      title: header(),
      onValidate: Beamer.of(context).popRoute,
      onCancel: Beamer.of(context).popRoute,
      textButtonValidation: "close".tr(),
      body: SingleChildScrollView(child: body()),
      footer: footer(),
    );
  }

  Widget body({bool showVisibilityButton = true}) {
    final double size = 310.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            child: Card(
              color: Theme.of(context).backgroundColor,
              elevation: 0.0,
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
          if (showVisibilityButton) visibilityWidget(context),
        ],
      ),
    );
  }

  Widget footer() {
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
        ],
      ),
    );
  }

  Widget header({
    EdgeInsets margin = EdgeInsets.zero,
  }) {
    final Color? textColor = Theme.of(context).textTheme.bodyText2?.color;

    return Padding(
      padding: margin,
      child: Text.rich(
        TextSpan(
          text: "share".tr() + ": ",
          children: [
            TextSpan(
              text: widget.name,
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
        maxLines: widget.asBottomSheet ? 3 : 1,
      ),
    );
  }

  Widget mobileLayout() {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                header(
                  margin: const EdgeInsets.only(
                    top: 28.0,
                    left: 12.0,
                    right: 12.0,
                    bottom: 16.0,
                  ),
                ),
                Divider(
                  thickness: 2.0,
                  color: Theme.of(context).secondaryHeaderColor,
                ),
              ],
            ),
          ),
          if ((Platform.isAndroid || Platform.isIOS))
            ...platformMobileBodyFooter()
          else
            ...webMobileBodyFooter(),
        ],
      ),
    );
  }

  List<Widget> webMobileBodyFooter() {
    return [
      SliverToBoxAdapter(child: body()),
      SliverToBoxAdapter(child: footer()),
    ];
  }

  List<Widget> platformMobileBodyFooter() {
    if (_tryingToShareImage) {
      return mobileDownloadingBodyFooter();
    }

    return mobileIdleBodyFooter();
  }

  List<Widget> mobileIdleBodyFooter() {
    return [
      SliverToBoxAdapter(child: body()),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.only(top: 24.0),
          child: Column(
            children: [
              elevatedTile(
                leading: Icon(UniconsLine.comment_share),
                textValue: "share_link".tr(),
                onTap: widget.onShareText,
              ),
              if (widget.shareContentType == EnumShareContentType.illustration)
                elevatedTile(
                  leading: Icon(UniconsLine.image_share),
                  textValue: "share_image".tr(),
                  onTap: widget.onShareImage != null ? onShareImage : null,
                ),
            ],
          ),
        ),
      ),
    ];
  }

  Widget elevatedTile({
    required final String textValue,
    required final Widget leading,
    final void Function()? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: BorderSide(color: Colors.white, width: 2.0),
        ),
        tileColor: Color.fromRGBO(255, 246, 247, 1),
        leading: leading,
        title: Opacity(
          opacity: 0.8,
          child: Text(
            textValue.toLowerCase(),
            style: Utilities.fonts.body(
              fontSize: 20.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  List<Widget> mobileDownloadingBodyFooter() {
    return [
      LoadingView(
        title: Text("${'share_preparing'.tr()} ..."),
      ),
      SliverToBoxAdapter(
        child: body(
          showVisibilityButton: false,
        ),
      ),
    ];
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
              label: Text(
                "${widget.shareContentType.name}_edit_visibility".tr(),
              ),
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

  void onShareImage() async {
    setState(() => _tryingToShareImage = true);
    await widget.onShareImage?.call();
    setState(() => _tryingToShareImage = false);
  }

  void onShareOnTwitter() {
    final String type = widget.shareContentType == EnumShareContentType.book
        ? "books"
        : "illustrations";

    final String base = "https://twitter.com/intent/tweet";
    final String hashtags = "artbooking,art,illustrations,books";
    final String text = "share_${widget.shareContentType.name}_tweet_text".tr(
      args: [widget.name, _username],
    );
    final String url = "https://artbooking.fr/${type}/${widget.itemId}";
    final String via = "artbookingapp";

    final Uri uri = Uri.parse(
      "$base?text=$text&url=$url&hashtags=$hashtags&via=$via",
    );

    launchUrl(uri);
  }
}
