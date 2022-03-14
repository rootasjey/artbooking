import 'package:artbooking/components/dialogs/input_dialog.dart';
import 'package:artbooking/types/icon_social_link_data.dart';
import 'package:artbooking/types/user/user_social_links.dart';
import 'package:beamer/beamer.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:unicons/unicons.dart';
import 'package:url_launcher/url_launcher.dart';

/// Display user's social links in a Wrap widget.
class UserSocialLinksComponent extends StatelessWidget {
  const UserSocialLinksComponent({
    Key? key,
    required this.socialLinks,
    this.onLinkChanged,
    this.hideEmpty = false,
    this.editMode = false,
  }) : super(key: key);

  /// Empty links will hidden if true.
  final bool hideEmpty;

  /// If true, clicking on a link will open edit dialog.
  final bool editMode;
  final UserSocialLinks socialLinks;
  final void Function(UserSocialLinks)? onLinkChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12.0,
      runSpacing: 12.0,
      alignment: WrapAlignment.center,
      children: getChildren2().map((x) {
        return IconButton(
          tooltip: x.tooltip,
          onPressed: () => onTap(
            context,
            key: x.socialKey,
            initialValue: x.initialValue,
            onValidate: x.onValidate,
          ),
          icon: x.icon,
        );
      }).toList(),
    );
  }

  List<IconSocialLinkData> getChildren2() {
    final data = [
      IconSocialLinkData(
        isEmpty: socialLinks.instagram.isEmpty,
        tooltip: UserSocialLinks.instagramString,
        socialKey: UserSocialLinks.instagramString,
        initialValue: socialLinks.instagram,
        icon: wrapIcon(
          Icon(UniconsLine.instagram),
          socialLinks.instagram,
        ),
        onValidate: (String newValue) {
          return socialLinks.copyWith(instagram: newValue);
        },
      ),
      IconSocialLinkData(
        isEmpty: socialLinks.twitter.isEmpty,
        tooltip: UserSocialLinks.twitterString,
        socialKey: UserSocialLinks.twitterString,
        initialValue: socialLinks.twitter,
        icon: wrapIcon(
          Icon(UniconsLine.twitter),
          socialLinks.twitter,
        ),
        onValidate: (String newValue) {
          return socialLinks.copyWith(twitter: newValue);
        },
      ),
      IconSocialLinkData(
        isEmpty: socialLinks.website.isEmpty,
        tooltip: UserSocialLinks.websiteString,
        socialKey: UserSocialLinks.websiteString,
        initialValue: socialLinks.website,
        icon: wrapIcon(
          Icon(UniconsLine.globe),
          socialLinks.website,
        ),
        onValidate: (String newValue) {
          return socialLinks.copyWith(website: newValue);
        },
      ),
      IconSocialLinkData(
        isEmpty: socialLinks.behance.isEmpty,
        tooltip: UserSocialLinks.behanceString,
        socialKey: UserSocialLinks.behanceString,
        initialValue: socialLinks.behance,
        icon: wrapIcon(
          Icon(UniconsLine.behance),
          socialLinks.behance,
        ),
        onValidate: (String newValue) {
          return socialLinks.copyWith(behance: newValue);
        },
      ),
      IconSocialLinkData(
        isEmpty: socialLinks.deviantart.isEmpty,
        tooltip: UserSocialLinks.deviantartString,
        socialKey: UserSocialLinks.deviantartString,
        initialValue: socialLinks.deviantart,
        icon: wrapIcon(
          FaIcon(FontAwesomeIcons.deviantart),
          socialLinks.deviantart,
        ),
        onValidate: (String newValue) {
          return socialLinks.copyWith(deviantart: newValue);
        },
      ),
      IconSocialLinkData(
        isEmpty: socialLinks.discord.isEmpty,
        tooltip: UserSocialLinks.discordString,
        socialKey: UserSocialLinks.discordString,
        initialValue: socialLinks.discord,
        icon: wrapIcon(
          Icon(UniconsLine.discord),
          socialLinks.discord,
        ),
        onValidate: (String newValue) {
          return socialLinks.copyWith(discord: newValue);
        },
      ),
      IconSocialLinkData(
        isEmpty: socialLinks.dribbble.isEmpty,
        tooltip: UserSocialLinks.dribbbleString,
        socialKey: UserSocialLinks.dribbbleString,
        initialValue: socialLinks.dribbble,
        icon: wrapIcon(
          Icon(UniconsLine.dribbble),
          socialLinks.dribbble,
        ),
        onValidate: (String newValue) {
          return socialLinks.copyWith(dribbble: newValue);
        },
      ),
      IconSocialLinkData(
        isEmpty: socialLinks.facebook.isEmpty,
        tooltip: UserSocialLinks.facebookString,
        socialKey: UserSocialLinks.facebookString,
        initialValue: socialLinks.facebook,
        icon: wrapIcon(
          Icon(UniconsLine.facebook),
          socialLinks.facebook,
        ),
        onValidate: (String newValue) {
          return socialLinks.copyWith(facebook: newValue);
        },
      ),
      IconSocialLinkData(
        isEmpty: socialLinks.twitch.isEmpty,
        tooltip: UserSocialLinks.twitchString,
        socialKey: UserSocialLinks.twitchString,
        initialValue: socialLinks.twitch,
        icon: wrapIcon(
          FaIcon(FontAwesomeIcons.twitch),
          socialLinks.twitch,
        ),
        onValidate: (String newValue) {
          return socialLinks.copyWith(twitch: newValue);
        },
      ),
      IconSocialLinkData(
        isEmpty: socialLinks.patreon.isEmpty,
        tooltip: UserSocialLinks.patreonString,
        socialKey: UserSocialLinks.patreonString,
        initialValue: socialLinks.patreon,
        icon: wrapIcon(
          FaIcon(FontAwesomeIcons.patreon),
          socialLinks.patreon,
        ),
        onValidate: (String newValue) {
          return socialLinks.copyWith(patreon: newValue);
        },
      ),
      IconSocialLinkData(
        isEmpty: socialLinks.tiktok.isEmpty,
        tooltip: UserSocialLinks.tiktokString,
        socialKey: UserSocialLinks.tiktokString,
        initialValue: socialLinks.tiktok,
        icon: wrapIcon(
          FaIcon(FontAwesomeIcons.tiktok),
          socialLinks.tiktok,
        ),
        onValidate: (String newValue) {
          return socialLinks.copyWith(tiktok: newValue);
        },
      ),
      IconSocialLinkData(
        isEmpty: socialLinks.tumblr.isEmpty,
        tooltip: UserSocialLinks.tumblrString,
        socialKey: UserSocialLinks.tumblrString,
        initialValue: socialLinks.tumblr,
        icon: wrapIcon(
          Icon(UniconsLine.tumblr),
          socialLinks.tumblr,
        ),
        onValidate: (String newValue) {
          return socialLinks.copyWith(tumblr: newValue);
        },
      ),
      IconSocialLinkData(
        isEmpty: socialLinks.youtube.isEmpty,
        tooltip: UserSocialLinks.youtubeString,
        socialKey: UserSocialLinks.youtubeString,
        initialValue: socialLinks.youtube,
        icon: wrapIcon(
          Icon(UniconsLine.youtube),
          socialLinks.youtube,
        ),
        onValidate: (String newValue) {
          return socialLinks.copyWith(youtube: newValue);
        },
      ),
    ];

    if (hideEmpty) {
      data.removeWhere((x) => x.isEmpty);
    }

    return data;
  }

  List<Widget> getChildren1(BuildContext context) {
    return [
      IconButton(
        tooltip: UserSocialLinks.instagramString,
        onPressed: () => onTap(
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
        onPressed: () => onTap(
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
        onPressed: () => onTap(
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
        onPressed: () => onTap(
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
        onPressed: () => onTap(
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
        onPressed: () => onTap(
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
        onPressed: () => onTap(
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
        onPressed: () => onTap(
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
        onPressed: () => onTap(
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
        onPressed: () => onTap(
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
        onPressed: () => onTap(
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
        onPressed: () => onTap(
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
        onPressed: () => onTap(
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
    ];
  }

  Widget wrapIcon(Widget child, String value) {
    return Opacity(
      opacity: value.isEmpty ? 0.4 : 0.8,
      child: child,
    );
  }

  void onTap(
    BuildContext context, {
    required String key,
    required String initialValue,
    required UserSocialLinks onValidate(String newValue),
  }) {
    if (!editMode) {
      if (initialValue.isEmpty) {
        return;
      }

      launch(initialValue);
      return;
    }

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
        onSubmitted: (value) {
          final newUserSocialLinks = onValidate.call(value);
          onLinkChanged?.call(newUserSocialLinks);
          Beamer.of(context).popRoute();
        },
      ),
    );
  }
}
