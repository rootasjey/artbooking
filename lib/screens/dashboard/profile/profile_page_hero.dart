import 'package:artbooking/components/avatar/better_avatar.dart';
import 'package:artbooking/components/popup_menu/popup_menu_item_icon.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/enums/enum_section_action.dart';
import 'package:artbooking/types/section.dart';
import 'package:artbooking/types/user/user_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flash/src/flash_helper.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:unicons/unicons.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfilePageHero extends StatefulWidget {
  const ProfilePageHero({
    Key? key,
    required this.userId,
    this.onPopupMenuItemSelected,
    this.popupMenuEntries = const [],
    required this.index,
    required this.section,
    this.isLast = false,
  }) : super(key: key);

  final bool isLast;
  final String userId;
  final void Function(EnumSectionAction, int, Section)? onPopupMenuItemSelected;
  final List<PopupMenuItemIcon<EnumSectionAction>> popupMenuEntries;

  /// Section's position in the layout (e.g. 0 is the first).
  final int index;
  final Section section;

  @override
  State<ProfilePageHero> createState() => _ProfilePageHeroState();
}

class _ProfilePageHeroState extends State<ProfilePageHero> {
  var _userFirestore = UserFirestore.empty();

  @override
  void initState() {
    super.initState();
    fetchUser();
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height - 200.0;

    var popupMenuEntries = widget.popupMenuEntries;

    if (widget.index == 0) {
      popupMenuEntries = popupMenuEntries.toList();
      popupMenuEntries.removeWhere((x) => x.value == EnumSectionAction.moveUp);
    }

    if (widget.isLast) {
      popupMenuEntries = popupMenuEntries.toList();
      popupMenuEntries
          .removeWhere((x) => x.value == EnumSectionAction.moveDown);
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Stack(
          children: [
            Column(
              children: [
                SizedBox(
                  height: height,
                  child: Row(
                    children: [
                      Flexible(
                        fit: FlexFit.tight,
                        child: SizedBox(
                          child: Column(
                            children: [
                              SizedBox(
                                width: 400.0,
                                height: 500.0,
                                child: Card(
                                  elevation: 6.0,
                                  child: Ink.image(
                                    image: NetworkImage(
                                      "https://picsum.photos/seed/picsum/400/400",
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Flexible(
                        fit: FlexFit.tight,
                        child: SizedBox(
                          child: Column(
                            children: [
                              BetterAvatar(
                                size: 160.0,
                                image: NetworkImage(
                                    "https://picsum.photos/seed/picsum/200/300"),
                                colorFilter: ColorFilter.mode(
                                  Colors.grey,
                                  BlendMode.saturation,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 16.0),
                                child: Text(
                                  _userFirestore.name,
                                  style: Utilities.fonts.style(
                                    fontSize: 24.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      right: 8.0,
                                    ),
                                    child: Opacity(
                                      opacity: 0.6,
                                      child: Icon(UniconsLine.location_point),
                                    ),
                                  ),
                                  Opacity(
                                    opacity: 0.6,
                                    child: Text(
                                      _userFirestore.location,
                                      style: Utilities.fonts.style(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              userLinks(),
                              SizedBox(
                                width: 300.0,
                                child: Divider(
                                  height: 36.0,
                                ),
                              ),
                              SizedBox(
                                width: 400.0,
                                child: Opacity(
                                  opacity: 0.6,
                                  child: Text(
                                    _userFirestore.summary,
                                    style: Utilities.fonts.style(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              right: 0.0,
              child: PopupMenuButton(
                icon: Opacity(
                  opacity: 0.8,
                  child: Icon(
                    UniconsLine.ellipsis_h,
                  ),
                ),
                itemBuilder: (_) => popupMenuEntries,
                onSelected: (EnumSectionAction action) {
                  widget.onPopupMenuItemSelected?.call(
                    action,
                    widget.index,
                    widget.section,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget userLinks() {
    final urls = _userFirestore.urls;

    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Opacity(
        opacity: 0.8,
        child: Wrap(
          spacing: 16.0,
          runSpacing: 12.0,
          children: [
            if (urls.instagram.isNotEmpty)
              IconButton(
                onPressed: () {
                  launch(urls.instagram);
                },
                icon: Icon(UniconsLine.instagram),
              ),
            if (urls.twitter.isNotEmpty)
              IconButton(
                onPressed: () {
                  launch(urls.twitter);
                },
                icon: Icon(UniconsLine.twitter),
              ),
            if (urls.website.isNotEmpty)
              IconButton(
                onPressed: () {
                  launch(urls.website);
                },
                icon: Icon(UniconsLine.globe),
              ),
          ],
        ),
      ),
    );
  }

  Widget getIcon(String key) {
    switch (key) {
      case 'artbooking':
        return Image.asset(
          "assets/images/artbooking.png",
          width: 40.0,
          height: 40.0,
        );
      case 'behance':
        return FaIcon(FontAwesomeIcons.behance);
      case 'dribbble':
        return Icon(UniconsLine.dribbble);
      case 'facebook':
        return Icon(UniconsLine.facebook);
      case 'github':
        return Icon(UniconsLine.github);
      case 'gitlab':
        return FaIcon(FontAwesomeIcons.gitlab);
      case 'instagram':
        return Icon(UniconsLine.instagram);
      case 'linkedin':
        return Icon(UniconsLine.linkedin);
      case 'other':
        return Icon(UniconsLine.question);
      case 'tiktok':
        return FaIcon(FontAwesomeIcons.tiktok);
      case 'twitch':
        return FaIcon(FontAwesomeIcons.twitch);
      case 'twitter':
        return Icon(UniconsLine.twitter);
      case 'website':
        return Icon(UniconsLine.globe);
      case 'wikipedia':
        return FaIcon(FontAwesomeIcons.wikipediaW);
      case 'youtube':
        return Icon(UniconsLine.youtube);
      default:
        return Icon(UniconsLine.globe);
    }
  }

  void fetchUser() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.userId)
          .collection("public")
          .doc("basic")
          .get();

      final mapData = snapshot.data();

      if (!snapshot.exists || mapData == null) {
        return;
      }

      mapData["id"] = snapshot.id;
      setState(() {
        _userFirestore = UserFirestore.fromMap(mapData);
      });
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    }
  }
}
