import 'package:artbooking/components/buttons/dark_elevated_button.dart';
import 'package:artbooking/components/buttons/text_rectangle_button.dart';
import 'package:artbooking/components/loading_view.dart';
import 'package:artbooking/screens/illustrations/edit/edit_illustration_page_license.dart';
import 'package:artbooking/screens/illustrations/edit/edit_illustration_page_presentation.dart';
import 'package:artbooking/screens/illustrations/edit/edit_illustration_page_art_movements.dart';
import 'package:artbooking/screens/illustrations/edit/edit_illustration_page_topics.dart';
import 'package:artbooking/screens/illustrations/edit/edit_illustration_page_visibility.dart';
import 'package:artbooking/types/enums/enum_content_visibility.dart';
import 'package:artbooking/types/illustration/illustration.dart';
import 'package:artbooking/types/license/license.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class EditIllustrationPageBody extends StatelessWidget {
  const EditIllustrationPageBody({
    Key? key,
    required this.loading,
    required this.illustration,
    required this.illustrationName,
    required this.illustrationDescription,
    required this.illustrationLore,
    required this.illustrationTopics,
    required this.illustrationVisibility,
    required this.license,
    required this.presentationCardKey,
    required this.showArtMovementPanel,
    required this.showLicensePanel,
    this.onUpdatePresentation,
    this.onToggleArtMovementPanel,
    this.onRemoveArtMovementAndUpdate,
    this.onAddTopicAndUpdate,
    this.onRemoveTopicAndUpdate,
    this.onUpdateVisibility,
    this.onTapCurrentLicense,
    this.onToggleLicensePanel,
    this.onUnselectLicenseAndUpdate,
    this.onDone,
    this.onExpandStateLicenseChanged,
    this.goToEditImagePage,
  }) : super(key: key);

  /// Loading this widget if true.
  final bool loading;

  /// Show panel to select/deselect license if true.
  final bool showLicensePanel;

  /// Show panel to select/deselect art movement if true.
  final bool showArtMovementPanel;

  final GlobalKey<ExpansionTileCardState> presentationCardKey;

  /// Target illustration.
  final Illustration illustration;

  /// Selected license for the target illustration.
  final License license;

  /// Illustration's name.
  final String illustrationName;

  /// Illustration's description.
  final String illustrationDescription;

  /// Illustration's lore.
  final String illustrationLore;

  /// Illustration's topics.
  final List<String> illustrationTopics;

  /// Illustration's visibility.
  final EnumContentVisibility illustrationVisibility;

  /// Callback to navigate to image edit.
  final void Function()? goToEditImagePage;

  /// Callback fired to update illustration's presentation.
  final void Function(String, String, String)? onUpdatePresentation;

  /// Callback to toggle art movement panel.
  final void Function()? onToggleArtMovementPanel;

  /// Callback fired to remove art movement.
  final void Function(String)? onRemoveArtMovementAndUpdate;

  /// Callback fired to add a topic to an illustration.
  final void Function(String)? onAddTopicAndUpdate;

  /// Callback fired to remove a topic to an illustration.
  final void Function(String)? onRemoveTopicAndUpdate;

  /// Callback fired to update illustration's visibility.
  final void Function(EnumContentVisibility)? onUpdateVisibility;

  /// Callback fired when we tap on a license.
  final void Function()? onTapCurrentLicense;

  /// Callback fired to show/hide the license panel.
  final void Function()? onToggleLicensePanel;

  /// Callback fired to unselect a license.
  final void Function()? onUnselectLicenseAndUpdate;

  /// Callback fired when the license section is expanded.
  /// The callback will fetch license's data (from its id).
  final void Function(bool)? onExpandStateLicenseChanged;

  /// Callback fired when we tap on "done" button.
  final void Function()? onDone;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return LoadingView(
        sliver: false,
        title: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Opacity(
            opacity: 0.6,
            child: Text("loading".tr()),
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(top: 70.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20.0, bottom: 32.0),
            child: TextRectangleButton(
              onPressed: goToEditImagePage,
              primary: Theme.of(context)
                  .textTheme
                  .bodyText2
                  ?.color
                  ?.withOpacity(0.6),
              icon: Icon(UniconsLine.image_edit),
              label: Text("edit_image".tr()),
            ),
          ),
          EditIllustrationPagePresentation(
            cardKey: presentationCardKey,
            name: illustrationName,
            description: illustrationDescription,
            lore: illustrationLore,
            onUpdatePresentation: onUpdatePresentation,
          ),
          EditIllustrationPageArtMovements(
            selectedArtMovements: illustration.artMovements,
            showArtMovementPanel: showArtMovementPanel,
            onRemoveArtMovementAndUpdate: onRemoveArtMovementAndUpdate,
            onToggleArtMovementPanel: onToggleArtMovementPanel,
          ),
          EditIllustrationPageTopics(
            topics: illustrationTopics,
            onAddTopicAndUpdate: onAddTopicAndUpdate,
            onRemoveTopicAndUpdate: onRemoveTopicAndUpdate,
          ),
          EditIllustrationPageVisibility(
            visibility: illustrationVisibility,
            onUpdateVisibility: onUpdateVisibility,
          ),
          EditIllustrationPageLicense(
            showLicensesPanel: showLicensePanel,
            license: license,
            onTapCurrentLicense: onTapCurrentLicense,
            onToggleLicensePanel: onToggleLicensePanel,
            onUnselectLicenseAndUpdate: onUnselectLicenseAndUpdate,
            onExpandStateLicenseChanged: onExpandStateLicenseChanged,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 80.0),
            child: DarkElevatedButton.large(
              onPressed: onDone,
              child: Text("done".tr()),
            ),
          ),
        ],
      ),
    );
  }
}
