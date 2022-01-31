import 'package:artbooking/components/buttons/dark_elevated_button.dart';
import 'package:artbooking/components/buttons/dark_text_button.dart';
import 'package:artbooking/components/expansion_tile_card/expansion_tile_card_description.dart';
import 'package:artbooking/components/expansion_tile_card/expansion_tile_card_title.dart';
import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/illustration/illustration.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class EditIllustrationPagePresentation extends StatelessWidget {
  const EditIllustrationPagePresentation({
    Key? key,
    this.onUpdatePresentation,
    required this.cardKey,
    this.onTitleChanged,
    this.onDescriptionChanged,
    this.onStoryChanged,
    required this.illustration,
  }) : super(key: key);

  final void Function(String, String, String)? onUpdatePresentation;
  final void Function(String)? onTitleChanged;
  final void Function(String)? onDescriptionChanged;
  final void Function(String)? onStoryChanged;
  final GlobalKey<ExpansionTileCardState> cardKey;

  final Illustration illustration;

  @override
  Widget build(BuildContext context) {
    final Color _clairPink = Constants.colors.clairPink;

    final _descriptionInputController = TextEditingController();
    final _nameInputController = TextEditingController();
    final _storyInputController = TextEditingController();

    /// Illustration's name after page loading.
    /// Used to know if they're pending changes.
    final String _initialName = illustration.name;

    /// Illustration's description after page loading.
    /// Used to know if they're pending changes.
    final String _initialDescription = illustration.description;

    /// Illustration's story after page loading.
    /// Used to know if they're pending changes.
    final String _initialStory = illustration.story;

    _nameInputController.text = _initialName;
    _descriptionInputController.text = _initialDescription;
    _storyInputController.text = _initialStory;

    final double inputWidth =
        Utilities.size.isMobileSize(context) ? 300.0 : 600.0;

    return SizedBox(
      width: 600.0,
      child: ExpansionTileCard(
        key: cardKey,
        elevation: 0.0,
        expandedTextColor: Colors.black,
        baseColor: Theme.of(context).backgroundColor,
        expandedColor: Theme.of(context).backgroundColor,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExpansionTileCardTitle(
              textValue: "presentation".tr(),
            ),
            ExpansionTileCardDescription(
              textValue: "presentation_description".tr(),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16.0, left: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Opacity(
                  opacity: 0.6,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      "title".tr(),
                      style: Utilities.fonts.style(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: inputWidth,
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: TextField(
                    autofocus: true,
                    controller: _nameInputController,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.sentences,
                    style: Utilities.fonts.style(
                      fontSize: 24.0,
                      fontWeight: FontWeight.w700,
                    ),
                    onChanged: onTitleChanged,
                    decoration: InputDecoration(
                      hintText: "illustration_title_dot".tr(),
                      filled: true,
                      isDense: true,
                      fillColor: _clairPink,
                      focusColor: _clairPink,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 2.0,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    buildCounter: (
                      context, {
                      required int currentLength,
                      required bool isFocused,
                      int? maxLength,
                    }) =>
                        buildCounter(
                      context,
                      currentTextValue: _nameInputController.text,
                      initialTextValue: _initialName,
                    ),
                  ),
                ),
                Opacity(
                  opacity: 0.6,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      "description".tr(),
                      style: Utilities.fonts.style(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  width: inputWidth,
                  child: TextFormField(
                    controller: _descriptionInputController,
                    textInputAction: TextInputAction.next,
                    onChanged: onDescriptionChanged,
                    decoration: InputDecoration(
                      hintText: "illustration_description_sample".tr(),
                      filled: true,
                      isDense: true,
                      fillColor: _clairPink,
                      focusColor: _clairPink,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 2.0,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    buildCounter: (
                      context, {
                      required int currentLength,
                      required bool isFocused,
                      int? maxLength,
                    }) =>
                        buildCounter(
                      context,
                      currentTextValue: _descriptionInputController.text,
                      initialTextValue: _initialDescription,
                    ),
                  ),
                ),
                Opacity(
                  opacity: 0.6,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      "story".tr(),
                      style: Utilities.fonts.style(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: inputWidth,
                  padding: const EdgeInsets.only(bottom: 36.0),
                  child: TextFormField(
                    maxLines: null,
                    controller: _storyInputController,
                    onChanged: onStoryChanged,
                    decoration: InputDecoration(
                      filled: true,
                      isDense: true,
                      hintText: "illustration_story_sample".tr(),
                      fillColor: _clairPink,
                      focusColor: _clairPink,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 2.0,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    onFieldSubmitted: (value) => onUpdatePresentation?.call(
                      _nameInputController.text,
                      _descriptionInputController.text,
                      _storyInputController.text,
                    ),
                    buildCounter: (
                      context, {
                      required int currentLength,
                      required bool isFocused,
                      int? maxLength,
                    }) =>
                        buildCounter(
                      context,
                      currentTextValue: _storyInputController.text,
                      initialTextValue: _initialStory,
                    ),
                  ),
                ),
                Wrap(
                  spacing: 24.0,
                  children: [
                    DarkTextButton(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Opacity(
                            opacity: 0.8,
                            child: Icon(UniconsLine.times),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text("cancel".tr()),
                          ),
                        ],
                      ),
                      onPressed: () {
                        cardKey.currentState?.collapse();

                        _nameInputController.text = _initialName;
                        _descriptionInputController.text = _initialDescription;
                        _storyInputController.text = _initialStory;
                      },
                    ),
                    DarkElevatedButton(
                      child: Text("update".tr()),
                      onPressed: () => onUpdatePresentation?.call(
                        _nameInputController.text,
                        _descriptionInputController.text,
                        _storyInputController.text,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCounter(
    BuildContext context, {
    required String currentTextValue,
    required String initialTextValue,
  }) {
    final bool unsavedChanges = initialTextValue != currentTextValue;

    return Text.rich(
      TextSpan(
        // text: "${currentTextValue.length} characters ",
        text: "text_field_counter_caracters".tr(args: [
          currentTextValue.length.toString(),
        ]),
        style: Utilities.fonts.style(
          fontWeight: FontWeight.w600,
        ),
        children: [
          if (unsavedChanges)
            TextSpan(
              // text: "• Unsaved changes",
              text: "text_field_counter_unsaved_changes".tr(),
              style: Utilities.fonts.style(
                color: Theme.of(context).secondaryHeaderColor,
              ),
            ),
        ],
      ),
    );
  }
}