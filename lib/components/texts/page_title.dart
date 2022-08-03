import 'package:artbooking/globals/utilities.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class PageTitle extends StatelessWidget {
  const PageTitle({
    Key? key,
    this.isMobileSize = false,
    this.renderSliver = true,
    this.showBackButton = false,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.padding = EdgeInsets.zero,
    this.subtitleValue = "",
    this.titleValue,
    this.title,
  }) : super(key: key);

  /// True if this widget must adapt its size to small screen.
  final bool isMobileSize;

  /// If true, render this Widget as a sliver box.
  final bool renderSliver;

  /// If true, show a back icon button before title & subtitle.
  final bool showBackButton;

  /// Alignment of children to the cross axis.
  final CrossAxisAlignment crossAxisAlignment;

  /// Spacing around this page title widget.
  final EdgeInsets padding;

  /// String value for subtitle.
  final String subtitleValue;

  /// If specified, [titleValue] will be ignored.
  final Widget? title;

  /// String value for title.
  final String? titleValue;

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
            height: isMobileSize ? 0.0 : null,
            fontSize: 30.0,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
    }

    final Widget child = Padding(
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    titleWidget,
                    if (subtitleValue.isNotEmpty)
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: isMobileSize ? double.infinity : 500.0,
                          minWidth: isMobileSize ? 0.0 : 500.0,
                        ),
                        child: Opacity(
                          opacity: 0.4,
                          child: Text(
                            subtitleValue,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: Utilities.fonts.body(
                              fontSize: isMobileSize ? 14.0 : 16.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
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
