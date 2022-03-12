import 'package:artbooking/components/animations/fade_in_y.dart';
import 'package:artbooking/components/buttons/dark_elevated_button.dart';
import 'package:artbooking/components/buttons/dark_outlined_button.dart';
import 'package:artbooking/components/cards/separator_shape_card.dart';
import 'package:artbooking/components/dialogs/colors_selector.dart';
import 'package:artbooking/components/dialogs/themed_dialog.dart';
import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/enums/enum_header_separator_tab.dart';
import 'package:artbooking/types/enums/enum_separator_shape.dart';
import 'package:artbooking/types/header_separator.dart';
import 'package:artbooking/types/named_color.dart';
import 'package:artbooking/types/tile_data.dart';
import 'package:beamer/beamer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class HeaderSeparatorDialog extends StatefulWidget {
  const HeaderSeparatorDialog({
    Key? key,
    this.onValidate,
    required this.headerSeparator,
    this.initialTab = EnumHeaderSeparatorTab.color,
  }) : super(key: key);

  final EnumHeaderSeparatorTab initialTab;
  final HeaderSeparator headerSeparator;
  final void Function(HeaderSeparator)? onValidate;

  @override
  State<HeaderSeparatorDialog> createState() => _HeaderSeparatorDialogState();
}

class _HeaderSeparatorDialogState extends State<HeaderSeparatorDialog> {
  var _selectedTab = EnumHeaderSeparatorTab.color;
  var _headerSeparator = HeaderSeparator.empty();

  @override
  void initState() {
    super.initState();
    _headerSeparator = widget.headerSeparator;
    _selectedTab = widget.initialTab;
  }

  @override
  Widget build(BuildContext context) {
    return ThemedDialog(
      useRawDialog: true,
      title: header(),
      body: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: 390.0,
          maxWidth: 400.0,
        ),
        child: body(),
      ),
      textButtonValidation: "save".tr(),
      footer: Material(
        elevation: 0.0,
        color: Constants.colors.clairPink,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.all(12.0),
              child: DarkElevatedButton.large(
                onPressed: _onValidate,
                child: Text("save".tr()),
              ),
            ),
            Tooltip(
              message: "cancel".tr(),
              child: DarkElevatedButton.iconOnly(
                color: Colors.amber,
                onPressed: Beamer.of(context).popRoute,
                child: Icon(UniconsLine.times),
              ),
            ),
          ],
        ),
      ),
      onCancel: Beamer.of(context).popRoute,
      onValidate: _onValidate,
    );
  }

  Widget body() {
    if (_selectedTab == EnumHeaderSeparatorTab.shape) {
      return shapeListWidget();
    }

    return ColorsSelector(
      subtitle: "header_separator_choose_color".tr(),
      selectedColorInt: _headerSeparator.color,
      onTapNamedColor: onTapNamedColor,
      namedColorList: Utilities.ui.getSeparatorColors(),
    );
  }

  Widget header() {
    return Opacity(
      opacity: 0.8,
      child: Column(
        children: [
          Text(
            "header_separator".tr().toUpperCase(),
            style: Utilities.fonts.style(
              color: Colors.black,
              fontWeight: FontWeight.w700,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 12.0,
              right: 12.0,
              top: 12.0,
            ),
            child: Wrap(
              spacing: 12.0,
              children: [
                DarkOutlinedButton(
                  selected: _selectedTab == EnumHeaderSeparatorTab.color,
                  onPressed: () => onPressedTabButton(
                    EnumHeaderSeparatorTab.color,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Icon(UniconsLine.palette),
                      ),
                      Text("color".tr()),
                    ],
                  ),
                ),
                DarkOutlinedButton(
                  selected: _selectedTab == EnumHeaderSeparatorTab.shape,
                  onPressed: () => onPressedTabButton(
                    EnumHeaderSeparatorTab.shape,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Icon(UniconsLine.pentagon),
                      ),
                      Text("shape".tr()),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget shapeListWidget() {
    int index = 0;

    return CustomScrollView(
      slivers: [
        SliverList(
          delegate: SliverChildListDelegate.fixed([
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Opacity(
                opacity: 0.6,
                child: Text(
                  "header_separator_shape_choose".tr(),
                  textAlign: TextAlign.center,
                  style: Utilities.fonts.style(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            Wrap(
              children: [
                TileData<EnumSeparatorShape>(
                  name: "",
                  description: "",
                  iconData: UniconsLine.ban,
                  type: EnumSeparatorShape.none,
                ),
                TileData<EnumSeparatorShape>(
                  name: "",
                  description: "",
                  iconData: UniconsLine.circle,
                  type: EnumSeparatorShape.dot,
                ),
                TileData<EnumSeparatorShape>(
                  name: "",
                  description: "",
                  iconData: UniconsLine.line,
                  type: EnumSeparatorShape.line,
                ),
              ].map((data) {
                index++;
                return FadeInY(
                    beginY: 12.0,
                    delay: Duration(milliseconds: 50 * index),
                    child: shapeTile(data));
              }).toList(),
            ),
          ]),
        )
      ],
    );
  }

  Widget shapeTile(TileData<EnumSeparatorShape> data) {
    final bool selected = _headerSeparator.shape == data.type;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: SeparatorShapeCard(
        selected: selected,
        separatorType: data.type,
        onTap: () {
          setState(() {
            _headerSeparator = _headerSeparator.copyWith(
              separatorType: data.type,
            );
          });
        },
      ),
    );
  }

  void onPressedTabButton(EnumHeaderSeparatorTab selectedTab) {
    setState(() {
      _selectedTab = selectedTab;
    });

    Utilities.storage.saveHeaderSeparatorTab(selectedTab);
  }

  void onTapNamedColor(NamedColor namedColor) {
    setState(() {
      _headerSeparator = _headerSeparator.copyWith(
        color: namedColor.color.value,
      );
    });
  }

  void _onValidate() {
    widget.onValidate?.call(_headerSeparator);
    Beamer.of(context).popRoute();
  }
}
