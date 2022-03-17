import 'package:artbooking/components/avatar/better_avatar.dart';
import 'package:artbooking/components/loading_view.dart';
import 'package:artbooking/components/popup_menu/popup_menu_item_icon.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/components/user_social_links_component.dart';
import 'package:artbooking/types/enums/enum_section_action.dart';
import 'package:artbooking/types/section.dart';
import 'package:artbooking/types/user/user_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flash/src/flash_helper.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

/// A section showing user's public information.
/// An optional illustration background can be configured.
class UserSection extends StatefulWidget {
  const UserSection({
    Key? key,
    required this.index,
    required this.section,
    required this.userId,
    this.onPopupMenuItemSelected,
    this.popupMenuEntries = const [],
    this.isLast = false,
    this.usingAsDropTarget = false,
    this.isOwner = false,
  }) : super(key: key);

  final bool isLast;

  /// True if the current authenticated user is the owner.
  final bool isOwner;
  final bool usingAsDropTarget;

  /// Section's position in the layout (e.g. 0 is the first).
  final int index;

  final List<PopupMenuItemIcon<EnumSectionAction>> popupMenuEntries;

  final Section section;
  final String userId;

  final void Function(EnumSectionAction, int, Section)? onPopupMenuItemSelected;

  @override
  State<UserSection> createState() => _UserSectionState();
}

class _UserSectionState extends State<UserSection> {
  bool _loading = false;
  var _userFirestore = UserFirestore.empty();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return LoadingView(
        sliver: false,
        title: Text("loading".tr()),
      );
    }

    final double height = MediaQuery.of(context).size.height - 200.0;

    final EdgeInsets outerPadding =
        widget.usingAsDropTarget ? const EdgeInsets.all(4.0) : EdgeInsets.zero;

    final BoxDecoration boxDecoration = widget.usingAsDropTarget
        ? BoxDecoration(
            borderRadius: BorderRadius.circular(4.0),
            border: Border.all(
              color: Theme.of(context).primaryColor,
              width: 3.0,
            ),
            color: Color(widget.section.backgroundColor),
          )
        : BoxDecoration(
            color: Color(widget.section.backgroundColor),
          );

    return Padding(
      padding: outerPadding,
      child: Stack(
        children: [
          Container(
            decoration: boxDecoration,
            padding: const EdgeInsets.only(
              left: 24.0,
              top: 60.0,
              right: 24.0,
            ),
            child: SizedBox(
              height: height,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  userWidget(),
                ],
              ),
            ),
          ),
          rightPopupMenuButton(),
        ],
      ),
    );
  }

  List<PopupMenuItemIcon<EnumSectionAction>> getPopupMenuEntries() {
    var popupMenuEntries = widget.popupMenuEntries.sublist(0);

    if (widget.index == 0) {
      popupMenuEntries.removeWhere((x) => x.value == EnumSectionAction.moveUp);
    }

    if (widget.isLast) {
      popupMenuEntries.removeWhere(
        (x) => x.value == EnumSectionAction.moveDown,
      );
    }

    popupMenuEntries.removeWhere((x) => x.value == EnumSectionAction.rename);
    popupMenuEntries.removeWhere((x) => x.value == EnumSectionAction.settings);

    popupMenuEntries.add(
      PopupMenuItemIcon(
        icon: Icon(UniconsLine.paint_tool),
        textLabel: "edit_background_color".tr(),
        value: EnumSectionAction.editBackgroundColor,
      ),
    );

    return popupMenuEntries;
  }

  Widget rightPopupMenuButton() {
    if (!widget.isOwner) {
      return Container();
    }

    final popupMenuEntries = getPopupMenuEntries();

    return Positioned(
      top: 12.0,
      right: 12.0,
      child: PopupMenuButton(
        child: Card(
          elevation: 2.0,
          color: Theme.of(context).backgroundColor,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(UniconsLine.ellipsis_h),
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

  void fetchData() async {
    setState(() => _loading = true);
    await fetchUser();
    setState(() => _loading = false);
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
