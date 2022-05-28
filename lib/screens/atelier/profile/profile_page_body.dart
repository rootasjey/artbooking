import 'package:artbooking/components/application_bar/application_bar.dart';
import 'package:artbooking/components/buttons/circle_button.dart';
import 'package:artbooking/components/buttons/dark_elevated_button.dart';
import 'package:artbooking/components/popup_menu/popup_menu_item_icon.dart';
import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/globals/constants/section_ids.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/screens/atelier/profile/section_wrapper.dart';
import 'package:artbooking/types/artistic_page.dart';
import 'package:artbooking/types/enums/enum_section_action.dart';
import 'package:artbooking/types/enums/enum_select_type.dart';
import 'package:artbooking/types/section.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_improved_scrolling/flutter_improved_scrolling.dart';
import 'package:unicons/unicons.dart';

class ProfilePageBody extends StatelessWidget {
  const ProfilePageBody({
    Key? key,
    required this.userId,
    required this.artisticPage,
    this.onPopupMenuItemSelected,
    this.popupMenuEntries = const [],
    this.onAddSection,
    this.isOwner = false,
    this.editMode = false,
    this.onShowAddSection,
    this.onShowIllustrationDialog,
    this.onUpdateSectionItems,
    this.onShowBookDialog,
    this.onDropSection,
    this.showBackButton = false,
    this.onToggleEditMode,
  }) : super(key: key);

  final bool isOwner;
  final bool showBackButton;

  /// If true, the current user is an admin or owner and can add, remove, and edit
  /// this page sections.
  final bool editMode;

  final String userId;
  final ArtisticPage artisticPage;
  final void Function(EnumSectionAction, int, Section)? onPopupMenuItemSelected;
  final List<PopupMenuItemIcon<EnumSectionAction>> popupMenuEntries;

  final void Function(Section)? onAddSection;

  /// Callback when drag and dropping items on this book card.
  final void Function(
    int dropTargetIndex,
    List<int> dragIndexes,
  )? onDropSection;
  final void Function()? onShowAddSection;

  final void Function({
    required Section section,
    required int index,
    required EnumSelectType selectType,
    int maxPick,
  })? onShowIllustrationDialog;

  final void Function({
    required Section section,
    required int index,
    required EnumSelectType selectType,
    int maxPick,
  })? onShowBookDialog;

  final void Function(
    Section section,
    int index,
    List<String> items,
  )? onUpdateSectionItems;

  final void Function()? onToggleEditMode;

  @override
  Widget build(BuildContext context) {
    final bool hasAppBar =
        artisticPage.sections.any((element) => element.id == SectionIds.appBar);

    final List<Widget> slivers = [
      // Sliver issue: https://github.com/flutter/flutter/issues/55170
      SliverToBoxAdapter(),
      if (hasAppBar) ApplicationBar(),
    ];

    int index = -1;
    final scrollController = ScrollController();

    for (var section in artisticPage.sections) {
      index++;
      slivers.add(
        SectionWrapper(
          section: section,
          index: index,
          scrollController: scrollController,
          editMode: editMode,
          sectionCount: artisticPage.sections.length - 1,
          userId: userId,
          onDropSection: onDropSection,
          popupMenuEntries: popupMenuEntries,
          onPopupMenuItemSelected: onPopupMenuItemSelected,
          onUpdateSectionItems: onUpdateSectionItems,
          onShowBookDialog: onShowBookDialog,
          onShowIllustrationDialog: onShowIllustrationDialog,
        ),
      );
    }

    if (isOwner) {
      slivers.add(
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 42.0),
          ),
        ),
      );
    }

    return Scaffold(
      // floatingActionButton: fab(context),
      body: Stack(
        children: [
          ImprovedScrolling(
            scrollController: scrollController,
            enableKeyboardScrolling: true,
            child: CustomScrollView(
              controller: scrollController,
              slivers: slivers,
            ),
          ),
          if (showBackButton)
            Positioned(
              top: 16.0,
              left: 64.0,
              child: CircleButton(
                tooltip: "back".tr(),
                elevation: 2.0,
                backgroundColor: Constants.colors.tertiary,
                onTap: () => Utilities.navigation.back(context),
                icon: Icon(
                  UniconsLine.arrow_left,
                  color: Colors.black,
                ),
              ),
            ),
          if (isOwner)
            Positioned(
              left: 0.0,
              bottom: 0.0,
              right: 0.0,
              child: editPanel(context, scrollController),
            ),
        ],
      ),
    );
  }

  Widget editPanel(BuildContext context, ScrollController scrollController) {
    return Material(
      elevation: 4.0,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
        height: 60.0,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: DarkElevatedButton.iconOnly(
                child: Icon(UniconsLine.arrow_up),
                onPressed: () {
                  scrollController.animateTo(
                    0.0,
                    duration: Duration(milliseconds: 250),
                    curve: Curves.decelerate,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: DarkElevatedButton.icon(
                iconData: UniconsLine.plus,
                labelValue: "Add new section",
                foreground: Theme.of(context).textTheme.bodyText2?.color,
                onPressed: onShowAddSection,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: DarkElevatedButton.icon(
                iconData: editMode ? UniconsLine.pen : UniconsLine.eye,
                labelValue: editMode ? "edit_mode".tr() : "view_mode".tr(),
                foreground: Theme.of(context).textTheme.bodyText2?.color,
                onPressed: onToggleEditMode,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget fab(BuildContext context) {
    if (!isOwner) {
      return Container();
    }

    return FloatingActionButton(
      onPressed: onShowAddSection,
      backgroundColor: Theme.of(context).primaryColor,
      child: Icon(UniconsLine.plus),
    );
  }
}
