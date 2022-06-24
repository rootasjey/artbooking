import 'package:artbooking/components/buttons/circle_button.dart';
import 'package:artbooking/components/dialogs/themed_dialog.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/enums/enum_share_content_type.dart';
import 'package:beamer/beamer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unicons/unicons.dart';
import 'package:url_launcher/url_launcher.dart';

class ShareDialog extends StatelessWidget {
  const ShareDialog({
    Key? key,
    required this.name,
    required this.username,
    required this.imageProvider,
    required this.shareContentType,
    required this.itemId,
  }) : super(key: key);

  /// Id of the book/illustraton.
  final String itemId;

  /// Name of the book/illustration.
  final String name;

  /// Owner of this book/illustration.
  final String username;

  /// Thumbnail to display in the dialog.
  final ImageProvider imageProvider;

  /// Define if we're sharing a book or an illustration.
  final EnumShareContentType shareContentType;

  @override
  Widget build(BuildContext context) {
    final double size = 310.0;

    return ThemedDialog(
      showDivider: true,
      title: Text.rich(
        TextSpan(
          text: "share".tr(),
          children: [
            TextSpan(
              text: ": ${name}",
              style: Utilities.fonts.body(
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          style: Utilities.fonts.body(
            fontSize: 16.0,
            fontWeight: FontWeight.w400,
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
                    image: imageProvider,
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
                          text: " ${username}",
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
            ],
          ),
        ),
      ),
      footer: Padding(
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
              onTap: onShareOnFacebook,
              elevation: 2.0,
              tooltip: "facebook",
              backgroundColor: Colors.black87,
              icon: Icon(UniconsLine.facebook_f, color: Colors.white),
            ),
            CircleButton(
              onTap: () => onCopyLink(context),
              elevation: 2.0,
              tooltip: "copy_link".tr(),
              backgroundColor: Colors.black87,
              icon: Icon(UniconsLine.link, color: Colors.white),
            ),
            CircleButton(
              onTap: () => onCopyImage(context),
              elevation: 2.0,
              tooltip: "copy_image".tr(),
              backgroundColor: Colors.black87,
              icon: Icon(UniconsLine.copy_alt, color: Colors.white),
            ),
            CircleButton(
              onTap: () {},
              elevation: 2.0,
              tooltip: "more".tr(),
              backgroundColor: Colors.black87,
              icon: Icon(UniconsLine.ellipsis_h, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  void onCopyLink(BuildContext context) {
    final String type = shareContentType == EnumShareContentType.book
        ? "books"
        : "illustrations";

    Clipboard.setData(
      ClipboardData(text: "https://artbooking.fr/${type}/${itemId}"),
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

  void onCopyImage(BuildContext context) {}

  void onShareOnTwitter() {
    final String type = shareContentType == EnumShareContentType.book
        ? "books"
        : "illustrations";

    final String base = "https://twitter.com/intent/tweet";
    final String hashtags = "artbooking,art,illustrations,books";
    final String text = "share_illustration_tweet_text".tr(
      args: [name, username],
    );
    final String url = "https://artbooking.fr/${type}/${itemId}";
    final String via = "artbookingapp";

    final Uri uri = Uri.parse(
      "$base?text=$text&url=$url&hashtags=$hashtags&via=$via",
    );

    launchUrl(uri);
  }

  void onShareOnFacebook() {}
}
