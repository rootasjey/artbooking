import 'package:artbooking/components/buttons/dark_elevated_button.dart';
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

class EditIllustrationPageBody extends StatelessWidget {
  const EditIllustrationPageBody({
    Key? key,
    required this.isLoading,
    required this.illustration,
    required this.illustrationName,
    required this.illustrationDescription,
    required this.illustrationLore,
    required this.illustrationTopics,
    required this.illustrationVisibility,
    required this.license,
    required this.presentationCardKey,
    required this.showArtMovementPanel,
    required this.showLicensesPanel,
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
  }) : super(key: key);

  final bool isLoading;
  final bool showLicensesPanel;
  final bool showArtMovementPanel;

  final GlobalKey<ExpansionTileCardState> presentationCardKey;
  final Illustration illustration;
  final License license;

  final String illustrationName;
  final String illustrationDescription;
  final String illustrationLore;
  final List<String> illustrationTopics;
  final EnumContentVisibility illustrationVisibility;

  final void Function(String, String, String)? onUpdatePresentation;

  final void Function()? onToggleArtMovementPanel;
  final void Function(String)? onRemoveArtMovementAndUpdate;

  final void Function(String)? onAddTopicAndUpdate;
  final void Function(String)? onRemoveTopicAndUpdate;

  final void Function(EnumContentVisibility)? onUpdateVisibility;

  final void Function()? onTapCurrentLicense;
  final void Function()? onToggleLicensePanel;
  final void Function()? onUnselectLicenseAndUpdate;
  final void Function(bool)? onExpandStateLicenseChanged;

  final void Function()? onDone;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
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
      padding: EdgeInsets.only(top: 90.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
            showLicensesPanel: showLicensesPanel,
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
