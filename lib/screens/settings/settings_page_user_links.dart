import 'package:artbooking/components/dialogs/input_dialog.dart';
import 'package:artbooking/types/user/user_links.dart';
import 'package:beamer/beamer.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:unicons/unicons.dart';

class SettingsPageUserLinks extends StatelessWidget {
  const SettingsPageUserLinks({
    Key? key,
    required this.socialLinks,
    this.onLinkChanged,
  }) : super(key: key);

  final UserSocialLinks socialLinks;
  final void Function(UserSocialLinks)? onLinkChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12.0,
      runSpacing: 12.0,
      children: [
        IconButton(
          tooltip: UserSocialLinks.instagramString,
          onPressed: () => showEditLinkDialog(
            context,
            key: UserSocialLinks.instagramString,
            initialValue: socialLinks.instagram,
            onValidate: (String newValue) {
              return socialLinks.copyWith(instagram: newValue);
            },
          ),
          icon: wrapIcon(
            Icon(UniconsLine.instagram),
            socialLinks.instagram,
          ),
        ),
        IconButton(
          tooltip: UserSocialLinks.twitterString,
          onPressed: () => showEditLinkDialog(
            context,
            key: UserSocialLinks.twitterString,
            initialValue: socialLinks.twitter,
            onValidate: (String newValue) {
              return socialLinks.copyWith(twitter: newValue);
            },
          ),
          icon: wrapIcon(
            Icon(UniconsLine.twitter),
            socialLinks.twitter,
          ),
        ),
        IconButton(
          tooltip: UserSocialLinks.websiteString,
          onPressed: () => showEditLinkDialog(
            context,
            key: UserSocialLinks.websiteString,
            initialValue: socialLinks.website,
            onValidate: (String newValue) {
              return socialLinks.copyWith(website: newValue);
            },
          ),
          icon: wrapIcon(
            Icon(UniconsLine.globe),
            socialLinks.website,
          ),
        ),
        IconButton(
          tooltip: UserSocialLinks.behanceString,
          onPressed: () => showEditLinkDialog(
            context,
            key: UserSocialLinks.behanceString,
            initialValue: socialLinks.behance,
            onValidate: (String newValue) {
              return socialLinks.copyWith(behance: newValue);
            },
          ),
          icon: wrapIcon(
            Icon(UniconsLine.behance),
            socialLinks.behance,
          ),
        ),
        IconButton(
          tooltip: UserSocialLinks.deviantartString,
          onPressed: () => showEditLinkDialog(
            context,
            key: UserSocialLinks.deviantartString,
            initialValue: socialLinks.deviantart,
            onValidate: (String newValue) {
              return socialLinks.copyWith(deviantart: newValue);
            },
          ),
          icon: wrapIcon(
            FaIcon(FontAwesomeIcons.deviantart),
            socialLinks.deviantart,
          ),
        ),
        IconButton(
          tooltip: UserSocialLinks.discordString,
          onPressed: () => showEditLinkDialog(
            context,
            key: UserSocialLinks.discordString,
            initialValue: socialLinks.discord,
            onValidate: (String newValue) {
              return socialLinks.copyWith(discord: newValue);
            },
          ),
          icon: wrapIcon(
            Icon(UniconsLine.discord),
            socialLinks.discord,
          ),
        ),
        IconButton(
          tooltip: UserSocialLinks.dribbbleString,
          onPressed: () => showEditLinkDialog(
            context,
            key: UserSocialLinks.dribbbleString,
            initialValue: socialLinks.dribbble,
            onValidate: (String newValue) {
              return socialLinks.copyWith(dribbble: newValue);
            },
          ),
          icon: wrapIcon(
            Icon(UniconsLine.dribbble),
            socialLinks.dribbble,
          ),
        ),
        IconButton(
          tooltip: UserSocialLinks.facebookString,
          onPressed: () => showEditLinkDialog(
            context,
            key: UserSocialLinks.facebookString,
            initialValue: socialLinks.facebook,
            onValidate: (String newValue) {
              return socialLinks.copyWith(facebook: newValue);
            },
          ),
          icon: wrapIcon(
            Icon(UniconsLine.facebook),
            socialLinks.facebook,
          ),
        ),
        IconButton(
          tooltip: UserSocialLinks.twitchString,
          onPressed: () => showEditLinkDialog(
            context,
            key: UserSocialLinks.twitchString,
            initialValue: socialLinks.twitch,
            onValidate: (String newValue) {
              return socialLinks.copyWith(twitch: newValue);
            },
          ),
          icon: wrapIcon(
            FaIcon(FontAwesomeIcons.twitch),
            socialLinks.twitch,
          ),
        ),
        IconButton(
          tooltip: UserSocialLinks.patreonString,
          onPressed: () => showEditLinkDialog(
            context,
            key: UserSocialLinks.patreonString,
            initialValue: socialLinks.patreon,
            onValidate: (String newValue) {
              return socialLinks.copyWith(patreon: newValue);
            },
          ),
          icon: wrapIcon(
            FaIcon(FontAwesomeIcons.patreon),
            socialLinks.patreon,
          ),
        ),
        IconButton(
          tooltip: UserSocialLinks.tiktokString,
          onPressed: () => showEditLinkDialog(
            context,
            key: UserSocialLinks.tiktokString,
            initialValue: socialLinks.tiktok,
            onValidate: (String newValue) {
              return socialLinks.copyWith(tiktok: newValue);
            },
          ),
          icon: wrapIcon(
            FaIcon(FontAwesomeIcons.tiktok),
            socialLinks.tiktok,
          ),
        ),
        IconButton(
          tooltip: UserSocialLinks.tumblrString,
          onPressed: () => showEditLinkDialog(
            context,
            key: UserSocialLinks.tumblrString,
            initialValue: socialLinks.tumblr,
            onValidate: (String newValue) {
              return socialLinks.copyWith(tumblr: newValue);
            },
          ),
          icon: wrapIcon(
            Icon(UniconsLine.tumblr),
            socialLinks.tumblr,
          ),
        ),
        IconButton(
          tooltip: UserSocialLinks.youtubeString,
          onPressed: () => showEditLinkDialog(
            context,
            key: UserSocialLinks.youtubeString,
            initialValue: socialLinks.youtube,
            onValidate: (String newValue) {
              return socialLinks.copyWith(youtube: newValue);
            },
          ),
          icon: wrapIcon(
            Icon(UniconsLine.youtube),
            socialLinks.youtube,
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
    required UserSocialLinks onValidate(String newValue),
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
          // links.setUrl(key, value);
          final newUserSocialLinks = onValidate.call(value);
          onLinkChanged?.call(newUserSocialLinks);
          Beamer.of(context).popRoute();
        },
        onSubmitted: (value) {
          // links.setUrl(key, value);
          final newUserSocialLinks = onValidate.call(value);
          onLinkChanged?.call(newUserSocialLinks);
          Beamer.of(context).popRoute();
        },
      ),
    );
  }
}
