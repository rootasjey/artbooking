import 'package:artbooking/components/dialogs/themed_dialog.dart';
import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/named_color.dart';
import 'package:artbooking/types/section.dart';
import 'package:beamer/beamer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class SectionSettingsDialog extends StatelessWidget {
  const SectionSettingsDialog({
    Key? key,
    this.onValidate,
    required this.section,
    required this.index,
  }) : super(key: key);

  final void Function(NamedColor, Section, int)? onValidate;
  final Section section;
  final int index;

  @override
  Widget build(BuildContext context) {
    return ThemedDialog(
      useRawDialog: true,
      title: Opacity(
        opacity: 0.8,
        child: Column(
          children: [
            Text(
              "section_configure".tr().toUpperCase(),
              style: Utilities.fonts.style(
                color: Colors.black,
                fontWeight: FontWeight.w700,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Opacity(
                opacity: 0.4,
                child: Text(
                  "section_configure_subtitle".tr(),
                  textAlign: TextAlign.center,
                  style: Utilities.fonts.style(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: 390.0,
          maxWidth: 400.0,
        ),
        child: CustomScrollView(
          slivers: [
            SliverList(
              delegate: SliverChildListDelegate.fixed([
                Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Wrap(
                      spacing: 12.0,
                      runSpacing: 12.0,
                      alignment: WrapAlignment.center,
                      children: [
                        NamedColor(
                          name: "Clair Pink",
                          color: Constants.colors.clairPink,
                        ),
                        NamedColor(
                          name: "Light Blue",
                          color: Constants.colors.lightBackground,
                        ),
                        NamedColor(
                          name: "Blue 100",
                          color: Colors.blue.shade100,
                        ),
                        NamedColor(
                          name: "Green 100",
                          color: Colors.green.shade100,
                        ),
                        NamedColor(
                          name: "Lime 100",
                          color: Colors.lime.shade100,
                        ),
                        NamedColor(
                          name: "Amber 100",
                          color: Colors.amber.shade100,
                        ),
                        NamedColor(
                          name: "Yellow 100",
                          color: Colors.yellow.shade100,
                        ),
                        NamedColor(
                          name: "Black 26",
                          color: Colors.black26,
                        ),
                        NamedColor(
                          name: "Deep Orange 100",
                          color: Colors.deepOrange.shade100,
                        ),
                        NamedColor(
                          name: "Orange 100",
                          color: Colors.orange.shade100,
                        ),
                        NamedColor(
                          name: "Red 100",
                          color: Colors.red.shade100,
                        ),
                        NamedColor(
                          name: "Pink 100",
                          color: Colors.pink.shade100,
                        ),
                        NamedColor(
                          name: "Deep Purple 100",
                          color: Colors.deepPurple.shade100,
                        ),
                        NamedColor(
                          name: "Purple 100",
                          color: Colors.purple.shade100,
                        ),
                        NamedColor(
                          name: "Indigo 100",
                          color: Colors.indigo.shade100,
                        ),
                        NamedColor(
                          name: "Grey 100",
                          color: Colors.grey.shade100,
                        ),
                        NamedColor(
                          name: "White 54",
                          color: Colors.white54,
                        ),
                      ].map((NamedColor namedColor) {
                        return colorCard(
                          namedColor,
                          context,
                        );
                      }).toList(),
                    )),
              ]),
            ),
          ],
        ),
      ),
      textButtonValidation: "close".tr(),
      onCancel: Beamer.of(context).popRoute,
      onValidate: Beamer.of(context).popRoute,
    );
  }

  Widget colorCard(NamedColor namedColor, BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 100.0,
          height: 100.0,
          child: Card(
            color: namedColor.color,
            child: InkWell(
              onTap: () {
                onValidate?.call(namedColor, section, index);
                Beamer.of(context).popRoute();
              },
            ),
          ),
        ),
        Opacity(
          opacity: 0.7,
          child: Text(
            namedColor.name,
            style: Utilities.fonts.style(
              fontWeight: FontWeight.w600,
              fontSize: 14.0,
            ),
          ),
        ),
      ],
    );
  }
}
