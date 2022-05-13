import 'package:artbooking/components/animations/fade_in_y.dart';
import 'package:artbooking/components/cards/color_card.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/named_color.dart';
import 'package:flutter/material.dart';

class ColorsSelector extends StatelessWidget {
  const ColorsSelector({
    Key? key,
    this.onTapNamedColor,
    required this.selectedColorInt,
    this.subtitle = "",
    this.namedColorList = const [],
  }) : super(key: key);

  final void Function(NamedColor namedColor)? onTapNamedColor;
  final int selectedColorInt;
  final String subtitle;
  final List<NamedColor> namedColorList;

  @override
  Widget build(BuildContext context) {
    int index = 0;

    final _namedColorList = namedColorList.isNotEmpty
        ? namedColorList
        : Utilities.ui.getBackgroundSectionColors();

    return CustomScrollView(
      slivers: [
        SliverList(
          delegate: SliverChildListDelegate.fixed([
            if (subtitle.isNotEmpty)
              Opacity(
                opacity: 0.6,
                child: Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: Utilities.fonts.body(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            Padding(
                padding: const EdgeInsets.all(12.0),
                child: Wrap(
                  spacing: 12.0,
                  runSpacing: 12.0,
                  alignment: WrapAlignment.center,
                  children: _namedColorList.map((NamedColor namedColor) {
                    index++;

                    final bool selected =
                        selectedColorInt == namedColor.color.value;
                    final Color primaryColor = Theme.of(context).primaryColor;
                    final BorderSide borderSide = selected
                        ? BorderSide(color: primaryColor, width: 2.0)
                        : BorderSide.none;

                    return FadeInY(
                      beginY: 12.0,
                      delay: Duration(milliseconds: 50 * index),
                      child: ColorCard(
                        borderSide: borderSide,
                        namedColor: namedColor,
                        selected: selected,
                        onTap: onTapNamedColor,
                      ),
                    );
                  }).toList(),
                )),
          ]),
        ),
      ],
    );
  }
}
