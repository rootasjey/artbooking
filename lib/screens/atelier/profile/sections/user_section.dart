import 'package:artbooking/components/avatar/better_avatar.dart';
import 'package:artbooking/components/cards/illustration_card.dart';
import 'package:artbooking/components/popup_menu/popup_menu_item_icon.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/components/user_social_links_component.dart';
import 'package:artbooking/types/enums/enum_section_action.dart';
import 'package:artbooking/types/illustration/illustration.dart';
import 'package:artbooking/types/section.dart';
import 'package:artbooking/types/user/user_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flash/src/flash_helper.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:unicons/unicons.dart';

/// A section showing user's public information.
/// An optional illustration background can be configured.
class UserSection extends StatefulWidget {
  const UserSection({
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
  State<UserSection> createState() => _UserSectionState();
}

class _UserSectionState extends State<UserSection> {
  var _userFirestore = UserFirestore.empty();
  final List<Illustration> _illustrations = [];
  var _illustrationBackground = Illustration.empty();

  @override
  void initState() {
    super.initState();
    fetchData();
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
      popupMenuEntries.removeWhere((x) {
        return x.value == EnumSectionAction.moveDown;
      });
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(left: 24.0, top: 60.0, right: 24.0),
        child: Stack(
          children: [
            SizedBox(
              height: height,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  imageBackground(),
                  userWidget(),
                ],
              ),
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

  Widget imageBackground() {
    if (_illustrationBackground.id.isEmpty) {
      return Container();
    }

    final first = _illustrations.first;

    return Flexible(
      fit: FlexFit.tight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IllustrationCard(
            heroTag: first.id,
            illustration: first,
            index: 0,
          ),
        ],
      ),
    );
  }

  Widget userWidget() {
    final String imageUrl = _userFirestore.getProfilePicture();

    return Flexible(
      fit: FlexFit.tight,
      child: SizedBox(
        child: Column(
          children: [
            BetterAvatar(
              image: NetworkImage(imageUrl),
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
                  _userFirestore.bio,
                  style: Utilities.fonts.style(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget userLinks() {
    return Container(
      width: 400.0,
      padding: const EdgeInsets.all(16.0),
      child: UserSocialLinksComponent(
        editMode: false,
        hideEmpty: true,
        socialLinks: _userFirestore.socialLinks,
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

  void fetchData() async {
    await fetchUser();
    fetchBackground();
  }

  /// Fetch user's public illustrations.
  Future<void> fetchBackground() async {
    if (_userFirestore.id.isEmpty) {
      return;
    }

    setState(() {
      _illustrations.clear();
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("illustrations")
          .where("user_id", isEqualTo: _userFirestore.id)
          .where("visibility", isEqualTo: "public")
          .limit(3)
          .get();

      if (snapshot.docs.isEmpty) {
        return;
      }

      for (var doc in snapshot.docs) {
        final data = doc.data();
        data["id"] = doc.id;
        _illustrations.add(Illustration.fromMap(data));
      }

      setState(() {});
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    }
  }

  Future<void> fetchUser() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.userId)
          .collection("user_public_fields")
          .doc("base")
          .get();

      final data = snapshot.data();

      if (!snapshot.exists || data == null) {
        return;
      }

      setState(() {
        data["id"] = widget.userId;
        _userFirestore = UserFirestore.fromMap(data);
      });
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    }
  }
}
