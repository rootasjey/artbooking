import 'package:artbooking/components/expansion_tile_card/expansion_tile_card_description.dart';
import 'package:artbooking/components/expansion_tile_card/expansion_tile_card_title.dart';
import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class EditIllustrationPageTopics extends StatelessWidget {
  const EditIllustrationPageTopics({
    Key? key,
    required this.topics,
    this.isMobileSize = false,
    this.onAddTopicAndUpdate,
    this.onRemoveTopicAndUpdate,
    this.topicInputFocusNode,
  }) : super(key: key);

  /// If true, this widget adapts its layout to small screens.
  final bool isMobileSize;

  /// Allow to request focus after adding a topic.
  final FocusNode? topicInputFocusNode;

  /// Callback fired when a topic is added to an illustration.
  final void Function(String topic)? onAddTopicAndUpdate;

  /// Callback fired when a topic is removed from an illustration.
  final void Function(String topic)? onRemoveTopicAndUpdate;

  /// List of illustration's topics.
  final List<String> topics;

  @override
  Widget build(BuildContext context) {
    final _topicInputController = TextEditingController();

    return Container(
      width: 600.0,
      padding: const EdgeInsets.only(
        top: 100.0,
      ),
      child: ExpansionTileCard(
        elevation: 0.0,
        expandedTextColor: Colors.black,
        baseColor: Theme.of(context).backgroundColor,
        expandedColor: Theme.of(context).backgroundColor,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExpansionTileCardTitle(
              textValue: "topics".tr(),
            ),
            ExpansionTileCardDescription(
              textValue: "topics_description".tr(),
            ),
          ],
        ),
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(top: 16.0, left: 16.0),
              child: Wrap(
                spacing: 10.0,
                runSpacing: 10.0,
                children: topics.map((topic) {
                  return InputChip(
                    label: Opacity(
                      opacity: 0.8,
                      child: Text(topic),
                    ),
                    labelStyle: Utilities.fonts.body(
                      fontWeight: FontWeight.w600,
                    ),
                    labelPadding: const EdgeInsets.symmetric(horizontal: 12.0),
                    deleteIconColor:
                        Theme.of(context).secondaryHeaderColor.withOpacity(0.8),
                    onDeleted: () {
                      onRemoveTopicAndUpdate?.call(topic);
                    },
                    onSelected: (isSelected) {
                      _topicInputController.text = topic;
                      topicInputFocusNode?.requestFocus();
                    },
                  );
                }).toList(),
              ),
            ),
          ),
          Align(
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
                      style: Utilities.fonts.body(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: isMobileSize ? 260.0 : 300.0,
                        child: TextFormField(
                          focusNode: topicInputFocusNode,
                          controller: _topicInputController,
                          decoration: InputDecoration(
                            hintText: "topics_label_text".tr(),
                            filled: true,
                            isDense: true,
                            fillColor: Constants.colors.clairPink,
                            focusColor: Constants.colors.clairPink,
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                width: 2.0,
                                color: Theme.of(context)
                                        .textTheme
                                        .bodyText2
                                        ?.color
                                        ?.withOpacity(0.6) ??
                                    Colors.black54,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                width: 2.0,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                          onFieldSubmitted: onAddTopicAndUpdate,
                          style: Utilities.fonts.body(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                          ),
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
                          onPressed: () => onAddTopicAndUpdate?.call(
                            _topicInputController.text,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
