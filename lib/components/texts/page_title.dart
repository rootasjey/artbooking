import 'package:artbooking/globals/utilities.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class PageTitle extends StatelessWidget {
  const PageTitle({
    Key? key,
    this.titleValue,
    required this.subtitleValue,
    this.showBackButton = false,
    this.title,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.padding = EdgeInsets.zero,
    this.renderSliver = true,
  }) : super(key: key);

  /// If true, render this Widget as a sliver box.
  final bool renderSliver;

  /// If specified, [titleValue] will be ignored.
  final Widget? title;

  /// String value for title.
  final String? titleValue;

  /// String value for subtitle.
  final String subtitleValue;

  /// If true, show a back icon button before title & subtitle.
  final bool showBackButton;

  final CrossAxisAlignment crossAxisAlignment;

  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final Widget titleWidget;

    if (title != null) {
      titleWidget = title as Widget;
    } else {
      titleWidget = Opacity(
        opacity: 0.8,
        child: Text(
          titleValue ?? "",
          style: Utilities.fonts.body(
            fontSize: 30.0,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
    }

    final child = Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: crossAxisAlignment,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (showBackButton)
                Padding(
                  padding: const EdgeInsets.only(right: 24.0),
                  child: Opacity(
                    opacity: 0.8,
                    child: IconButton(
                      onPressed: () => Utilities.navigation.back(context),
                      icon: Icon(UniconsLine.arrow_left),
                    ),
                  ),
                ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  titleWidget,
                  SizedBox(
                    width: 500.0,
                    child: Opacity(
                      opacity: 0.4,
                      child: Text(
                        subtitleValue,
                        style: Utilities.fonts.body(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );

    if (renderSliver) {
      return SliverToBoxAdapter(
        child: child,
      );
    }

    return child;
  }
}
