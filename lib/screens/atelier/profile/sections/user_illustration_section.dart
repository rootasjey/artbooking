import 'package:artbooking/components/avatar/better_avatar.dart';
import 'package:artbooking/components/buttons/section_illustration_buttons.dart';
import 'package:artbooking/components/cards/illustration_card.dart';
import 'package:artbooking/components/user_social_links_component.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/router/navigation_state_helper.dart';
import 'package:artbooking/screens/atelier/profile/popup_menu_button_section.dart';
import 'package:artbooking/types/enums/enum_section_action.dart';
import 'package:artbooking/types/enums/enum_section_data_mode.dart';
import 'package:artbooking/types/enums/enum_select_type.dart';
import 'package:artbooking/types/illustration/illustration.dart';
import 'package:artbooking/types/json_types.dart';
import 'package:artbooking/types/popup_item_section.dart';
import 'package:artbooking/types/section.dart';
import 'package:artbooking/types/user/user_firestore.dart';
import 'package:beamer/beamer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flash/src/flash_helper.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

/// A section showing user's public information with
/// a group of 4 illustrations on the left.
class UserIllustrationSection extends StatefulWidget {
  const UserIllustrationSection({
    Key? key,
    required this.userId,
    this.onPopupMenuItemSelected,
    this.popupMenuEntries = const [],
    required this.index,
    required this.section,
    this.isLast = false,
    this.onShowIllustrationDialog,
    this.onUpdateSectionItems,
    this.usingAsDropTarget = false,
    this.editMode = false,
    this.isHover = false,
  }) : super(key: key);

  /// If true, the current authenticated user is the owner and
  /// this section can be edited.
  final bool editMode;
  final bool isLast;
  final bool isHover;

  final bool usingAsDropTarget;

  final String userId;
  final List<PopupMenuItemSection> popupMenuEntries;

  final void Function(EnumSectionAction, int, Section)? onPopupMenuItemSelected;
  final void Function({
    required Section section,
    required int index,
    required EnumSelectType selectType,
    int maxPick,
  })? onShowIllustrationDialog;

  final void Function(
    Section section,
    int index,
    List<String> items,
  )? onUpdateSectionItems;

  /// Section's position in the layout (e.g. 0 is the first).
  final int index;
  final Section section;

  @override
  State<UserIllustrationSection> createState() =>
      _UserIllustrationSectionState();
}

class _UserIllustrationSectionState extends State<UserIllustrationSection> {
  bool _loading = false;

  var _userFirestore = UserFirestore.empty();
  Illustration _illustration = Illustration.empty();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;

    checkData();

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

    return Stack(
      children: [
        Padding(
          padding: outerPadding,
          child: Container(
            decoration: boxDecoration,
            child: SizedBox(
              height: height,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  illustrationWidget(),
                  userWidget(),
                ],
              ),
            ),
          ),
        ),
        rightPopupMenuButton(),
      ],
    );
  }

  List<PopupMenuItemSection> getPopupMenuEntries() {
    final List<PopupMenuItemSection> popupMenuEntries =
        widget.popupMenuEntries.sublist(0);

    if (widget.index == 0) {
      popupMenuEntries.removeWhere((x) => x.value == EnumSectionAction.moveUp);
    }

    if (widget.isLast) {
      popupMenuEntries.removeWhere(
        (x) => x.value == EnumSectionAction.moveDown,
      );
    }

    popupMenuEntries.removeWhere((x) => x.value == EnumSectionAction.rename);
    return popupMenuEntries;
  }

  Widget illustrationWidget() {
    if (_illustration.id.isEmpty) {
      return Expanded(
        child: IllustrationCard(
          borderRadius: BorderRadius.circular(16.0),
          useAsPlaceholder: true,
          heroTag: DateTime.now().toString(),
          illustration: Illustration.empty(),
          index: 0,
          onTap: onPickIllustration,
        ),
      );
    }

    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
              _illustration.getHDThumbnail(),
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            InkWell(
              onTap: () {
                NavigationStateHelper.illustration = _illustration;
                Beamer.of(context, root: true).beamToNamed(
                  "illustrations/${_illustration.id}",
                  data: {
                    "illustrationId": _illustration.id,
                  },
                );
              },
            ),
            Positioned(
              right: 24.0,
              bottom: 24.0,
              child: SectionIllustrationButtons(
                onRemoveIllustration: onRemoveIllustration,
                onPickIllustration: onPickIllustration,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget rightPopupMenuButton() {
    if (!widget.editMode) {
      return Container();
    }

    return PopupMenuButtonSection(
      show: widget.isHover,
      itemBuilder: (_) => getPopupMenuEntries(),
      onSelected: (EnumSectionAction action) {
        widget.onPopupMenuItemSelected?.call(
          action,
          widget.index,
          widget.section,
        );
      },
    );
  }

  Widget userWidget() {
    final String imageUrl = _userFirestore.getProfilePicture();

    return Flexible(
      fit: FlexFit.tight,
      child: Material(
        elevation: 2.0,
        color: Color(widget.section.backgroundColor),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
                  style: Utilities.fonts.body(
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
                      style: Utilities.fonts.body(
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
                    style: Utilities.fonts.body(),
                  ),
                ),
              ),
            ],
          ),
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

  /// There may be a better way to handle new data.
  void checkData() {
    if (_loading) {
      return;
    }

    final items = widget.section.items;

    if (items.isEmpty) {
      if (_illustration.id.isNotEmpty) {
        setState(() {
          _illustration = Illustration.empty();
        });
      }
      return;
    }

    if (_illustration.id != items.first) {
      _illustration = _illustration.copyWith(
        id: items.first,
      );

      fetchIllustration();
    }
  }

  void fetchData() async {
    await fetchUser();
    await fetchIllustration();
  }

  Future<void> fetchIllustration() async {
    _loading = true;
    if (widget.section.dataFetchMode == EnumSectionDataMode.chosen) {
      await fetchChosenIllustration();
      _loading = false;
      return;
    }

    await fetchSyncIllustrations();
    _loading = false;
  }

  Future<void> fetchChosenIllustration() async {
    if (widget.section.items.isEmpty) {
      return;
    }

    final String illustrationId = widget.section.items.first;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("illustrations")
          .doc(illustrationId)
          .get();

      final Json? data = snapshot.data();

      if (!snapshot.exists || data == null) {
        return;
      }

      setState(() {
        data["id"] = snapshot.id;
        _illustration = Illustration.fromMap(data);
      });
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    }
  }

  /// Fetch user's public illustrations.
  Future<void> fetchSyncIllustrations() async {
    if (_userFirestore.id.isEmpty) {
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("illustrations")
          .where("user_id", isEqualTo: _userFirestore.id)
          .where("visibility", isEqualTo: "public")
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return;
      }

      for (var doc in snapshot.docs) {
        final data = doc.data();
        data["id"] = doc.id;
        _illustration = Illustration.fromMap(data);
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

  void onPickIllustration() {
    widget.onShowIllustrationDialog?.call(
      section: widget.section,
      index: widget.index,
      selectType: EnumSelectType.replace,
      maxPick: 1,
    );
  }

  void onRemoveIllustration() {
    widget.onUpdateSectionItems?.call(
      widget.section,
      widget.index,
      [],
    );
  }
}
