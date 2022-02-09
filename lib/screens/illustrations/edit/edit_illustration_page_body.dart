import 'package:artbooking/components/buttons/dark_elevated_button.dart';
import 'package:artbooking/components/loading_view.dart';
import 'package:artbooking/screens/illustrations/edit/edit_illustration_page_license.dart';
import 'package:artbooking/screens/illustrations/edit/edit_illustration_page_presentation.dart';
import 'package:artbooking/screens/illustrations/edit/edit_illustration_page_styles.dart';
import 'package:artbooking/screens/illustrations/edit/edit_illustration_page_topics.dart';
import 'package:artbooking/screens/illustrations/edit/edit_illustration_page_visibility.dart';
import 'package:artbooking/types/enums/enum_content_visibility.dart';
import 'package:artbooking/types/illustration/illustration.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';

class EditIllustrationPageBody extends StatelessWidget {
  const EditIllustrationPageBody({
    Key? key,
    required this.isLoading,
    required this.illustration,
    required this.presentationCardKey,
    required this.showLicensesPanel,
    required this.showStylesPanel,
    this.onUpdatePresentation,
    this.onToggleStylesPanel,
    this.onRemoveStyleAndUpdate,
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
  final bool showStylesPanel;

  final GlobalKey<ExpansionTileCardState> presentationCardKey;
  final Illustration illustration;

  final void Function(String, String, String)? onUpdatePresentation;

  final void Function()? onToggleStylesPanel;
  final void Function(String)? onRemoveStyleAndUpdate;

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
            illustration: illustration,
            onUpdatePresentation: onUpdatePresentation,
          ),
          EditIllustrationPageStyles(
            selectedStyles: illustration.artMovements,
            showStylesPanel: showStylesPanel,
            onRemoveStyleAndUpdate: onRemoveStyleAndUpdate,
            onToggleStylesPanel: onToggleStylesPanel,
          ),
          EditIllustrationPageTopics(
            topics: illustration.topics,
            onAddTopicAndUpdate: onAddTopicAndUpdate,
            onRemoveTopicAndUpdate: onAddTopicAndUpdate,
          ),
          EditIllustrationPageVisibility(
            visibilityValue: illustration.visibilityToString(),
            onUpdateVisibility: onUpdateVisibility,
          ),
          EditIllustrationPageLicense(
            showLicensesPanel: showLicensesPanel,
            license: illustration.license,
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
