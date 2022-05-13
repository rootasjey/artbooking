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
    this.onAddTopicAndUpdate,
    this.onRemoveTopicAndUpdate,
  }) : super(key: key);

  final List<String> topics;
  final void Function(String)? onAddTopicAndUpdate;
  final void Function(String)? onRemoveTopicAndUpdate;

  @override
  Widget build(BuildContext context) {
    final _topicInputController = TextEditingController();
    final _inputFocusNode = FocusNode();

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
                      _inputFocusNode.requestFocus();
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
                        width: 300.0,
                        child: TextFormField(
                          focusNode: _inputFocusNode,
                          controller: _topicInputController,
                          decoration: InputDecoration(
                            labelText: "topics_label_text".tr(),
                            filled: true,
                            isDense: true,
                            fillColor: Constants.colors.clairPink,
                            focusColor: Constants.colors.clairPink,
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                width: 2.0,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                          onFieldSubmitted: onAddTopicAndUpdate,
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
