import 'package:artbooking/components/buttons/section_illustration_buttons.dart';
import 'package:artbooking/components/cards/illustration_card.dart';
import 'package:artbooking/components/popup_menu/popup_menu_item_icon.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/screens/atelier/profile/popup_menu_button_section.dart';
import 'package:artbooking/types/enums/enum_section_action.dart';
import 'package:artbooking/types/enums/enum_select_type.dart';
import 'package:artbooking/types/illustration/illustration.dart';
import 'package:artbooking/types/json_types.dart';
import 'package:artbooking/types/section.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flash/flash.dart';
import 'package:flutter/material.dart';

class PosterSection extends StatefulWidget {
  const PosterSection({
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
  State<PosterSection> createState() => _PosterSectionState();
}

class _PosterSectionState extends State<PosterSection> {
  bool _loading = false;
  var _illustration = Illustration.empty();

  @override
  void initState() {
    super.initState();
    fetchChosenIllustration();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    checkData();

    if (_illustration.id.isEmpty) {
      return Stack(
        children: [
          Container(
            width: size.width,
            height: size.height,
            padding: const EdgeInsets.all(16.0),
            child: IllustrationCard(
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

    return Stack(
      children: [
        Container(
          width: size.width,
          height: size.height,
          child: Image.network(
            _illustration.getHDThumbnail(),
            width: size.width,
            height: size.height,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          right: 24.0,
          bottom: 24.0,
          child: SectionIllustrationButtons(
            onRemoveIllustration: onRemoveIllustration,
            onPickIllustration: onPickIllustration,
          ),
        ),
        rightPopupMenuButton(),
      ],
    );
  }

  List<PopupMenuItemIcon<EnumSectionAction>> getPopupMenuEntries() {
    final popupMenuEntries = widget.popupMenuEntries.sublist(0);

    if (widget.index == 0) {
      popupMenuEntries.removeWhere((x) => x.value == EnumSectionAction.moveUp);
    }

    if (widget.isLast) {
      popupMenuEntries.removeWhere(
        (x) => x.value == EnumSectionAction.moveDown,
      );
    }

    return popupMenuEntries;
  }

  Widget rightPopupMenuButton() {
    if (!widget.isHover) {
      return Container();
    }

    if (!widget.editMode) {
      return Container();
    }

    return PopupMenuButtonSection(
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
}
