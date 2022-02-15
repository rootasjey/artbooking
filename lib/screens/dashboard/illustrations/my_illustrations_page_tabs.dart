import 'package:artbooking/components/buttons/dark_outlined_button.dart';
import 'package:artbooking/types/enums/enum_visibility_tab.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class MyIllustrationsPageTabs extends StatelessWidget {
  const MyIllustrationsPageTabs({
    Key? key,
    required this.selectedTab,
    this.onChangedTab,
  }) : super(key: key);

  final EnumVisibilityTab selectedTab;
  final void Function(EnumVisibilityTab)? onChangedTab;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12.0,
            runSpacing: 12.0,
            children: [
              DarkOutlinedButton(
                selected: EnumVisibilityTab.active == selectedTab,
                onPressed: onChangedTab != null ? onPressedActive : null,
                child: Text("active".tr().toUpperCase()),
              ),
              DarkOutlinedButton(
                selected: EnumVisibilityTab.archived == selectedTab,
                onPressed: onChangedTab != null ? onPressedArchived : null,
                child: Text("archived".tr().toUpperCase()),
              ),
            ],
          ),
          Row(
            children: [
              SizedBox(
                width: 300.0,
                child: Divider(
                  thickness: 1.0,
                  height: 42.0,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  radius: 4.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void onPressedActive() {
    onChangedTab?.call(EnumVisibilityTab.active);
  }

  void onPressedArchived() {
    onChangedTab?.call(EnumVisibilityTab.archived);
  }
}
