import 'package:artbooking/components/add_style_panel.dart';
import 'package:artbooking/components/dark_elevated_button.dart';
import 'package:artbooking/components/loading_view.dart';
import 'package:artbooking/components/sheet_header.dart';
import 'package:artbooking/state/colors.dart';
import 'package:artbooking/types/illustration/illustration.dart';
import 'package:artbooking/types/style.dart';
import 'package:artbooking/utils/app_logger.dart';
import 'package:artbooking/utils/cloud_helper.dart';
import 'package:artbooking/utils/fonts.dart';
import 'package:artbooking/utils/snack.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';
import 'package:verbal_expressions/verbal_expressions.dart';

class EditIllustrationMeta extends StatefulWidget {
  final Illustration illustration;

  const EditIllustrationMeta({
    Key key,
    @required this.illustration,
  }) : super(key: key);

  @override
  _EditIllustrationMetaState createState() => _EditIllustrationMetaState();
}

class _EditIllustrationMetaState extends State<EditIllustrationMeta> {
  bool _isLoading = false;
  bool _isSaving = false;
  bool _isSidePanelStylesVisible = false;

  bool _isEditingExistingLink = false;

  DocumentSnapshot _illustrationSnapshot;

  final _linkNameFocusNode = FocusNode();
  final _linkValueFocusNode = FocusNode();

  final _descriptionTextController = TextEditingController();
  final _topicsTextController = TextEditingController();
  final _storyTextController = TextEditingController();
  final _nameTextController = TextEditingController();
  final _linkNameInputController = TextEditingController();
  final _linkValueInputController = TextEditingController();

  /// Illustration's selected art styles.
  final List<String> _selectedStyles = [];

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
  String _initialName = "";

  /// Illustration's description after page loading.
  /// Used to know if they're pending changes.
  String _initialDescription = "";

  /// Illustration's story after page loading.
  /// Used to know if they're pending changes.
  String _initialStory = "";

  @override
  void initState() {
    super.initState();
    populateFields();
    fetch();
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
                    title: "illustration_metadata".tr(),
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
          topicsSection(),
          stylesSection(),
          linksSection(),
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
        onPressed: context.router.pop,
        child: Text("done".tr()),
      ),
    );
  }

  Widget popupProgressIndicator() {
    if (!_isSaving) {
      return Container();
    }

    return Positioned(
      top: 100.0,
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
                  _nameTextController.text = _initialName;
                  _descriptionTextController.text = _initialDescription;
                  _storyTextController.text = _initialStory;

                  _presentationCard.currentState.collapse();
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

  Widget linksContent() {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: Wrap(
          spacing: 12.0,
          runSpacing: 12.0,
          children: _links.entries.map((entry) {
            return InputChip(
              label: Opacity(
                opacity: 0.8,
                child: Text(entry.key),
              ),
              labelPadding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 2.0,
              ),
              labelStyle: FontsUtils.mainStyle(
                fontWeight: FontWeight.w600,
              ),
              elevation: entry.value.isEmpty ? 0.0 : 2.0,
              selected: entry.value.isNotEmpty,
              checkmarkColor: Colors.black26,
              deleteIconColor: entry.value.isEmpty
                  ? Colors.black26
                  : stateColors.secondary.withOpacity(0.8),
              onDeleted: () {
                deleteUrlAndUpdate(entry);
              },
              onPressed: () {
                setState(() {
                  _linkName = entry.key;
                  _linkValue = entry.value;
                  _editingExistingLinkName = entry.key;
                  _isEditingExistingLink = true;
                  _linkNameInputController.text = '';
                  _linkValueInputController.text = entry.value;
                });

                _linkValueFocusNode.requestFocus();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget linksHeader() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          headerTitle("urls_ext".tr()),
          headerDescription("urls_ext_description".tr()),
        ],
      ),
    );
  }

  Widget linksSection() {
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
        title: linksHeader(),
        children: [
          linksContent(),
          linksInput(),
        ],
      ),
    );
  }

  Widget editingExistingLinkContainer() {
    if (!_isEditingExistingLink) {
      return Padding(padding: EdgeInsets.zero);
    }

    return Padding(
      padding: const EdgeInsets.only(top: 12.0, bottom: 24.0),
      child: Wrap(
        spacing: 12.0,
        runSpacing: 12.0,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            "You are editing an existing link.",
            style: FontsUtils.mainStyle(
              color: stateColors.primary,
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _linkName = '';
                _linkValue = '';
                _editingExistingLinkName = '';
                _isEditingExistingLink = false;
                _linkValueInputController.clear();
              });

              _linkNameFocusNode.requestFocus();
            },
            style: OutlinedButton.styleFrom(
              primary: Colors.black54,
              textStyle: FontsUtils.mainStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 8.0,
              ),
              child: Stack(
                children: [
                  Text("url_new".tr()),
                  Positioned(
                    left: 0.0,
                    right: 0.0,
                    bottom: 0.0,
                    child: Container(
                      color: Colors.black38,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget linksInput() {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: 36.0, left: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            editingExistingLinkContainer(),
            Container(
              width: 260.0,
              padding: const EdgeInsets.only(bottom: 12.0),
              child: TextFormField(
                focusNode: _linkNameFocusNode,
                controller: _linkNameInputController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: _linkName.isNotEmpty ? _linkName : "url_name".tr(),
                ),
                onChanged: (value) {
                  _linkName = value;

                  setState(() {
                    _isEditingExistingLink = _links.containsKey(_linkName);
                  });
                },
              ),
            ),
            Wrap(
              spacing: 24.0,
              runSpacing: 24.0,
              crossAxisAlignment: WrapCrossAlignment.end,
              children: [
                SizedBox(
                  width: 260.0,
                  child: TextFormField(
                    focusNode: _linkValueFocusNode,
                    controller: _linkValueInputController,
                    textInputAction: TextInputAction.go,
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'https://$_linkName...',
                    ),
                    keyboardType: TextInputType.url,
                    onChanged: (value) {
                      _linkValue = value;
                    },
                    onFieldSubmitted: (value) {
                      addLinkAndUpdate();
                    },
                  ),
                ),
                IconButton(
                  tooltip: "url_add".tr(),
                  icon: Opacity(
                    opacity: 0.6,
                    child: Icon(UniconsLine.check),
                  ),
                  onPressed: () {
                    addLinkAndUpdate();
                  },
                ),
              ],
            ),
          ],
        ),
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
                  child: Text(style),
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

  void addStyleAndUpdate(String styleName) async {
    setState(() {
      _selectedStyles.add(styleName);
      _isSaving = true;
    });

    try {
      final response = await Cloud.illustrations("updateStyles").call({
        "illustrationId": widget.illustration.id,
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
        final matches = _numberRegex.toRegExp().allMatches(error.message);

        final String numberOfStyles =
            matches.last.group(matches.last.groupCount);

        errorMessage = "styles_update_out_of_range".tr(args: [numberOfStyles]);
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
        "illustrationId": widget.illustration.id,
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

      String errorMessage = error.message;

      if (error.code == "out-of-range") {
        final matches = _numberRegex.toRegExp().allMatches(error.message);

        final String numberOfTopics =
            matches.last.group(matches.last.groupCount);

        errorMessage = "topics_update_out_of_range".tr(args: [numberOfTopics]);
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

  void fetch() async {
    setState(() => _isLoading = true);

    try {
      _jwt = await FirebaseAuth.instance.currentUser.getIdToken();

      _illustrationSnapshot = await FirebaseFirestore.instance
          .collection("illustrations")
          .doc(widget.illustration.id)
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

  void populateFields() {
    final illustration = widget.illustration;

    _initialName = illustration.name;
    _initialDescription = illustration.description;
    _initialStory = illustration.story;

    _nameTextController.text = illustration.name;
    _descriptionTextController.text = illustration.description;
    _storyTextController.text = illustration.story;

    illustration.topics.forEach((key) {
      _topics.putIfAbsent(key, () => true);
    });

    _selectedStyles.addAll(widget.illustration.styles);
  }

  void removeStyleAndUpdate(String styleName) async {
    setState(() {
      _isSaving = true;
      _selectedStyles.remove(styleName);
    });

    try {
      final response = await Cloud.illustrations("updateStyles").call({
        "illustrationId": widget.illustration.id,
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
        "illustrationId": widget.illustration.id,
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

  void updatePresentation() async {
    _presentationCard.currentState.collapse();
    setState(() => _isSaving = true);

    final illustration = widget.illustration;

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

      _presentationCard.currentState.expand();
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
}
