import 'package:artbooking/components/popup_menu/popup_menu_item_icon.dart';
import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/enums/enum_section_item_action.dart';
import 'package:artbooking/types/section.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:unicons/unicons.dart';

class SectionCardItem extends StatefulWidget {
  const SectionCardItem({
    Key? key,
    required this.section,
    required this.index,
    this.isWide = false,
    this.useBottomSheet = false,
    this.margin = EdgeInsets.zero,
    this.onDelete,
    this.onEdit,
    this.onTap,
    this.onPopupMenuItemSelected,
    this.popupMenuEntries = const [],
  }) : super(key: key);

  /// If true, the card will have a wide layout.
  final bool isWide;

  /// If true, a bottom sheet will be displayed on long press event.
  /// Setting this property to true will deactivate popup menu and
  /// hide like button.
  final bool useBottomSheet;

  /// Outer space of this widget.
  final EdgeInsets margin;

  /// Position of this item.
  final int index;

  /// onDelete callback function (after selecting 'delete' item menu)
  final void Function(Section, int)? onDelete;

  /// onEdit callback function (after selecting 'edit' item menu)
  final void Function(Section, int)? onEdit;

  /// Callback fired after tapping this card.
  final void Function(Section, int)? onTap;

  /// Callback fired when one of the popup menu item entries is selected.
  final void Function(
    EnumSectionItemAction action,
    Section section,
    int index,
  )? onPopupMenuItemSelected;

  /// Menu item list displayed after tapping on the corresponding popup button.
  final List<PopupMenuItemIcon<EnumSectionItemAction>> popupMenuEntries;

  /// Main data representing a section.
  final Section section;

  @override
  State<SectionCardItem> createState() => _SectionCardItemState();
}

class _SectionCardItemState extends State<SectionCardItem> {
  /// Display popup menu if true.
  /// Because we only show popup menu on hover.
  bool _showPopupMenu = false;

  /// Card's border color.
  Color _borderColor = Colors.pink;

  /// Card's title background color.
  Color _textBgColor = Colors.transparent;

  /// Card's elevation.
  double _elevation = 2.0;

  /// Card's border width.
  double _borderWidth = 2.0;

  @override
  Widget build(BuildContext context) {
    final Section section = widget.section;

    if (_borderColor == Colors.pink) {
      _borderColor = Theme.of(context).primaryColor.withOpacity(0.6);
    }

    if (widget.isWide) {
      return Container(
        width: 260.0,
        padding: widget.margin,
        child: Card(
          elevation: _elevation,
          color: Theme.of(context).backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6.0),
            side: BorderSide(
              color: _borderColor,
              width: _borderWidth,
            ),
          ),
          child: InkWell(
            onLongPress:
                widget.useBottomSheet ? () => onLongPress(context) : null,
            onTap: () => widget.onTap?.call(widget.section, widget.index),
            onHover: (isHover) {
              setState(() {
                _elevation = isHover ? 4.0 : 2.0;
                _borderColor = isHover
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).primaryColor.withOpacity(0.6);
                _borderWidth = isHover ? 3.0 : 2.0;
                _textBgColor = isHover ? Colors.amber : Colors.transparent;
                _showPopupMenu = isHover;
              });
            },
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Opacity(
                          opacity: 0.6,
                          child: Icon(
                            Utilities.ui.getSectionIcon(section.id),
                            size: 24.0,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Hero(
                              tag: section.id,
                              child: Opacity(
                                opacity: 0.8,
                                child: Text(
                                  "section_name.${section.id}".tr(),
                                  maxLines: 2,
                                  style: Utilities.fonts.body(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w600,
                                    backgroundColor: _textBgColor,
                                  ),
                                ),
                              ),
                            ),
                            Opacity(
                              opacity: 0.4,
                              child: Text(
                                "section_description.${section.id}".tr(),
                                maxLines: 5,
                                style: Utilities.fonts.body(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                popupMenuButton(),
              ],
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: 260.0,
      height: 300.0,
      child: Card(
        elevation: _elevation,
        color: Theme.of(context).backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6.0),
          side: BorderSide(
            color: _borderColor,
            width: _borderWidth,
          ),
        ),
        child: InkWell(
          onTap: () => widget.onTap?.call(widget.section, widget.index),
          onHover: (isHover) {
            setState(() {
              _elevation = isHover ? 4.0 : 2.0;
              _borderColor = isHover
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).primaryColor.withOpacity(0.6);
              _borderWidth = isHover ? 3.0 : 2.0;
              _textBgColor = isHover ? Colors.amber : Colors.transparent;
              _showPopupMenu = isHover;
            });
          },
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Opacity(
                        opacity: 0.6,
                        child: Icon(
                          Utilities.ui.getSectionIcon(section.id),
                          size: 32.0,
                        ),
                      ),
                    ),
                    Hero(
                      tag: section.id,
                      child: Opacity(
                        opacity: 0.8,
                        child: Text(
                          "section_name.${section.id}".tr(),
                          maxLines: 2,
                          style: Utilities.fonts.body(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w800,
                            backgroundColor: _textBgColor,
                          ),
                        ),
                      ),
                    ),
                    Opacity(
                      opacity: 0.4,
                      child: Text(
                        "section_description.${section.id}".tr(),
                        maxLines: 5,
                        textAlign: TextAlign.center,
                        style: Utilities.fonts.body(
                          fontSize: 15.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              popupMenuButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget popupMenuButton() {
    if (widget.popupMenuEntries.isEmpty || widget.useBottomSheet) {
      return Container();
    }

    return Positioned(
      top: 10.0,
      right: 10.0,
      child: Opacity(
        opacity: _showPopupMenu ? 1.0 : 0.0,
        child: PopupMenuButton(
          child: CircleAvatar(
            radius: 15.0,
            backgroundColor: Constants.colors.clairPink,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Icon(UniconsLine.ellipsis_h, size: 20),
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6.0),
          ),
          onSelected: (EnumSectionItemAction action) {
            widget.onPopupMenuItemSelected?.call(
              action,
              widget.section,
              widget.index,
            );
          },
          itemBuilder: (_) => widget.popupMenuEntries,
        ),
      ),
    );
  }

  void onLongPress(BuildContext context) {
    showCupertinoModalBottomSheet(
      context: context,
      expand: false,
      backgroundColor: Colors.white70,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Material(
            borderRadius: BorderRadius.circular(8.0),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: widget.popupMenuEntries.map(
                  (PopupMenuItemIcon<EnumSectionItemAction> popupMenuEntry) {
                    return ListTile(
                      title: Opacity(
                        opacity: 0.8,
                        child: Text(
                          popupMenuEntry.textLabel,
                          style: Utilities.fonts.body(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      trailing: popupMenuEntry.icon,
                      onTap: () {
                        Navigator.of(context).pop();
                        final EnumSectionItemAction? action =
                            popupMenuEntry.value;

                        if (action == null) {
                          return;
                        }

                        widget.onPopupMenuItemSelected?.call(
                          action,
                          widget.section,
                          widget.index,
                        );
                      },
                    );
                  },
                ).toList(),
              ),
            ),
          ),
        );
      },
    );
  }
}
