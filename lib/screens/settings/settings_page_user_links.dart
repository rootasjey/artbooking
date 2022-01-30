import 'package:artbooking/components/dialogs/input_dialog.dart';
import 'package:artbooking/types/user/user_urls.dart';
import 'package:beamer/beamer.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:unicons/unicons.dart';

class SettingsPageUserLinks extends StatelessWidget {
  const SettingsPageUserLinks({
    Key? key,
    required this.urls,
    this.onUrlChanged,
  }) : super(key: key);

  final UserUrls urls;
  final void Function(UserUrls)? onUrlChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12.0,
      runSpacing: 12.0,
      children: [
        IconButton(
          tooltip: UserUrls.instagramString,
          onPressed: () => showEditLinkDialog(
            context,
            key: UserUrls.instagramString,
            initialValue: urls.instagram,
          ),
          icon: wrapIcon(
            Icon(UniconsLine.instagram),
            urls.instagram,
          ),
        ),
        IconButton(
          tooltip: UserUrls.twitterString,
          onPressed: () => showEditLinkDialog(
            context,
            key: UserUrls.twitterString,
            initialValue: urls.twitter,
          ),
          icon: wrapIcon(
            Icon(UniconsLine.twitter),
            urls.twitter,
          ),
        ),
        IconButton(
          tooltip: UserUrls.websiteString,
          onPressed: () => showEditLinkDialog(
            context,
            key: UserUrls.websiteString,
            initialValue: urls.website,
          ),
          icon: wrapIcon(
            Icon(UniconsLine.globe),
            urls.website,
          ),
        ),
        IconButton(
          tooltip: UserUrls.behanceString,
          onPressed: () => showEditLinkDialog(
            context,
            key: UserUrls.behanceString,
            initialValue: urls.behance,
          ),
          icon: wrapIcon(
            Icon(UniconsLine.behance),
            urls.behance,
          ),
        ),
        IconButton(
          tooltip: UserUrls.deviantartString,
          onPressed: () => showEditLinkDialog(
            context,
            key: UserUrls.deviantartString,
            initialValue: urls.deviantart,
          ),
          icon: wrapIcon(
            FaIcon(FontAwesomeIcons.deviantart),
            urls.deviantart,
          ),
        ),
        IconButton(
          tooltip: UserUrls.discordString,
          onPressed: () => showEditLinkDialog(
            context,
            key: UserUrls.discordString,
            initialValue: urls.discord,
          ),
          icon: wrapIcon(
            Icon(UniconsLine.discord),
            urls.discord,
          ),
        ),
        IconButton(
          tooltip: UserUrls.dribbbleString,
          onPressed: () => showEditLinkDialog(
            context,
            key: UserUrls.dribbbleString,
            initialValue: urls.dribbble,
          ),
          icon: wrapIcon(
            Icon(UniconsLine.dribbble),
            urls.dribbble,
          ),
        ),
        IconButton(
          tooltip: UserUrls.facebookString,
          onPressed: () => showEditLinkDialog(
            context,
            key: UserUrls.facebookString,
            initialValue: urls.facebook,
          ),
          icon: wrapIcon(
            Icon(UniconsLine.facebook),
            urls.facebook,
          ),
        ),
        IconButton(
          tooltip: UserUrls.twitchString,
          onPressed: () => showEditLinkDialog(
            context,
            key: UserUrls.twitchString,
            initialValue: urls.twitch,
          ),
          icon: wrapIcon(
            FaIcon(FontAwesomeIcons.twitch),
            urls.twitch,
          ),
        ),
        IconButton(
          tooltip: UserUrls.patreonString,
          onPressed: () => showEditLinkDialog(
            context,
            key: UserUrls.patreonString,
            initialValue: urls.patreon,
          ),
          icon: wrapIcon(
            FaIcon(FontAwesomeIcons.patreon),
            urls.patreon,
          ),
        ),
        IconButton(
          tooltip: UserUrls.tiktokString,
          onPressed: () => showEditLinkDialog(
            context,
            key: UserUrls.tiktokString,
            initialValue: urls.tiktok,
          ),
          icon: wrapIcon(
            FaIcon(FontAwesomeIcons.tiktok),
            urls.tiktok,
          ),
        ),
        IconButton(
          tooltip: UserUrls.tumblrString,
          onPressed: () => showEditLinkDialog(
            context,
            key: UserUrls.tumblrString,
            initialValue: urls.tumblr,
          ),
          icon: wrapIcon(
            Icon(UniconsLine.tumblr),
            urls.tumblr,
          ),
        ),
        IconButton(
          tooltip: UserUrls.youtubeString,
          onPressed: () => showEditLinkDialog(
            context,
            key: UserUrls.youtubeString,
            initialValue: urls.youtube,
          ),
          icon: wrapIcon(
            Icon(UniconsLine.youtube),
            urls.youtube,
          ),
        ),
      ],
    );
  }

  Widget wrapIcon(Widget child, String value) {
    return Opacity(
      opacity: value.isEmpty ? 0.4 : 0.8,
      child: child,
    );
  }

  void showEditLinkDialog(
    BuildContext context, {
    required String key,
    required String initialValue,
  }) {
    final _locationController = TextEditingController();
    _locationController.text = initialValue;

    final String hintText = initialValue.isNotEmpty
        ? initialValue
        : 'https://myawesomelink.art/...';

    showDialog(
      context: context,
      builder: (context) => InputDialog.singleInput(
        nameController: _locationController,
        hintText: hintText,
        textInputAction: TextInputAction.send,
        label: "${key.substring(0, 1).toUpperCase()}${key.substring(1)}",
        submitButtonValue: "link_save_new".tr(),
        subtitleValue: "link_update_description".tr(),
        titleValue: "link_update".tr().toUpperCase(),
        onCancel: Beamer.of(context).popRoute,
        onSubmitInput: (value) {
          urls.setUrl(key, value);
          onUrlChanged?.call(urls);
          Beamer.of(context).popRoute();
        },
        onSubmitted: (value) {
          urls.setUrl(key, value);
          onUrlChanged?.call(urls);
          Beamer.of(context).popRoute();
        },
      ),
    );
  }
}
