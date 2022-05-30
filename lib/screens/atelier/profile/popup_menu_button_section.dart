import 'package:artbooking/components/buttons/circle_button.dart';
import 'package:artbooking/types/enums/enum_section_action.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class PopupMenuButtonSection extends StatelessWidget {
  const PopupMenuButtonSection({
    Key? key,
    required this.itemBuilder,
    required this.onSelected,
    this.show = true,
  }) : super(key: key);

  /// If true, show this widget normally.
  /// If false, this button will still exist in the tree
  /// but with an opacity of 0.0;
  final bool show;
  final List<PopupMenuEntry<EnumSectionAction>> Function(BuildContext)
      itemBuilder;
  final void Function(EnumSectionAction)? onSelected;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 18.0,
      right: 48.0,
      child: Opacity(
        opacity: show ? 1.0 : 0.0,
        child: PopupMenuButton(
          child: CircleButton.withNoEvent(
            radius: 16.0,
            icon: Icon(
              UniconsLine.ellipsis_h,
              color: Colors.black,
              size: 16.0,
            ),
          ),
          itemBuilder: itemBuilder,
          onSelected: onSelected,
        ),
      ),
    );
  }
}
