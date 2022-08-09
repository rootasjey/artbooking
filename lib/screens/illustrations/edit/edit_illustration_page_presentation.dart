import 'package:artbooking/components/buttons/dark_elevated_button.dart';
import 'package:artbooking/components/buttons/dark_text_button.dart';
import 'package:artbooking/components/expansion_tile_card/expansion_tile_card_description.dart';
import 'package:artbooking/components/expansion_tile_card/expansion_tile_card_title.dart';
import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class EditIllustrationPagePresentation extends StatelessWidget {
  const EditIllustrationPagePresentation({
    Key? key,
    required this.cardKey,
    required this.description,
    required this.name,
    required this.lore,
    this.isMobileSize = false,
    this.onDescriptionChanged,
    this.onLoreChanged,
    this.onTitleChanged,
    this.onUpdatePresentation,
  }) : super(key: key);

  /// If true, this widget adapts its layout to small screens.
  final bool isMobileSize;

  /// Callback fired when illustrations's description is updated.
  final void Function(String)? onDescriptionChanged;

  /// Callback fired when illustrations's lore is updated.
  final void Function(String)? onLoreChanged;

  /// Callback fired when illustrations's title is updated.
  final void Function(String)? onTitleChanged;

  /// Callback fired when illustrations's title, description and/or lore
  /// has changed.
  final void Function(
    String name,
    String description,
    String lore,
  )? onUpdatePresentation;

  /// Card's key to follow expansion tile card state.
  final GlobalKey<ExpansionTileCardState> cardKey;

  /// Illustration's description.
  final String description;

  /// Illustration's lore.
  final String lore;

  /// Illustration's title.
  final String name;

  @override
  Widget build(BuildContext context) {
    final Color _clairPink = Constants.colors.clairPink;

    final _descriptionInputController = TextEditingController();
    final _nameInputController = TextEditingController();
    final _loreInputController = TextEditingController();

    /// Illustration's name after page loading.
    /// Used to know if they're pending changes.
    final String _initialName = name;

    /// Illustration's description after page loading.
    /// Used to know if they're pending changes.
    final String _initialDescription = description;

    /// Illustration's story after page loading.
    /// Used to know if they're pending changes.
    final String _initialStory = lore;

    _nameInputController.text = _initialName;
    _descriptionInputController.text = _initialDescription;
    _loreInputController.text = _initialStory;

    final double inputWidth = isMobileSize ? 320.0 : 600.0;

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
                      style: Utilities.fonts.body(
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
                    style: Utilities.fonts.body(
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
                      style: Utilities.fonts.body(
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
                    style: Utilities.fonts.body(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Opacity(
                  opacity: 0.6,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      "story".tr(),
                      style: Utilities.fonts.body(
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
                    controller: _loreInputController,
                    onChanged: onLoreChanged,
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
                      _loreInputController.text,
                    ),
                    buildCounter: (
                      context, {
                      required int currentLength,
                      required bool isFocused,
                      int? maxLength,
                    }) =>
                        buildCounter(
                      context,
                      currentTextValue: _loreInputController.text,
                      initialTextValue: _initialStory,
                    ),
                    style: Utilities.fonts.body(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
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
                        _loreInputController.text = _initialStory;
                      },
                    ),
                    DarkElevatedButton(
                      child: Text("update".tr()),
                      onPressed: () => onUpdatePresentation?.call(
                        _nameInputController.text,
                        _descriptionInputController.text,
                        _loreInputController.text,
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
        style: Utilities.fonts.body(
          fontWeight: FontWeight.w600,
        ),
        children: [
          if (unsavedChanges)
            TextSpan(
              // text: "• Unsaved changes",
              text: "text_field_counter_unsaved_changes".tr(),
              style: Utilities.fonts.body(
                color: Theme.of(context).secondaryHeaderColor,
              ),
            ),
        ],
      ),
    );
  }
}
