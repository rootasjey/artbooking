import 'package:artbooking/components/buttons/section_illustration_buttons.dart';
import 'package:artbooking/components/cards/illustration_card.dart';
import 'package:artbooking/components/popup_menu/popup_menu_icon.dart';
import 'package:artbooking/components/popup_menu/popup_menu_item_icon.dart';
import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/router/locations/home_location.dart';
import 'package:artbooking/screens/atelier/profile/popup_menu_button_section.dart';
import 'package:artbooking/types/enums/enum_section_action.dart';
import 'package:artbooking/types/enums/enum_select_type.dart';
import 'package:artbooking/types/illustration/illustration.dart';
import 'package:artbooking/types/json_types.dart';
import 'package:artbooking/types/popup_item_section.dart';
import 'package:artbooking/types/section.dart';
import 'package:artbooking/types/user/user_firestore.dart';
import 'package:beamer/beamer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class BorderedPosterSection extends StatefulWidget {
  const BorderedPosterSection({
    Key? key,
    required this.index,
    required this.section,
    this.isLast = false,
    this.usingAsDropTarget = false,
    this.popupMenuEntries = const [],
    this.onPopupMenuItemSelected,
    this.onShowIllustrationDialog,
    this.onUpdateSectionItems,
    this.editMode = false,
    this.isHover = false,
  }) : super(key: key);

  /// If true, the current authenticated user is the owner and
  /// this section can be edited.
  final bool editMode;
  final bool isHover;
  final bool isLast;

  final bool usingAsDropTarget;

  final List<PopupMenuItemIcon<EnumSectionAction>> popupMenuEntries;

  /// Section's position in the layout (e.g. 0 is the first).
  final int index;

  final Section section;

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

  @override
  State<BorderedPosterSection> createState() => _BorderedPosterSectionState();
}

class _BorderedPosterSectionState extends State<BorderedPosterSection> {
  bool _loading = false;
  var _illustration = Illustration.empty();

  /// Illustration's owner.
  var _user = UserFirestore.empty();

  @override
  void initState() {
    super.initState();
    fetch();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    checkData();

    final bool isMobileSize = size.width <= Utilities.size.mobileWidthTreshold;

    if (_illustration.id.isEmpty) {
      return Stack(
        children: [
          Container(
            width: size.width,
            height: isMobileSize ? size.width : size.height,
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(side: BorderSide()),
            ),
            padding: const EdgeInsets.all(16.0),
            child: IllustrationCard(
              borderRadius: BorderRadius.circular(16.0),
              useAsPlaceholder: true,
              heroTag: DateTime.now().toString(),
              illustration: Illustration.empty(),
              index: 0,
              onTap: onPickIllustration,
            ),
          ),
          rightPopupMenuButton(),
        ],
      );
    }

    final String heroTag = "${widget.section.id}-${_illustration.id}";
    final double space = isMobileSize ? 12.0 : 80.0;
    final double height =
        isMobileSize ? (size.width - space) : (size.height - space);

    return Container(
      color: Color(widget.section.backgroundColor),
      child: Stack(
        children: [
          Center(
            child: Container(
              width: size.width - space,
              height: height,
              padding: const EdgeInsets.only(
                top: 54.0,
              ),
              color: Color(widget.section.backgroundColor),
              child: Container(
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6.0),
                    side: BorderSide(
                      width: 6.0,
                      color: Color(widget.section.borderColor),
                    ),
                  ),
                ),
                child: Stack(
                  children: [
                    Hero(
                      tag: heroTag,
                      child: Card(
                        elevation: 12.0,
                        margin: const EdgeInsets.all(8.0),
                        clipBehavior: Clip.hardEdge,
                        color: Constants.colors.clairPink,
                        child: Ink.image(
                          image: NetworkImage(
                            _illustration.getHDThumbnail(),
                          ),
                          width: size.width,
                          height: size.height,
                          fit: BoxFit.cover,
                          child: InkWell(
                            onTap: () => onTapIllustration(heroTag),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 24.0,
                      left: 24.0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            " ${_illustration.name} ",
                            style: Utilities.fonts.body(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              backgroundColor: Colors.black26,
                            ),
                          ),
                          InkWell(
                            onTap: () => onTapUser(_user),
                            child: Text(
                              " ${'made_by'.tr().toLowerCase()} ${_user.name} ",
                              style: Utilities.fonts.body(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                backgroundColor: Colors.black26,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (widget.editMode)
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
            ),
          ),
          rightPopupMenuButton(),
        ],
      ),
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

    popupMenuEntries.add(
      PopupMenuItemIcon(
        icon: PopupMenuIcon(UniconsLine.border_out),
        textLabel: "border_color_edit".tr(),
        value: EnumSectionAction.editBorderColor,
        delay: Duration(milliseconds: popupMenuEntries.length * 25),
      ),
    );

    return popupMenuEntries;
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

      fetchChosenIllustration();
    }
  }

  void fetch() async {
    await fetchChosenIllustration();
    fetchAuthor();
  }

  /// Fetch author from Firestore doc public data (fast).
  Future<bool> fetchAuthor() async {
    if (_illustration.userId.isEmpty) {
      return false;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(_illustration.userId)
          .collection("user_public_fields")
          .doc("base")
          .get();

      final Json? data = snapshot.data();

      if (!snapshot.exists || data == null) {
        return false;
      }

      setState(() {
        data["id"] = _illustration.userId;
        _user = UserFirestore.fromMap(data);
      });

      return true;
    } catch (error) {
      Utilities.logger.e(error);
      return false;
    }
  }

  Future<void> fetchChosenIllustration() async {
    if (widget.section.items.isEmpty) {
      return;
    }

    _loading = true;
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
    } finally {
      _loading = false;
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

  void onTapUser(UserFirestore userFirestore) {
    final String route =
        HomeLocation.profileRoute.replaceFirst(":userId", userFirestore.id);

    Beamer.of(context).beamToNamed(
      route,
      data: {"userId": userFirestore.id},
    );
  }

  void onTapIllustration(String heroTag) {
    Utilities.navigation.profileToIllustration(
      context,
      illustration: _illustration,
      heroTag: heroTag,
      userId: _illustration.userId,
    );
  }
}
