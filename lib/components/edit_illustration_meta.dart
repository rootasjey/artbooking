import 'package:artbooking/components/add_style_panel.dart';
import 'package:artbooking/components/dark_elevated_button.dart';
import 'package:artbooking/components/loading_view.dart';
import 'package:artbooking/components/select_license_panel.dart';
import 'package:artbooking/components/sheet_header.dart';
import 'package:artbooking/state/colors.dart';
import 'package:artbooking/types/enums.dart';
import 'package:artbooking/types/illustration/illustration.dart';
import 'package:artbooking/types/illustration/license.dart';
import 'package:artbooking/types/style.dart';
import 'package:artbooking/utils/app_logger.dart';
import 'package:artbooking/utils/cloud_helper.dart';
import 'package:artbooking/utils/fonts.dart';
import 'package:artbooking/utils/snack.dart';
import 'package:beamer/beamer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';
import 'package:verbal_expressions/verbal_expressions.dart';

class EditIllustrationMeta extends StatefulWidget {
  final Illustration? illustration;

  const EditIllustrationMeta({
    Key? key,
    required this.illustration,
  }) : super(key: key);

  @override
  _EditIllustrationMetaState createState() => _EditIllustrationMetaState();
}

class _EditIllustrationMetaState extends State<EditIllustrationMeta> {
  bool _isLoading = false;
  bool _isSaving = false;
  bool _isSidePanelStylesVisible = false;
  bool _isSidePanelLicenseVisible = false;

  bool _isEditingExistingLink = false;

  late DocumentSnapshot _illustrationSnapshot;

  final _descriptionTextController = TextEditingController();
  final _topicsTextController = TextEditingController();
  final _storyTextController = TextEditingController();
  final _nameTextController = TextEditingController();
  final _linkNameInputController = TextEditingController();
  final _linkValueInputController = TextEditingController();

  /// Illustration's selected art styles.
  final List<String?> _selectedStyles = [];

  final _programmingLanguages = Map<String, bool>();
  final _topics = Map<String, bool>();
  final _links = Map<String, String>();

  final GlobalKey<ExpansionTileCardState> _presentationCard = GlobalKey();

  final _numberRegex = VerbalExpression()
    ..digit()
    ..oneOrMore();

  String _editingExistingLinkName = '';
  String _jwt = '';
  String _linkName = '';
  String _linkValue = '';
  String _topicInputValue = '';

  /// Illustration's name after page loading.
  /// Used to know if they're pending changes.
  String? _initialName = "";

  /// Illustration's description after page loading.
  /// Used to know if they're pending changes.
  String? _initialDescription = "";

  /// Illustration's story after page loading.
  /// Used to know if they're pending changes.
  String _initialStory = "";

  @override
  void initState() {
    super.initState();
    populateFields();
    fetchIllustration();
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
                        widget.illustration!.name,
                      ],
                    ),
                    tooltip: "close".tr(),
                    subtitle: "illustration_metadata_description".tr(),
                    bottom: Opacity(
                      opacity: 0.7,
                      child: Text(
                        "card_click_to_expand".tr(),
                        style: FontsUtils.mainStyle(
                          color: stateColors.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  body(),
                ],
              ),
            ),
          ),
          popupProgressIndicator(),
          stylesSidePanel(),
          licenseSidePanel(),
        ],
      ),
    );
  }

  Widget body() {
    if (_isLoading) {
      return LoadingView();
    }

    return Padding(
      padding: EdgeInsets.only(top: 90.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          presentationSection(),
          stylesSection(),
          topicsSection(),
          visibilitySection(),
          licenseSection(),
          metaValidationButton(),
        ],
      ),
    );
  }

  Widget descriptionInput() {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: 20.0, left: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                "description".tr(),
                style: FontsUtils.mainStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(
              width: 300.0,
              child: TextFormField(
                controller: _descriptionTextController,
                decoration: InputDecoration(
                  labelText: "illustration_description_sample".tr(),
                  filled: true,
                  isDense: true,
                  fillColor: stateColors.clairPink,
                  focusColor: stateColors.clairPink,
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      width: 2.0,
                      color: stateColors.primary,
                    ),
                  ),
                ),
                onChanged: (value) {
                  setState(() {});
                },
                onFieldSubmitted: (value) {
                  updatePresentation();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget storyInput() {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: 40.0, left: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                "story".tr(),
                style: FontsUtils.mainStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(
              width: 300.0,
              child: TextFormField(
                maxLines: null,
                controller: _storyTextController,
                decoration: InputDecoration(
                  filled: true,
                  isDense: true,
                  labelText: "illustration_story_sample".tr(),
                  fillColor: stateColors.clairPink,
                  focusColor: stateColors.clairPink,
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      width: 2.0,
                      color: stateColors.primary,
                    ),
                  ),
                ),
                onChanged: (value) {
                  setState(() {});
                },
                onFieldSubmitted: (value) {
                  updatePresentation();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget headerTitle(String textValue) {
    return Opacity(
      opacity: 0.8,
      child: Text(
        textValue,
        style: FontsUtils.mainStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget headerDescription(String textValue) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 4.0,
        bottom: 8.0,
      ),
      child: Opacity(
        opacity: 0.6,
        child: Text(
          textValue,
          style: FontsUtils.mainStyle(),
        ),
      ),
    );
  }

  Widget metaValidationButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 80.0),
      child: DarkElevatedButton(
        onPressed: Beamer.of(context).popRoute,
        child: Text("done".tr()),
      ),
    );
  }

  Widget popupProgressIndicator() {
    if (!_isSaving) {
      return Container();
    }

    return Positioned(
      top: 40.0,
      right: 24.0,
      child: SizedBox(
        width: 240.0,
        child: Card(
          elevation: 4.0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 4.0,
                child: LinearProgressIndicator(),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      UniconsLine.circle,
                      color: stateColors.secondary,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Opacity(
                          opacity: 0.6,
                          child: Text(
                            "project_updating".tr(),
                            style: FontsUtils.mainStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget presentationSection() {
    return SizedBox(
      width: 600.0,
      child: ExpansionTileCard(
        key: _presentationCard,
        elevation: 0.0,
        expandedTextColor: Colors.black,
        baseColor: stateColors.lightBackground,
        expandedColor: stateColors.lightBackground,
        title: presentationHeader(),
        children: [
          presentationContent(),
        ],
      ),
    );
  }

  Widget presentationHeader() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        headerTitle("presentation".tr()),
        headerDescription("presentation_description".tr()),
      ],
    );
  }

  Widget presentationButtons() {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.only(
          top: 40.0,
          left: 12.0,
          bottom: 24.0,
        ),
        child: Wrap(
          spacing: 24.0,
          children: [
            IconButton(
              tooltip: "cancel".tr(),
              onPressed: () {
                setState(() {
                  _nameTextController.text = _initialName!;
                  _descriptionTextController.text = _initialDescription!;
                  _storyTextController.text = _initialStory;

                  _presentationCard.currentState!.collapse();
                });
              },
              icon: Opacity(
                opacity: 0.8,
                child: Icon(UniconsLine.times),
              ),
            ),
            IconButton(
              tooltip: "update".tr(),
              onPressed: updatePresentation,
              color: stateColors.primary,
              icon: Icon(UniconsLine.check),
            ),
          ],
        ),
      ),
    );
  }

  Widget presentationPendingChanges() {
    final bool sameDescription =
        _initialDescription == _descriptionTextController.text;
    final bool sameName = _initialName == _nameTextController.text;
    final bool sameStory = _initialStory == _storyTextController.text;

    if (sameName && sameDescription && sameStory) {
      return Container();
    }

    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 24.0),
        child: Text(
          "You have unsaved changes.",
          style: FontsUtils.mainStyle(
            color: stateColors.secondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget presentationContent() {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: 16.0, left: 16.0),
        child: Column(
          children: [
            nameInput(),
            descriptionInput(),
            storyInput(),
            presentationButtons(),
            presentationPendingChanges(),
          ],
        ),
      ),
    );
  }

  Widget topicsSection() {
    return Container(
      width: 600.0,
      padding: const EdgeInsets.only(
        top: 100.0,
      ),
      child: ExpansionTileCard(
        elevation: 0.0,
        expandedTextColor: Colors.black,
        baseColor: stateColors.lightBackground,
        expandedColor: stateColors.lightBackground,
        title: topicsHeader(),
        children: [
          topicsContent(),
          topicsInput(),
        ],
      ),
    );
  }

  Widget topicsHeader() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        headerTitle("topics".tr()),
        headerDescription("topics_description".tr()),
      ],
    );
  }

  Widget topicsContent() {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: 16.0, left: 16.0),
        child: Wrap(
          spacing: 10.0,
          runSpacing: 10.0,
          children: _topics.entries.map((entry) {
            return InputChip(
              label: Opacity(
                opacity: 0.8,
                child: Text(
                  "${entry.key.substring(0, 1).toUpperCase()}"
                  "${entry.key.substring(1)}",
                ),
              ),
              labelStyle: FontsUtils.mainStyle(
                fontWeight: FontWeight.w600,
              ),
              labelPadding: const EdgeInsets.symmetric(horizontal: 12.0),
              deleteIconColor: stateColors.secondary.withOpacity(0.8),
              onDeleted: () {
                removeTopicAndUpdate(entry);
              },
              onSelected: (isSelected) {},
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget topicsInput() {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: 20.0, left: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                "topics".tr(),
                style: FontsUtils.mainStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 300.0,
                  child: TextFormField(
                    controller: _topicsTextController,
                    decoration: InputDecoration(
                      labelText: "topics_label_text".tr(),
                      filled: true,
                      isDense: true,
                      fillColor: stateColors.clairPink,
                      focusColor: stateColors.clairPink,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 2.0,
                          color: stateColors.primary,
                        ),
                      ),
                    ),
                    onChanged: (value) {
                      _topicInputValue = value;
                    },
                    onFieldSubmitted: (value) {
                      addTopicAndUpdate();
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: IconButton(
                    tooltip: "topic_add".tr(),
                    icon: Opacity(
                      opacity: 0.6,
                      child: Icon(UniconsLine.plus),
                    ),
                    onPressed: addTopicAndUpdate,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget nameInput() {
    return Container(
      width: 700.0,
      padding: const EdgeInsets.only(
        top: 0.0,
      ),
      child: TextField(
        maxLines: null,
        autofocus: true,
        controller: _nameTextController,
        keyboardType: TextInputType.multiline,
        textCapitalization: TextCapitalization.sentences,
        style: FontsUtils.mainStyle(
          fontSize: 42.0,
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          hintText: "illustration_title_dot".tr(),
          border: OutlineInputBorder(borderSide: BorderSide.none),
        ),
        onChanged: (newValue) {
          setState(() {});
        },
        onSubmitted: (value) => updatePresentation(),
      ),
    );
  }

  Widget stylesSection() {
    return Container(
      width: 600.0,
      padding: const EdgeInsets.only(top: 100.0),
      child: ExpansionTileCard(
        elevation: 0.0,
        expandedTextColor: Colors.black,
        baseColor: stateColors.lightBackground,
        expandedColor: stateColors.lightBackground,
        title: stylesHeader(),
        children: [
          selectedStyles(),
          stylesAddButton(),
        ],
      ),
    );
  }

  Widget stylesAddButton() {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.only(
          top: 24.0,
          left: 16.0,
        ),
        child: DarkElevatedButton(
          onPressed: () {
            setState(() {
              _isSidePanelStylesVisible = !_isSidePanelStylesVisible;
            });
          },
          child: Text(
            _isSidePanelStylesVisible
                ? "style_hide_panel".tr()
                : "style_add".tr(),
          ),
        ),
      ),
    );
  }

  Widget stylesHeader() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        headerTitle("styles".tr()),
        headerDescription("styles_description".tr()),
      ],
    );
  }

  Widget stylesSidePanel() {
    return Positioned(
      top: 100.0,
      right: 24.0,
      child: AddStylePanel(
        isVisible: _isSidePanelStylesVisible,
        selectedStyles: _selectedStyles,
        onClose: () {
          setState(() => _isSidePanelStylesVisible = false);
        },
        toggleStyleAndUpdate: toggleStyleAndUpdate,
      ),
    );
  }

  Widget selectedStyles() {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Wrap(
            spacing: 12.0,
            runSpacing: 12.0,
            children: _selectedStyles.map((style) {
              return InputChip(
                label: Opacity(
                  opacity: 0.8,
                  child: Text(style!),
                ),
                labelStyle: FontsUtils.mainStyle(fontWeight: FontWeight.w700),
                elevation: 2.0,
                deleteIconColor: stateColors.secondary.withOpacity(0.8),
                labelPadding: const EdgeInsets.symmetric(horizontal: 12.0),
                onDeleted: () {
                  removeStyleAndUpdate(style);
                },
                onSelected: (isSelected) {},
              );
            }).toList()),
      ),
    );
  }

  Widget visibilityBody() {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: 12.0, left: 16.0),
        child: PopupMenuButton(
          tooltip: "illustration_visibility_choose".tr(),
          child: visibilityCurrentButton(),
          onSelected: updateVisibility,
          itemBuilder: (context) => <PopupMenuEntry<ContentVisibility>>[
            visibiltyPopupItem(
              value: ContentVisibility.private,
              titleValue: "visibility_private".tr(),
              subtitleValue: "visibility_private_description".tr(),
            ),
            visibiltyPopupItem(
              value: ContentVisibility.public,
              titleValue: "visibility_public".tr(),
              subtitleValue: "visibility_public_description".tr(),
            ),
          ],
        ),
      ),
    );
  }

  Widget visibilityCurrentButton() {
    final illustration = widget.illustration!;

    return Material(
      color: Colors.black87,
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6.0),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 200.0,
          minHeight: 48.0,
        ),
        child: Center(
          child: Text(
            "visibility_${illustration.visibilityToString()}"
                .tr()
                .toUpperCase(),
            style: FontsUtils.mainStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget visibilityHeader() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          headerTitle("visibility".tr()),
          headerDescription("illustration_visibility_description".tr()),
        ],
      ),
    );
  }

  PopupMenuItem<ContentVisibility> visibiltyPopupItem({
    ContentVisibility? value,
    required String titleValue,
    required String subtitleValue,
  }) {
    return PopupMenuItem(
      value: value,
      child: ListTile(
        title: Text(
          titleValue,
          style: FontsUtils.mainStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitleValue,
          style: FontsUtils.mainStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget visibilitySection() {
    return Container(
      width: 600.0,
      padding: const EdgeInsets.only(
        top: 100.0,
      ),
      child: ExpansionTileCard(
        elevation: 0.0,
        expandedTextColor: Colors.black,
        baseColor: stateColors.lightBackground,
        expandedColor: stateColors.lightBackground,
        title: visibilityHeader(),
        children: [
          visibilityBody(),
        ],
      ),
    );
  }

  Widget licenseCurrent() {
    final illustration = widget.illustration!;

    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        width: 400.0,
        padding: const EdgeInsets.only(
          top: 24.0,
          left: 12.0,
          bottom: 12.0,
        ),
        child: Card(
          elevation: 2.0,
          child: InkWell(
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Opacity(
                        opacity: 0.6,
                        child: Text(
                          "license_current".tr().toUpperCase(),
                          style: FontsUtils.mainStyle(
                            color: stateColors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Opacity(
                        opacity: 0.8,
                        child: Text(
                          illustration.license!.name!.isEmpty
                              ? "license_none".tr()
                              : illustration.license!.name!,
                          style: FontsUtils.mainStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Opacity(
                    opacity: 0.8,
                    child: IconButton(
                      tooltip: "license_current_remove".tr(),
                      onPressed: unselectLicenseAndUpdate,
                      icon: Icon(UniconsLine.trash),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget licenseHeader() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          headerTitle("license".tr()),
          headerDescription("illustration_license_description".tr()),
        ],
      ),
    );
  }

  Widget licenseSection() {
    return Container(
      width: 600.0,
      padding: const EdgeInsets.only(
        top: 100.0,
      ),
      child: ExpansionTileCard(
        elevation: 0.0,
        expandedTextColor: Colors.black,
        baseColor: stateColors.lightBackground,
        expandedColor: stateColors.lightBackground,
        onExpansionChanged: (isExpanded) {
          if (!isExpanded) {
            return;
          }

          fetchIllustrationLicense();
        },
        title: licenseHeader(),
        children: [
          licenseCurrent(),
          licenseSelectButton(),
        ],
      ),
    );
  }

  Widget licenseSelectButton() {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.only(
          top: 24.0,
          left: 16.0,
        ),
        child: DarkElevatedButton(
          onPressed: () {
            setState(() {
              _isSidePanelLicenseVisible = !_isSidePanelLicenseVisible;
            });
          },
          child: Text(
            _isSidePanelStylesVisible
                ? "license_hide_panel".tr()
                : "license_select".tr(),
          ),
        ),
      ),
    );
  }

  Widget licenseSidePanel() {
    return Positioned(
      top: 100.0,
      right: 24.0,
      child: SelectLicensePanel(
        isVisible: _isSidePanelLicenseVisible,
        selectedLicense: widget.illustration!.license,
        onClose: () {
          setState(() => _isSidePanelLicenseVisible = false);
        },
        toggleLicenseAndUpdate: toggleLicenseAndUpdate,
      ),
    );
  }

  void addStyleAndUpdate(String? styleName) async {
    setState(() {
      _selectedStyles.add(styleName);
      _isSaving = true;
    });

    try {
      final response = await Cloud.illustrations("updateStyles").call({
        "illustrationId": widget.illustration!.id,
        "styles": _selectedStyles,
      });

      final bool success = response.data["success"];

      if (!success) {
        throw "styles_update_fail".tr();
      }
    } on FirebaseFunctionsException catch (error) {
      appLogger.e(error);

      String errorMessage = "styles_update_fail".tr();

      if (error.code == "out-of-range") {
        final matches = _numberRegex.toRegExp().allMatches(error.message!);

        final String? numberOfStyles =
            matches.last.group(matches.last.groupCount);

        errorMessage = "styles_update_out_of_range".tr(args: [numberOfStyles!]);
      }

      Snack.e(
        context: context,
        message: errorMessage,
      );
    } catch (error) {
      appLogger.e(error);

      setState(() {
        _selectedStyles.remove(styleName);
      });

      Snack.e(
        context: context,
        message: "styles_update_fail".tr(),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void addTopicAndUpdate() async {
    if (_topicInputValue.isEmpty) {
      Snack.e(
        context: context,
        message: "input_empty_invalid".tr(),
      );

      return;
    }

    final topicsList = _topicInputValue.split(",");

    setState(() {
      _topicsTextController.clear();

      for (String topic in topicsList) {
        _topics[topic] = true;
      }

      _isSaving = true;
    });

    try {
      final response = await Cloud.illustrations("updateTopics").call({
        "illustrationId": widget.illustration!.id,
        "topics": _topics.keys.toList(),
      });

      final bool success = response.data["success"];

      if (!success) {
        throw "topics_update_fail".tr();
      }
    } on FirebaseFunctionsException catch (error) {
      appLogger.e(error);

      for (String topic in topicsList) {
        _topics.remove(topic);
      }

      String? errorMessage = error.message;

      if (error.code == "out-of-range") {
        final matches = _numberRegex.toRegExp().allMatches(error.message!);

        final String? numberOfTopics =
            matches.last.group(matches.last.groupCount);

        errorMessage = "topics_update_out_of_range".tr(args: [numberOfTopics!]);
      }

      Snack.e(
        context: context,
        message: errorMessage,
      );
    } catch (error) {
      appLogger.e(error);

      for (String topic in topicsList) {
        _topics.remove(topic);
      }

      Snack.e(
        context: context,
        message: error.toString(),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void addLinkAndUpdate() async {
    _linkNameInputController.text = '';
    _linkValueInputController.text = '';

    /// To clear input label text while keeping the last value
    /// if request fails.
    final savedName = _linkName;

    final wasEditingExistingLink = _isEditingExistingLink;

    if (_isEditingExistingLink) {
      _links.remove(_editingExistingLinkName);
    }

    setState(() {
      _links[savedName] = _linkValue;
      _linkName = '';
      _isSaving = true;
      _isEditingExistingLink = false;
    });

    try {
      await _illustrationSnapshot.reference.update({'urls': _links});
    } catch (error) {
      appLogger.e(error);

      _links.remove(savedName);

      if (wasEditingExistingLink) {
        _links.putIfAbsent(_editingExistingLinkName, () => _linkValue);
      }

      Snack.e(
        context: context,
        message: "project_update_urls_fail".tr(),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void deleteUrlAndUpdate(MapEntry<String, String> entry) async {
    setState(() {
      _linkName = '';
      _linkValue = '';
      _linkNameInputController.clear();
      _linkValueInputController.clear();

      _links.remove(entry.key);
      _isSaving = true;
    });

    try {
      await _illustrationSnapshot.reference.update({'urls': _links});
    } catch (error) {
      appLogger.e(error);

      _links.putIfAbsent(entry.key, () => entry.value);

      Snack.e(
        context: context,
        message: "project_update_urls_fail".tr(),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void fetchIllustration() async {
    setState(() => _isLoading = true);

    try {
      _jwt = await FirebaseAuth.instance.currentUser!.getIdToken();

      _illustrationSnapshot = await FirebaseFirestore.instance
          .collection("illustrations")
          .doc(widget.illustration!.id)
          .get();

      if (!_illustrationSnapshot.exists) {
        return;
      }
    } catch (error) {
      appLogger.e(error);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void fetchIllustrationLicense() async {
    if (widget.illustration!.license!.id!.isEmpty) {
      return;
    }

    try {
      final licenseSnap = await FirebaseFirestore.instance
          .collection("licenses")
          .doc(widget.illustration!.license!.id)
          .get();

      if (!licenseSnap.exists) {
        return;
      }

      final data = licenseSnap.data()!;
      data['id'] = licenseSnap.id;

      setState(() {
        final completeLicense = IllustrationLicense.fromJSON(data);
        widget.illustration!.license = completeLicense;
      });
    } catch (error) {
      appLogger.e(error);
    }
  }

  void populateFields() {
    final illustration = widget.illustration!;

    _initialName = illustration.name;
    _initialDescription = illustration.description;
    _initialStory = illustration.story;

    _nameTextController.text = illustration.name;
    _descriptionTextController.text = illustration.description;
    _storyTextController.text = illustration.story;

    illustration.topics.forEach((key) {
      _topics.putIfAbsent(key, () => true);
    });

    _selectedStyles.addAll(widget.illustration!.styles);
  }

  void removeStyleAndUpdate(String? styleName) async {
    setState(() {
      _isSaving = true;
      _selectedStyles.remove(styleName);
    });

    try {
      final response = await Cloud.illustrations("updateStyles").call({
        "illustrationId": widget.illustration!.id,
        "styles": _selectedStyles,
      });

      final bool success = response.data["success"];

      if (!success) {
        throw "styles_update_fail".tr();
      }
    } on FirebaseFunctionsException catch (error) {
      appLogger.e(error);

      Snack.e(
        context: context,
        message: error.message,
      );
    } catch (error) {
      appLogger.e(error);
      _selectedStyles.add(styleName);

      Snack.e(
        context: context,
        message: "styles_update_fail".tr(),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void removeProLangAndUpdate(String key) async {
    _programmingLanguages.remove(key);
    setState(() => _isSaving = true);

    try {
      await _illustrationSnapshot.reference
          .update({'programmingLanguages': _programmingLanguages});
    } catch (error) {
      appLogger.e(error);
      _programmingLanguages.putIfAbsent(key, () => true);

      Snack.e(
        context: context,
        message: "project_update_prog_fail".tr(),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void removeTopicAndUpdate(MapEntry<String, bool> entry) async {
    setState(() {
      _topics.remove(entry.key);
      _isSaving = true;
    });

    try {
      final response = await Cloud.illustrations("updateTopics").call({
        "illustrationId": widget.illustration!.id,
        "topics": _topics.keys.toList(),
      });

      final bool success = response.data["success"];

      if (!success) {
        throw "topics_update_fail".tr();
      }
    } catch (error) {
      appLogger.e(error);
      _topics.putIfAbsent(entry.key, () => entry.value);

      Snack.e(
        context: context,
        message: error.toString(),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void toggleLicenseAndUpdate(
    IllustrationLicense illustrationLicense,
    bool selected,
  ) async {
    if (selected) {
      unselectLicenseAndUpdate();
      return;
    }

    selectLicenseAndUpdate(illustrationLicense);
  }

  void selectLicenseAndUpdate(IllustrationLicense illustrationLicense) async {
    setState(() => _isSaving = true);

    final illustration = widget.illustration!;
    final previousLicense = illustration.license;
    illustration.license = illustrationLicense;

    try {
      final response = await Cloud.illustrations("updateLicense").call({
        "illustrationId": illustration.id,
        "license": {
          "id": illustrationLicense.id,
          "from": illustrationLicense.from,
        },
      });

      final bool success = response.data["success"];

      if (!success) {
        throw "license_update_fail".tr();
      }
    } catch (error) {
      appLogger.e(error);

      illustrationLicense = previousLicense!;

      Snack.e(
        context: context,
        message: error.toString(),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void unselectLicenseAndUpdate() async {
    setState(() => _isSaving = true);

    final illustration = widget.illustration!;
    final previousLicense = illustration.license;
    illustration.license = IllustrationLicense.empty();

    try {
      final response = await Cloud.illustrations("unsetLicense").call({
        "illustrationId": illustration.id,
        "license": {
          "id": illustration.license!.id,
          "from": illustration.license!.from,
        },
      });

      final bool success = response.data["success"];

      if (!success) {
        throw "license_update_fail".tr();
      }
    } catch (error) {
      appLogger.e(error);

      illustration.license = previousLicense;

      Snack.e(
        context: context,
        message: error.toString(),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void updatePresentation() async {
    _presentationCard.currentState!.collapse();
    setState(() => _isSaving = true);

    final illustration = widget.illustration!;

    try {
      final HttpsCallableResult response =
          await Cloud.illustrations("updatePresentation").call({
        "illustrationId": illustration.id,
        "name": _nameTextController.text,
        "description": _descriptionTextController.text,
        "story": _storyTextController.text,
        "jwt": _jwt,
      });

      final bool success = response.data['success'];

      if (!success) {
        throw "The operation couldn't succeed.";
      }
    } catch (error) {
      appLogger.e(error);

      Snack.e(
        context: context,
        message: "project_update_title_fail".tr(),
      );

      _presentationCard.currentState!.expand();
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void toggleStyleAndUpdate(Style style, bool selected) {
    if (selected) {
      removeStyleAndUpdate(style.name);
      return;
    }

    addStyleAndUpdate(style.name);
  }

  void updateVisibility(ContentVisibility visibility) async {
    final illustration = widget.illustration!;
    final previousVisibility = widget.illustration!.visibility;

    setState(() {
      _isSaving = true;
      illustration.visibility = visibility;
    });

    try {
      final HttpsCallableResult response =
          await Cloud.illustrations("updateVisibility").call({
        "illustrationId": illustration.id,
        "visibility": illustration.visibilityToString(),
      });

      final bool success = response.data["success"];

      if (!success) {
        throw "illustration_visibility_update_fail".tr();
      }
    } on FirebaseFunctionsException catch (error) {
      appLogger.e(error);
      illustration.visibility = previousVisibility;

      Snack.e(
        context: context,
        message: "[${error.code}] ${error.message}",
      );
    } catch (error) {
      appLogger.e(error);

      illustration.visibility = previousVisibility;

      Snack.e(
        context: context,
        message: "illustration_visibility_update_fail".tr(),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }
}
