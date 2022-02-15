import 'package:artbooking/components/add_art_movement_panel.dart';
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
import 'package:artbooking/types/art_movement/art_movement.dart';
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
    this.goToEditImagePage,
  }) : super(key: key);

  final Illustration illustration;
  final void Function()? goToEditImagePage;

  @override
  _EditIllustrationPageState createState() => _EditIllustrationPageState();
}

class _EditIllustrationPageState extends ConsumerState<EditIllustrationPage> {
  bool _isLoading = false;
  bool _saving = false;
  bool _showArtMovementPanel = false;
  bool _showLicensesPanel = false;

  License _license = License.empty();
  EnumContentVisibility _visibility = EnumContentVisibility.public;
  List<String> _topics = [];

  final GlobalKey<ExpansionTileCardState> _presentationCardKey = GlobalKey();

  final _numberRegex = VerbalExpression()
    ..digit()
    ..oneOrMore();

  /// Illustration's name.
  String _illustrationName = '';

  /// Illustration's descriptin..
  String _illustrationDescription = '';

  /// Illustration's lore..
  String _illustrationLore = '';

  @override
  void initState() {
    super.initState();
    final illustration = widget.illustration;
    _license = illustration.license;
    _visibility = illustration.visibility;
    _topics = illustration.topics;
    _illustrationName = illustration.name;
    _illustrationDescription = illustration.description;
    _illustrationLore = illustration.lore;
  }

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
                    license: _license,
                    illustration: widget.illustration,
                    illustrationName: _illustrationName,
                    illustrationDescription: _illustrationDescription,
                    illustrationLore: _illustrationLore,
                    illustrationTopics: _topics,
                    illustrationVisibility: _visibility,
                    onUpdatePresentation: onUpdatePresentation,
                    onExpandStateLicenseChanged: onExpandStateLicenseChanged,
                    onTapCurrentLicense: onTapCurrentLicense,
                    onToggleLicensePanel: onToggleLicensePanel,
                    onUnselectLicenseAndUpdate: onUnselectLicenseAndUpdate,
                    onToggleArtMovementPanel: onToggleArtMovementPanel,
                    onRemoveArtMovementAndUpdate: onRemoveArtMovementAndUpdate,
                    onAddTopicAndUpdate: onAddTopicAndUpdate,
                    onRemoveTopicAndUpdate: onRemoveTopicAndUpdate,
                    onUpdateVisibility: onUpdateVisibility,
                    onDone: Beamer.of(context).popRoute,
                    presentationCardKey: _presentationCardKey,
                    showLicensesPanel: _showLicensesPanel,
                    showArtMovementPanel: _showArtMovementPanel,
                    goToEditImagePage: widget.goToEditImagePage,
                  )
                ],
              ),
            ),
          ),
          Positioned(
            top: 40.0,
            right: 24.0,
            child: PopupProgressIndicator(
              show: _saving,
              message: '${"illustration_updating".tr()}...',
            ),
          ),
          artMovementsSidePanel(),
          Positioned(
            top: 100.0,
            right: 24.0,
            child: SelectLicensePanel(
              elevation: 8.0,
              isVisible: _showLicensesPanel,
              selectedLicense: _license,
              onClose: () => setState(() => _showLicensesPanel = false),
              onToggleLicenseAndUpdate: onToggleLicenseAndUpdate,
            ),
          ),
        ],
      ),
    );
  }

  Widget artMovementsSidePanel() {
    return Positioned(
      top: 100.0,
      right: 24.0,
      child: AddArtMovementPanel(
        isVisible: _showArtMovementPanel,
        selectedArtMovements: widget.illustration.artMovements,
        onClose: () {
          setState(() => _showArtMovementPanel = false);
        },
        onToggleArtMovementAndUpdate: onToggleArtMovementAndUpdate,
      ),
    );
  }

  void onAddArtMovementsAndUpdate(String artMovementId) async {
    setState(() {
      widget.illustration.artMovements.add(artMovementId);
      _saving = true;
    });

    try {
      final response =
          await Utilities.cloud.illustrations("updateArtMovements").call({
        "illustration_id": widget.illustration.id,
        "art_movements": widget.illustration.artMovements,
      });

      final bool success = response.data["success"];

      if (!success) {
        throw "art_movements_update_fail".tr();
      }
    } on FirebaseFunctionsException catch (error) {
      Utilities.logger.e(error);
      String errorMessage = "art_movements_update_fail".tr();
      final String? nativeErrorMessage = error.message;

      if (error.code == "out-of-range" && nativeErrorMessage != null) {
        final matches = _numberRegex.toRegExp().allMatches(nativeErrorMessage);

        final String numberOfArtMovements =
            matches.last.group(matches.last.groupCount) ?? '0';

        errorMessage = "art_movements_update_out_of_range"
            .tr(args: [numberOfArtMovements]);
      }

      context.showErrorBar(
        content: Text(errorMessage),
      );
    } catch (error) {
      Utilities.logger.e(error);

      setState(() {
        widget.illustration.artMovements.remove(artMovementId);
      });

      context.showErrorBar(
        content: Text("art_movements_update_fail".tr()),
      );
    } finally {
      setState(() => _saving = false);
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

    for (String topic in _topics) {
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
      _saving = true;
      _topics = topicsMap.keys.toList();
    });

    try {
      final response =
          await Utilities.cloud.illustrations("updateTopics").call({
        "illustration_id": widget.illustration.id,
        "topics": _topics,
      });

      final bool success = response.data["success"];

      if (!success) {
        throw "topics_update_fail".tr();
      }
    } on FirebaseFunctionsException catch (error) {
      Utilities.logger.e(error);

      for (String topic in topicsToAdd) {
        _topics.remove(topic);
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
        _topics.remove(topic);
      }

      context.showErrorBar(
        content: Text(error.toString()),
      );
    } finally {
      setState(() => _saving = false);
    }
  }

  DocumentMap getLicenseQuery() {
    if (_license.type == EnumLicenseType.staff) {
      return FirebaseFirestore.instance.collection("licenses").doc(_license.id);
    }

    final String? uid = ref.read(AppState.userProvider).authUser?.uid;

    return FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("user_licenses")
        .doc(_license.id);
  }

  void fetchLicense() async {
    if (_license.id.isEmpty) {
      return;
    }

    try {
      final DocumentSnapshotMap licenseSnap = await getLicenseQuery().get();

      if (!licenseSnap.exists) {
        return;
      }

      final data = licenseSnap.data();
      if (data == null) {
        return;
      }

      data['id'] = licenseSnap.id;

      setState(() {
        final completeLicense = License.fromMap(data);
        _license = completeLicense;
      });
    } catch (error) {
      Utilities.logger.e(error);
    }
  }

  void onExpandStateLicenseChanged(isExpanded) {
    if (!isExpanded) {
      return;
    }

    fetchLicense();
  }

  void onRemoveArtMovementAndUpdate(String artMovementId) async {
    setState(() {
      _saving = true;
      widget.illustration.artMovements.remove(artMovementId);
    });

    try {
      final response =
          await Utilities.cloud.illustrations("updateArtMovements").call({
        "illustration_id": widget.illustration.id,
        "art_movements": widget.illustration.artMovements,
      });

      final bool success = response.data["success"];

      if (!success) {
        throw "art_movements_update_fail".tr();
      }
    } on FirebaseFunctionsException catch (error) {
      Utilities.logger.e(error);

      final String message =
          error.message ?? 'There was an issue while removing art movements.';

      context.showErrorBar(
        content: Text(message),
      );
    } catch (error) {
      Utilities.logger.e(error);
      widget.illustration.artMovements.add(artMovementId);

      context.showErrorBar(
        content: Text("art_movements_update_fail".tr()),
      );
    } finally {
      setState(() => _saving = false);
    }
  }

  void onRemoveTopicAndUpdate(String topic) async {
    setState(() {
      _topics.remove(topic);
      _saving = true;
    });

    try {
      final response =
          await Utilities.cloud.illustrations("updateTopics").call({
        "illustration_id": widget.illustration.id,
        "topics": _topics,
      });

      final bool success = response.data["success"];

      if (!success) {
        throw "topics_update_fail".tr();
      }
    } catch (error) {
      Utilities.logger.e(error);
      _topics.add(topic);

      context.showErrorBar(
        content: Text(error.toString()),
      );
    } finally {
      setState(() => _saving = false);
    }
  }

  void onSelectLicenseAndUpdate(License license) async {
    setState(() => _saving = true);

    final illustration = widget.illustration;
    final previousLicense = illustration.license;
    _license = license;

    try {
      final response =
          await Utilities.cloud.illustrations("updateLicense").call({
        "illustration_id": illustration.id,
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
      setState(() => _saving = false);
    }
  }

  void onToggleArtMovementAndUpdate(ArtMovement artMovement, bool selected) {
    if (selected) {
      onRemoveArtMovementAndUpdate(artMovement.id);
      return;
    }

    onAddArtMovementsAndUpdate(artMovement.id);
  }

  void onTapCurrentLicense() {
    setState(() {
      _showLicensesPanel = !_showLicensesPanel;
    });
  }

  void onToggleArtMovementPanel() {
    setState(() {
      _showArtMovementPanel = !_showArtMovementPanel;
    });
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

  void onToggleLicensePanel() {
    setState(() {
      _showLicensesPanel = !_showLicensesPanel;
    });
  }

  void onUnselectLicenseAndUpdate() async {
    setState(() => _saving = true);

    final License previousLicense = _license.copyWith();
    _license = License.empty();

    try {
      final response =
          await Utilities.cloud.illustrations("unsetLicense").call({
        "illustration_id": widget.illustration.id,
      });

      final bool success = response.data["success"];

      if (!success) {
        throw "license_update_fail".tr();
      }
    } catch (error) {
      Utilities.logger.e(error);
      _license = previousLicense;

      context.showErrorBar(
        content: Text(error.toString()),
      );
    } finally {
      setState(() => _saving = false);
    }
  }

  void onUpdatePresentation(
    String name,
    String description,
    String lore,
  ) async {
    Illustration illustration = widget.illustration;
    final String prevName = illustration.name;
    final String prevDescription = illustration.description;
    final String prevLore = illustration.lore;

    _presentationCardKey.currentState?.collapse();

    setState(() {
      _saving = true;
      _illustrationName = name;
      _illustrationDescription = description;
      _illustrationLore = lore;
    });

    try {
      final HttpsCallableResult response =
          await Utilities.cloud.illustrations("updatePresentation").call({
        "illustration_id": widget.illustration.id,
        "name": name,
        "description": description,
        "lore": lore,
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
        _illustrationName = prevName;
        _illustrationDescription = prevDescription;
        _illustrationLore = prevLore;
      });
    } finally {
      setState(() => _saving = false);
    }
  }

  void onUpdateVisibility(EnumContentVisibility visibility) async {
    final illustration = widget.illustration;
    final EnumContentVisibility previousVisibility = _visibility;

    setState(() {
      _saving = true;
      _visibility = visibility;
    });

    try {
      final HttpsCallableResult response =
          await Utilities.cloud.illustrations("updateVisibility").call({
        "illustration_id": illustration.id,
        "visibility": _visibility.name,
      });

      final bool success = response.data["success"];

      if (!success) {
        throw "illustration_visibility_update_fail".tr();
      }
    } on FirebaseFunctionsException catch (error) {
      Utilities.logger.e(error);
      _visibility = previousVisibility;

      context.showErrorBar(
        content: Text("[${error.code}] ${error.message}"),
      );
    } catch (error) {
      Utilities.logger.e(error);
      _visibility = previousVisibility;

      context.showErrorBar(
        content: Text("illustration_visibility_update_fail".tr()),
      );
    } finally {
      setState(() => _saving = false);
    }
  }
}
