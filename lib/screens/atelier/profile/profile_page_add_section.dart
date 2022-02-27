import 'package:artbooking/components/buttons/dark_text_button.dart';
import 'package:artbooking/components/square/square_section_button.dart';
import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/globals/constants/section_ids.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/section.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flash/src/flash_helper.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class ProfilePageAddSection extends StatefulWidget {
  const ProfilePageAddSection({
    Key? key,
    this.onAddSection,
  }) : super(key: key);

  final void Function(Section)? onAddSection;

  @override
  _ProfilePageAddSectionState createState() => _ProfilePageAddSectionState();
}

class _ProfilePageAddSectionState extends State<ProfilePageAddSection> {
  /// True if the user is selecting which section to add.
  bool _selectionMode = false;
  List<Section> _sections = [];

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Card(
          color: Constants.colors.clairPink,
          child: _selectionMode ? selectionView() : initialView(),
        ),
      ),
    );
  }

  Widget initialView() {
    return InkWell(
      onTap: () {
        setState(() {
          _selectionMode = true;
        });

        fetchSections();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Opacity(
              opacity: 0.6,
              child: Text(
                "Add a new section",
                style: Utilities.fonts.style(
                  fontSize: 24.0,
                ),
              ),
            ),
            Opacity(
              opacity: 0.4,
              child: Text(
                "This section will be added to your profile page",
                style: Utilities.fonts.style(
                  fontSize: 16.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget selectionView() {
    return Column(
      children: [
        DarkTextButton(
          onPressed: () {
            setState(() {
              _selectionMode = false;
            });
          },
          child: Opacity(
            opacity: 0.6,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(UniconsLine.times),
                Text("Close"),
              ],
            ),
          ),
        ),
        Divider(),
        Opacity(
          opacity: 0.4,
          child: Text(
            "Choose a new section to add to your profile page",
            style: Utilities.fonts.style(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 32.0),
          child: Wrap(
            spacing: 12.0,
            runSpacing: 12.0,
            children: _sections.map((section) {
              return SquareSectionButton(
                iconData: getIconData(section),
                iconColor: getIconColor(section),
                textValue: section.name,
                onTap: () {
                  widget.onAddSection?.call(section);
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Color getIconColor(Section section) {
    switch (section.id) {
      case SectionIds.bookGrid:
        return Constants.colors.books;
      case SectionIds.illustrationGrid:
        return Constants.colors.illustrations;
      case SectionIds.userWithArtworks:
        return Colors.teal;
      default:
        return Colors.pink;
    }
  }

  IconData getIconData(Section section) {
    switch (section.id) {
      case SectionIds.bookGrid:
        return UniconsLine.book;
      case SectionIds.illustrationGrid:
        return UniconsLine.picture;
      case SectionIds.userWithArtworks:
        return UniconsLine.user;
      default:
        return UniconsLine.question;
    }
  }

  void fetchSections() async {
    _sections.clear();

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("sections")
          .limit(10)
          .get();

      if (snapshot.size == 0) {
        return;
      }

      for (var doc in snapshot.docs) {
        final map = doc.data();
        map["id"] = doc.id;
        _sections.add(Section.fromMap(map));
      }

      setState(() {});
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    }
  }
}
