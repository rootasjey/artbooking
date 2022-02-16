import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/enums/enum_visibility_tab.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

/// My books page custom title with a popup menu button.
class MyBooksPageTitle extends StatelessWidget {
  const MyBooksPageTitle({
    Key? key,
    required this.selectedTab,
    this.onChangedTab,
  }) : super(key: key);

  final EnumVisibilityTab selectedTab;
  final void Function(EnumVisibilityTab)? onChangedTab;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Opacity(
          opacity: 0.8,
          child: Text(
            "books".tr(),
            style: Utilities.fonts.style(
              fontSize: 30.0,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Opacity(
          opacity: 0.3,
          child: Text(
            " •",
            style: Utilities.fonts.style(
              color: Theme.of(context).secondaryHeaderColor,
              fontSize: 30.0,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        PopupMenuButton(
          tooltip: "books_active_or_archived".tr(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Opacity(
              opacity: 0.8,
              child: Stack(
                children: [
                  Positioned(
                    bottom: 8.0,
                    left: 0.0,
                    right: 0.0,
                    child: Container(
                      height: 8.0,
                      color: Theme.of(context).primaryColor.withOpacity(0.4),
                    ),
                  ),
                  Text(
                    selectedTab.name,
                    style: Utilities.fonts.style(
                      fontSize: 30.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          onSelected: (visibilityTab) {
            onChangedTab?.call(visibilityTab as EnumVisibilityTab);
          },
          itemBuilder: (context) {
            return <PopupMenuEntry<Object>>[
              popupItem(EnumVisibilityTab.active, context),
              PopupMenuDivider(),
              popupItem(EnumVisibilityTab.archived, context),
            ];
          },
        ),
      ],
    );
  }

  PopupMenuItem<EnumVisibilityTab> popupItem(
    EnumVisibilityTab visibilityTab,
    BuildContext context,
  ) {
    final bool selected = selectedTab == visibilityTab;

    return PopupMenuItem(
      value: visibilityTab,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Opacity(
            opacity: 0.6,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (selected)
                  Icon(
                    UniconsLine.check,
                    color: selected ? Theme.of(context).primaryColor : null,
                  )
                else
                  Container(padding: const EdgeInsets.only(left: 24.0)),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    "books_${visibilityTab.name}_word".tr().toLowerCase(),
                    style: Utilities.fonts.style(
                      color: selected ? Theme.of(context).primaryColor : null,
                      fontSize: 26.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Divider(),
        ],
      ),
    );
  }
}
