import 'package:artbooking/components/buttons/dark_elevated_button.dart';
import 'package:artbooking/components/loading_view.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/screens/sections/many/section_card_item.dart';
import 'package:artbooking/types/section.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class SectionsPageBody extends StatelessWidget {
  const SectionsPageBody({
    Key? key,
    required this.sections,
    required this.loading,
    this.onDeleteSection,
    this.onEditSection,
    this.onTapSection,
    this.onCreateSection,
  }) : super(key: key);

  final List<Section> sections;
  final bool loading;
  final Function(Section, int)? onDeleteSection;
  final Function(Section, int)? onEditSection;
  final Function()? onCreateSection;
  final Function(Section, int)? onTapSection;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return LoadingView(
        sliver: true,
        title: Text(
          "sections_loading".tr() + "...",
          style: Utilities.fonts.style(
            fontSize: 32.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    if (sections.isEmpty) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(
          horizontal: 80.0,
          vertical: 69.0,
        ),
        sliver: SliverList(
          delegate: SliverChildListDelegate.fixed([
            Align(
              alignment: Alignment.topLeft,
              child: Opacity(
                opacity: 0.6,
                child: Icon(
                  UniconsLine.no_entry,
                  size: 80.0,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: DarkElevatedButton(
                  onPressed: onCreateSection,
                  child: Text(
                    "section_create".tr(),
                  ),
                ),
              ),
            ),
          ]),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.only(
        top: 42.0,
        left: 34.0,
        right: 30.0,
        bottom: 300.0,
      ),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 280.0,
          mainAxisSpacing: 24.0,
          crossAxisSpacing: 24.0,
          childAspectRatio: 0.9,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final section = sections.elementAt(index);

            return SectionCardItem(
              key: ValueKey(section.id),
              index: index,
              section: section,
              onTap: onTapSection,
              onDelete: onDeleteSection,
              onEdit: onEditSection,
            );
          },
          childCount: sections.length,
        ),
      ),
    );
  }
}
