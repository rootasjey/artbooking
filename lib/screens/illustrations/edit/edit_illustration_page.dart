import 'package:artbooking/components/add_style_panel.dart';
import 'package:artbooking/components/popup_progress_indicator.dart';
import 'package:artbooking/components/sheet_header.dart';
import 'package:artbooking/globals/app_state.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/screens/illustrations/edit/edit_illustration_page_body.dart';
import 'package:artbooking/screens/licenses/selection_panel/select_license_panel.dart';
import 'package:artbooking/types/enums/enum_content_visibility.dart';
import 'package:artbooking/types/enums/enum_license_type.dart';
import 'package:artbooking/types/firestore/document_map.dart';
import 'package:artbooking/types/firestore/document_snapshot_map.dart';
import 'package:artbooking/types/illustration/illustration.dart';
import 'package:artbooking/types/license/license.dart';
import 'package:artbooking/types/art_style/art_style.dart';
import 'package:beamer/beamer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flash/src/flash_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verbal_expressions/verbal_expressions.dart';

class EditIllustrationPage extends ConsumerStatefulWidget {
  const EditIllustrationPage({
    Key? key,
    required this.illustration,
  }) : super(key: key);

  final Illustration illustration;

  @override
  _EditIllustrationPageState createState() => _EditIllustrationPageState();
}

class _EditIllustrationPageState extends ConsumerState<EditIllustrationPage> {
  bool _isLoading = false;
  bool _isSaving = false;
  bool _showStylesPanel = false;
  bool _showLicensesPanel = false;

  final GlobalKey<ExpansionTileCardState> _presentationCardKey = GlobalKey();

  final _numberRegex = VerbalExpression()
    ..digit()
    ..oneOrMore();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(60.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SheetHeader(
                    title: "illustration_name_metadata".tr(
                      args: [
                        widget.illustration.name,
                      ],
                    ),
                    tooltip: "close".tr(),
                    subtitle: "illustration_metadata_description".tr(),
                    bottom: Opacity(
                      opacity: 0.7,
                      child: Text(
                        "card_click_to_expand".tr(),
                        style: Utilities.fonts.style(
                          color: Theme.of(context).secondaryHeaderColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  EditIllustrationPageBody(
                    isLoading: _isLoading,
                    illustration: widget.illustration,
                    presentationCardKey: _presentationCardKey,
                    showLicensesPanel: _showLicensesPanel,
                    showStylesPanel: _showStylesPanel,
                    onUpdatePresentation: onUpdatePresentation,
                    onExpandStateLicenseChanged: onExpandStateLicenseChanged,
                    onTapCurrentLicense: onTapCurrentLicense,
                    onToggleLicensePanel: onToggleLicensePanel,
                    onUnselectLicenseAndUpdate: onUnselectLicenseAndUpdate,
                    onToggleStylesPanel: onToggleStylesPanel,
                    onRemoveStyleAndUpdate: onRemoveStyleAndUpdate,
                    onAddTopicAndUpdate: onAddTopicAndUpdate,
                    onRemoveTopicAndUpdate: onRemoveTopicAndUpdate,
                    onUpdateVisibility: onUpdateVisibility,
                    onDone: Beamer.of(context).popRoute,
                  )
                ],
              ),
            ),
          ),
          Positioned(
            top: 40.0,
            right: 24.0,
            child: PopupProgressIndicator(
              show: _isSaving,
              message: '${"illustration_updating".tr()}...',
            ),
          ),
          stylesSidePanel(),
          Positioned(
            top: 100.0,
            right: 24.0,
            child: SelectLicensePanel(
              elevation: 8.0,
              isVisible: _showLicensesPanel,
              selectedLicense: widget.illustration.license,
              onClose: () => setState(() => _showLicensesPanel = false),
              onToggleLicenseAndUpdate: onToggleLicenseAndUpdate,
            ),
          ),
        ],
      ),
    );
  }

  Widget stylesSidePanel() {
    return Positioned(
      top: 100.0,
      right: 24.0,
      child: AddStylePanel(
        isVisible: _showStylesPanel,
        selectedStyles: widget.illustration.styles,
        onClose: () {
          setState(() => _showStylesPanel = false);
        },
        onToggleStyleAndUpdate: onToggleStyleAndUpdate,
      ),
    );
  }

  void onAddStyleAndUpdate(String styleName) async {
    setState(() {
      widget.illustration.styles.add(styleName);
      _isSaving = true;
    });

    try {
      final response =
          await Utilities.cloud.illustrations("updateStyles").call({
        "illustrationId": widget.illustration.id,
        "styles": widget.illustration.styles,
      });

      final bool success = response.data["success"];

      if (!success) {
        throw "styles_update_fail".tr();
      }
    } on FirebaseFunctionsException catch (error) {
      Utilities.logger.e(error);
      String errorMessage = "styles_update_fail".tr();

      if (error.code == "out-of-range") {
        final matches = _numberRegex.toRegExp().allMatches(error.message!);

        final String? numberOfStyles =
            matches.last.group(matches.last.groupCount);

        errorMessage = "styles_update_out_of_range".tr(args: [numberOfStyles!]);
      }

      context.showErrorBar(
        content: Text(errorMessage),
      );
    } catch (error) {
      Utilities.logger.e(error);

      setState(() {
        widget.illustration.styles.remove(styleName);
      });

      context.showErrorBar(
        content: Text("styles_update_fail".tr()),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void onAddTopicAndUpdate(String topicString) async {
    if (topicString.isEmpty) {
      context.showErrorBar(
        content: Text("input_empty_invalid".tr()),
      );

      return;
    }

    bool hasNewValues = false;
    final topicsToAdd = topicString.split(",");
    final topicsMap = Map<String, bool>();

    for (String topic in widget.illustration.topics) {
      topicsMap[topic] = true;
    }

    for (String topic in topicsToAdd) {
      if (!topicsMap.containsKey(topic)) {
        hasNewValues = true;
      }

      topicsMap[topic] = true;
    }

    if (!hasNewValues) {
      return;
    }

    setState(() {
      _isSaving = true;
      widget.illustration.topics = topicsMap.keys.toList();
    });

    try {
      final response =
          await Utilities.cloud.illustrations("updateTopics").call({
        "illustrationId": widget.illustration.id,
        "topics": topicsMap.keys.toList(),
      });

      final bool success = response.data["success"];

      if (!success) {
        throw "topics_update_fail".tr();
      }
    } on FirebaseFunctionsException catch (error) {
      Utilities.logger.e(error);

      for (String topic in topicsToAdd) {
        widget.illustration.topics.remove(topic);
      }

      String errorMessage = error.message ??
          'There was an issue while adding topics to your illustration.';

      if (error.code == "out-of-range") {
        final matches = _numberRegex.toRegExp().allMatches(error.message!);

        final String? numberOfTopics =
            matches.last.group(matches.last.groupCount);

        errorMessage = "topics_update_out_of_range".tr(args: [numberOfTopics!]);
      }

      context.showErrorBar(
        content: Text(errorMessage),
      );
    } catch (error) {
      Utilities.logger.e(error);

      for (String topic in topicsToAdd) {
        widget.illustration.topics.remove(topic);
      }

      context.showErrorBar(
        content: Text(error.toString()),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  DocumentMap getLicenseQuery() {
    final License license = widget.illustration.license;

    if (license.type == EnumLicenseType.staff) {
      return FirebaseFirestore.instance.collection("licenses").doc(license.id);
    }

    final String? uid = ref.read(AppState.userProvider).authUser?.uid;

    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection("licenses")
        .doc(license.id);
  }

  void fetchLicense() async {
    final License license = widget.illustration.license;

    if (license.id.isEmpty) {
      return;
    }

    try {
      final DocumentSnapshotMap licenseSnap = await getLicenseQuery().get();

      if (!licenseSnap.exists) {
        return;
      }

      final data = licenseSnap.data()!;
      data['id'] = licenseSnap.id;

      setState(() {
        final completeLicense = License.fromJSON(data);
        widget.illustration.license = completeLicense;
      });
    } catch (error) {
      Utilities.logger.e(error);
    }
  }

  void onRemoveStyleAndUpdate(String styleName) async {
    setState(() {
      _isSaving = true;
      widget.illustration.styles.remove(styleName);
    });

    try {
      final response =
          await Utilities.cloud.illustrations("updateStyles").call({
        "illustrationId": widget.illustration.id,
        "styles": widget.illustration.styles,
      });

      final bool success = response.data["success"];

      if (!success) {
        throw "styles_update_fail".tr();
      }
    } on FirebaseFunctionsException catch (error) {
      Utilities.logger.e(error);

      final String message =
          error.message ?? 'There was an issue while removing styles.';

      context.showErrorBar(
        content: Text(message),
      );
    } catch (error) {
      Utilities.logger.e(error);
      widget.illustration.styles.add(styleName);

      context.showErrorBar(
        content: Text("styles_update_fail".tr()),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void onRemoveTopicAndUpdate(String topic) async {
    setState(() {
      widget.illustration.topics.remove(topic);
      _isSaving = true;
    });

    try {
      final response =
          await Utilities.cloud.illustrations("updateTopics").call({
        "illustrationId": widget.illustration.id,
        "topics": widget.illustration.topics,
      });

      final bool success = response.data["success"];

      if (!success) {
        throw "topics_update_fail".tr();
      }
    } catch (error) {
      Utilities.logger.e(error);
      widget.illustration.topics.add(topic);

      context.showErrorBar(
        content: Text(error.toString()),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void onToggleLicenseAndUpdate(
    License license,
    bool selected,
  ) async {
    if (selected) {
      onUnselectLicenseAndUpdate();
      return;
    }

    onSelectLicenseAndUpdate(license);
    setState(() => _showLicensesPanel = false);
  }

  void onSelectLicenseAndUpdate(License license) async {
    setState(() => _isSaving = true);

    final illustration = widget.illustration;
    final previousLicense = illustration.license;
    illustration.license = license;

    try {
      final response =
          await Utilities.cloud.illustrations("updateLicense").call({
        "illustrationId": illustration.id,
        "license": {
          "id": license.id,
          "type": license.typeToString(),
        },
      });

      final bool success = response.data["success"];

      if (!success) {
        throw "license_update_fail".tr();
      }
    } catch (error) {
      context.showErrorBar(
        content: Text(error.toString()),
      );

      license = previousLicense;

      context.showErrorBar(
        content: Text(error.toString()),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void onUnselectLicenseAndUpdate() async {
    setState(() => _isSaving = true);

    final illustration = widget.illustration;
    final previousLicense = illustration.license;
    illustration.license = License.empty();

    try {
      final response =
          await Utilities.cloud.illustrations("unsetLicense").call({
        "illustrationId": illustration.id,
      });

      final bool success = response.data["success"];

      if (!success) {
        throw "license_update_fail".tr();
      }
    } catch (error) {
      Utilities.logger.e(error);

      illustration.license = previousLicense;

      context.showErrorBar(
        content: Text(error.toString()),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void onUpdatePresentation(
    String name,
    String description,
    String story,
  ) async {
    final Illustration illustration = widget.illustration;
    final String prevName = illustration.name;
    final String prevDescription = illustration.description;
    final String prevStory = illustration.story;

    _presentationCardKey.currentState?.collapse();

    setState(() {
      _isSaving = true;
      illustration.name = name;
      illustration.description = description;
      illustration.story = story;
    });

    try {
      final HttpsCallableResult response =
          await Utilities.cloud.illustrations("updatePresentation").call({
        "illustrationId": widget.illustration.id,
        "name": name,
        "description": description,
        "story": story,
      });

      final bool success = response.data['success'];

      if (!success) {
        throw "The operation couldn't succeed.";
      }
    } catch (error) {
      Utilities.logger.e(error);

      context.showErrorBar(
        content: Text("project_update_title_fail".tr()),
      );

      _presentationCardKey.currentState?.expand();

      setState(() {
        illustration.name = prevName;
        illustration.description = prevDescription;
        illustration.story = prevStory;
      });
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void onToggleStyleAndUpdate(ArtStyle style, bool selected) {
    if (selected) {
      onRemoveStyleAndUpdate(style.name);
      return;
    }

    onAddStyleAndUpdate(style.name);
  }

  void onUpdateVisibility(EnumContentVisibility visibility) async {
    final illustration = widget.illustration;
    final EnumContentVisibility previousVisibility =
        widget.illustration.visibility;

    setState(() {
      _isSaving = true;
      illustration.visibility = visibility;
    });

    try {
      final HttpsCallableResult response =
          await Utilities.cloud.illustrations("updateVisibility").call({
        "illustrationId": illustration.id,
        "visibility": illustration.visibilityToString(),
      });

      final bool success = response.data["success"];

      if (!success) {
        throw "illustration_visibility_update_fail".tr();
      }
    } on FirebaseFunctionsException catch (error) {
      Utilities.logger.e(error);
      illustration.visibility = previousVisibility;

      context.showErrorBar(
        content: Text("[${error.code}] ${error.message}"),
      );
    } catch (error) {
      Utilities.logger.e(error);
      illustration.visibility = previousVisibility;

      context.showErrorBar(
        content: Text("illustration_visibility_update_fail".tr()),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void onTapCurrentLicense() {
    setState(() {
      _showLicensesPanel = !_showLicensesPanel;
    });
  }

  void onExpandStateLicenseChanged(isExpanded) {
    if (!isExpanded) {
      return;
    }

    fetchLicense();
  }

  void onToggleLicensePanel() {
    setState(() {
      _showLicensesPanel = !_showLicensesPanel;
    });
  }

  void onToggleStylesPanel() {
    setState(() {
      _showStylesPanel = !_showStylesPanel;
    });
  }
}
