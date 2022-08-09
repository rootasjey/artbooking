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
    required this.showArtMovementPanel,
    required this.showLicensePanel,
    required this.illustrationVisibility,
    required this.presentationCardKey,
    required this.illustration,
    required this.license,
    required this.illustrationTopics,
    required this.illustrationName,
    required this.illustrationDescription,
    required this.illustrationLore,
    this.isMobileSize = false,
    this.topicInputFocusNode,
    this.goToEditImagePage,
    this.onAddTopicAndUpdate,
    this.onDone,
    this.onExpandStateLicenseChanged,
    this.onRemoveArtMovementAndUpdate,
    this.onRemoveTopicAndUpdate,
    this.onTapCurrentLicense,
    this.onToggleArtMovementPanel,
    this.onToggleLicensePanel,
    this.onUnselectLicenseAndUpdate,
    this.onUpdateVisibility,
    this.onUpdatePresentation,
  }) : super(key: key);

  /// If true, this widget adapts its layout to small screens.
  final bool isMobileSize;

  /// Loading this widget if true.
  final bool loading;

  /// Show panel to select/deselect license if true.
  final bool showLicensePanel;

  /// Show panel to select/deselect art movement if true.
  final bool showArtMovementPanel;

  /// Allow the topic input to request focus.
  final FocusNode? topicInputFocusNode;

  /// Callback to navigate to image edit.
  final void Function()? goToEditImagePage;

  /// Callback fired to add a topic to an illustration.
  final void Function(String topic)? onAddTopicAndUpdate;

  /// Callback fired to remove art movement.
  final void Function(String artMovement)? onRemoveArtMovementAndUpdate;

  /// Callback fired to remove a topic to an illustration.
  final void Function(String topic)? onRemoveTopicAndUpdate;

  /// Callback fired when we tap on a license.
  final void Function()? onTapCurrentLicense;

  /// Callback fired to show/hide the license panel.
  final void Function()? onToggleLicensePanel;

  /// Callback to toggle art movement panel.
  final void Function()? onToggleArtMovementPanel;

  /// Callback fired to unselect a license.
  final void Function()? onUnselectLicenseAndUpdate;

  /// Callback fired when illustration's name, description and/or lore
  /// has changed.
  final void Function(
    String name,
    String description,
    String lore,
  )? onUpdatePresentation;

  /// Callback fired to update illustration's visibility.
  final void Function(EnumContentVisibility)? onUpdateVisibility;

  /// Callback fired when the license section is expanded.
  /// The callback will fetch license's data (from its id).
  final void Function(bool)? onExpandStateLicenseChanged;

  /// Callback fired when we tap on "done" button.
  final void Function()? onDone;

  final GlobalKey<ExpansionTileCardState> presentationCardKey;

  /// Target illustration.
  final Illustration illustration;

  /// Selected license for the target illustration.
  final License license;

  /// Illustration's topics.
  final List<String> illustrationTopics;

  /// Illustration's visibility.
  final EnumContentVisibility illustrationVisibility;

  /// Illustration's name.
  final String illustrationName;

  /// Illustration's description.
  final String illustrationDescription;

  /// Illustration's lore.
  final String illustrationLore;

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
            isMobileSize: isMobileSize,
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
            topicInputFocusNode: topicInputFocusNode,
          ),
          EditIllustrationPageVisibility(
            visibility: illustrationVisibility,
            onUpdateVisibility: onUpdateVisibility,
          ),
          EditIllustrationPageLicense(
            isMobileSize: isMobileSize,
            showLicensesPanel: showLicensePanel,
            license: license,
            onTapCurrentLicense: onTapCurrentLicense,
            onToggleLicensePanel: onToggleLicensePanel,
            onUnselectLicenseAndUpdate: onUnselectLicenseAndUpdate,
            onExpandStateLicenseChanged: onExpandStateLicenseChanged,
          ),
          Padding(
            padding: isMobileSize
                ? const EdgeInsets.only(left: 12.0, top: 0.0)
                : const EdgeInsets.only(left: 12.0, top: 80.0),
            child: Column(
              children: [
                if (isMobileSize)
                  Divider(
                    thickness: 2.0,
                    height: 56.0,
                  ),
                DarkElevatedButton.large(
                  onPressed: onDone,
                  child: Text("done".tr()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
