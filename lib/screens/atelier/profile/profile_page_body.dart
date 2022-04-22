import 'package:artbooking/components/application_bar/application_bar.dart';
import 'package:artbooking/components/buttons/circle_button.dart';
import 'package:artbooking/components/popup_menu/popup_menu_item_icon.dart';
import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/globals/constants/section_ids.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/screens/atelier/profile/sections/book_grid_section.dart';
import 'package:artbooking/screens/atelier/profile/sections/bordered_poster_section.dart';
import 'package:artbooking/screens/atelier/profile/sections/featured_artists_section.dart';
import 'package:artbooking/screens/atelier/profile/sections/h1_section.dart';
import 'package:artbooking/screens/atelier/profile/sections/h4_section.dart';
import 'package:artbooking/screens/atelier/profile/sections/illustration_row_section.dart';
import 'package:artbooking/screens/atelier/profile/sections/illustration_window_section.dart';
import 'package:artbooking/screens/atelier/profile/sections/poster_section.dart';
import 'package:artbooking/screens/atelier/profile/sections/spacing_section.dart';
import 'package:artbooking/screens/atelier/profile/sections/title_description_section.dart';
import 'package:artbooking/screens/atelier/profile/sections/user_illustration_section.dart';
import 'package:artbooking/screens/atelier/profile/sections/user_section.dart';
import 'package:artbooking/screens/atelier/profile/sections/illustration_grid_section.dart';
import 'package:artbooking/types/artistic_page.dart';
import 'package:artbooking/types/drag_data.dart';
import 'package:artbooking/types/enums/enum_section_action.dart';
import 'package:artbooking/types/enums/enum_select_type.dart';
import 'package:artbooking/types/section.dart';
import 'package:dotted_border/dotted_border.dart';
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
    this.onShowAddSection,
    this.onShowIllustrationDialog,
    this.onUpdateSectionItems,
    this.onShowBookDialog,
    this.onDropSection,
    this.showBackButton = false,
  }) : super(key: key);

  final bool isOwner;
  final bool showBackButton;
  final String userId;
  final ArtisticPage artisticPage;
  final void Function(EnumSectionAction, int, Section)? onPopupMenuItemSelected;
  final List<PopupMenuItemIcon<EnumSectionAction>> popupMenuEntries;

  final void Function(Section)? onAddSection;

  /// Callback when drag and dropping items on this book card.
  final void Function(int dropTargetIndex, List<int> dragIndexes)?
      onDropSection;
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
        sectionWrapper(
          section: section,
          index: index,
          context: context,
          scrollController: scrollController,
        ),
      );
    }

    if (isOwner) {
      slivers.add(newSectionButton(context));
    }

    return Scaffold(
      floatingActionButton: fab(context),
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
        ],
      ),
    );
  }

  Widget newSectionButton(BuildContext context) {
    return SliverToBoxAdapter(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 32.0,
          ),
          child: DottedBorder(
            strokeWidth: 3.0,
            borderType: BorderType.RRect,
            radius: Radius.circular(8),
            color: Theme.of(context).primaryColor.withOpacity(0.6),
            dashPattern: [8, 4],
            child: InkWell(
              onTap: onShowAddSection,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
                child: Opacity(
                  opacity: 0.6,
                  child: Text(
                    "section_add_new".tr(),
                    style: Utilities.fonts.style(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
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

  Widget getSectionWidget({
    required Section section,
    required int index,
    bool usingAsDropTarget = false,
  }) {
    if (section.id == SectionIds.user) {
      return UserSection(
        index: index,
        section: section,
        userId: userId,
        isOwner: isOwner,
        usingAsDropTarget: usingAsDropTarget,
        onPopupMenuItemSelected: onPopupMenuItemSelected,
        popupMenuEntries: popupMenuEntries,
        isLast: index == artisticPage.sections.length - 1,
      );
    }

    if (section.id == SectionIds.illustrationGrid) {
      return IllustrationGridSection(
        index: index,
        section: section,
        userId: userId,
        isOwner: isOwner,
        usingAsDropTarget: usingAsDropTarget,
        onPopupMenuItemSelected: onPopupMenuItemSelected,
        popupMenuEntries: popupMenuEntries,
        isLast: index == artisticPage.sections.length - 1,
        onShowIllustrationDialog: onShowIllustrationDialog,
        onUpdateSectionItems: onUpdateSectionItems,
      );
    }

    if (section.id == SectionIds.bookGrid) {
      return BookGridSection(
        index: index,
        section: section,
        userId: userId,
        isOwner: isOwner,
        usingAsDropTarget: usingAsDropTarget,
        isLast: index == artisticPage.sections.length - 1,
        onPopupMenuItemSelected: onPopupMenuItemSelected,
        popupMenuEntries: popupMenuEntries,
        onUpdateSectionItems: onUpdateSectionItems,
        onShowBookDialog: onShowBookDialog,
      );
    }

    if (section.id == SectionIds.userWithIllustration) {
      return UserIllustrationSection(
        index: index,
        section: section,
        userId: userId,
        isOwner: isOwner,
        usingAsDropTarget: usingAsDropTarget,
        isLast: index == artisticPage.sections.length - 1,
        onPopupMenuItemSelected: onPopupMenuItemSelected,
        onShowIllustrationDialog: onShowIllustrationDialog,
        popupMenuEntries: popupMenuEntries,
        onUpdateSectionItems: onUpdateSectionItems,
      );
    }

    if (section.id == SectionIds.borderedPoster) {
      return BorderedPosterSection(
        index: index,
        section: section,
        isOwner: isOwner,
        usingAsDropTarget: usingAsDropTarget,
        isLast: index == artisticPage.sections.length - 1,
        onPopupMenuItemSelected: onPopupMenuItemSelected,
        onShowIllustrationDialog: onShowIllustrationDialog,
        popupMenuEntries: popupMenuEntries,
        onUpdateSectionItems: onUpdateSectionItems,
      );
    }

    if (section.id == SectionIds.poster) {
      return PosterSection(
        index: index,
        section: section,
        isOwner: isOwner,
        usingAsDropTarget: usingAsDropTarget,
        isLast: index == artisticPage.sections.length - 1,
        onPopupMenuItemSelected: onPopupMenuItemSelected,
        onShowIllustrationDialog: onShowIllustrationDialog,
        popupMenuEntries: popupMenuEntries,
        onUpdateSectionItems: onUpdateSectionItems,
      );
    }

    if (section.id == SectionIds.illustrationRow) {
      return IllustrationRowSection(
        index: index,
        section: section,
        userId: userId,
        isOwner: isOwner,
        usingAsDropTarget: usingAsDropTarget,
        isLast: index == artisticPage.sections.length - 1,
        onPopupMenuItemSelected: onPopupMenuItemSelected,
        onShowIllustrationDialog: onShowIllustrationDialog,
        popupMenuEntries: popupMenuEntries,
        onUpdateSectionItems: onUpdateSectionItems,
      );
    }

    if (section.id == SectionIds.spacing) {
      return SpacingSection(
        index: index,
        section: section,
        isOwner: isOwner,
        usingAsDropTarget: usingAsDropTarget,
        isLast: index == artisticPage.sections.length - 1,
        onPopupMenuItemSelected: onPopupMenuItemSelected,
        popupMenuEntries: popupMenuEntries,
      );
    }

    if (section.id == SectionIds.h1) {
      return H1Section(
        index: index,
        section: section,
        isOwner: isOwner,
        usingAsDropTarget: usingAsDropTarget,
        isLast: index == artisticPage.sections.length - 1,
        onPopupMenuItemSelected: onPopupMenuItemSelected,
        popupMenuEntries: popupMenuEntries,
      );
    }

    if (section.id == SectionIds.h4) {
      return H4Section(
        index: index,
        section: section,
        isOwner: isOwner,
        usingAsDropTarget: usingAsDropTarget,
        isLast: index == artisticPage.sections.length - 1,
        onPopupMenuItemSelected: onPopupMenuItemSelected,
        popupMenuEntries: popupMenuEntries,
      );
    }

    if (section.id == SectionIds.titleDescription) {
      return TitleDescriptionSection(
        index: index,
        section: section,
        isOwner: isOwner,
        usingAsDropTarget: usingAsDropTarget,
        isLast: index == artisticPage.sections.length - 1,
        onPopupMenuItemSelected: onPopupMenuItemSelected,
        popupMenuEntries: popupMenuEntries,
      );
    }

    if (section.id == SectionIds.illustrationWindow) {
      return IllustrationWindowSection(
        index: index,
        section: section,
        userId: userId,
        isOwner: isOwner,
        usingAsDropTarget: usingAsDropTarget,
        isLast: index == artisticPage.sections.length - 1,
        onShowIllustrationDialog: onShowIllustrationDialog,
        popupMenuEntries: popupMenuEntries,
        onPopupMenuItemSelected: onPopupMenuItemSelected,
      );
    }

    if (section.id == SectionIds.featuredArtist) {
      return FeaturedArtistsSection(
        index: index,
        section: section,
        userId: userId,
        isOwner: isOwner,
        usingAsDropTarget: usingAsDropTarget,
        isLast: index == artisticPage.sections.length - 1,
        onShowIllustrationDialog: onShowIllustrationDialog,
        popupMenuEntries: popupMenuEntries,
        onPopupMenuItemSelected: onPopupMenuItemSelected,
      );
    }

    return Container();
  }

  String getDraggableName(Section section) {
    String name = section.name;
    if (name.isEmpty) {
      name = "section_name.${section.id}".tr();
    }

    return name;
  }

  Widget sectionWrapper({
    required Section section,
    required int index,
    required BuildContext context,
    required ScrollController scrollController,
  }) {
    if (!isOwner) {
      return SliverToBoxAdapter(
        child: getSectionWidget(
          section: section,
          index: index,
        ),
      );
    }

    return SliverToBoxAdapter(
      child: Stack(
        children: [
          DragTarget<DragData>(
            builder: (BuildContext context, candidateItems, rejectedItems) {
              return getSectionWidget(
                section: section,
                index: index,
                usingAsDropTarget: candidateItems.isNotEmpty,
              );
            },
            onAccept: (DragData dragData) {
              onDropSection?.call(index, [dragData.index]);
            },
            onWillAccept: (DragData? dragData) {
              if (dragData == null) {
                return false;
              }

              if (dragData.type != Section) {
                return false;
              }

              return true;
            },
          ),
          Positioned(
            top: 12.0,
            left: 12.0,
            child: Draggable<DragData>(
              data: DragData(
                index: index,
                groupName: "profile-page",
                type: Section,
              ),
              onDragUpdate: (details) => onDragUpdateSection(
                context: context,
                details: details,
                scrollController: scrollController,
              ),
              feedback: Card(
                elevation: 2.0,
                color: Constants.colors.clairPink,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 4.0),
                        child: Icon(Utilities.ui.getSectionIcon(section.id)),
                      ),
                      Text(
                        getDraggableName(section),
                        style: Utilities.fonts.style(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              child: Card(
                elevation: 2.0,
                color: Constants.colors.clairPink,
                child: InkWell(
                  onTap: () {},
                  onLongPress: () {},
                  child: Tooltip(
                    message: "drag_to_move".tr(),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(UniconsLine.draggabledots),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void onDragUpdateSection({
    required BuildContext context,
    required DragUpdateDetails details,
    required ScrollController scrollController,
  }) async {
    /// Amount of offset to jump when dragging an element to the edge.
    final double jumpOffset = 200.0;

    /// Distance to the edge where the scroll viewer starts to jump.
    final double edgeDistance = 50.0;

    final position = details.globalPosition;

    if (position.dy < edgeDistance) {
      if (scrollController.offset <= 0) {
        return;
      }

      await scrollController.animateTo(
        scrollController.offset - jumpOffset,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );

      return;
    }

    final windowHeight = MediaQuery.of(context).size.height;
    if (windowHeight - edgeDistance < position.dy) {
      if (scrollController.position.atEdge && scrollController.offset != 0) {
        return;
      }

      await scrollController.animateTo(
        scrollController.offset + jumpOffset,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }
}
