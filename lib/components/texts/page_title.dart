import 'package:artbooking/globals/utilities.dart';
import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class PageTitle extends StatelessWidget {
  const PageTitle({
    Key? key,
    this.titleValue,
    required this.subtitleValue,
    this.showBackButton = false,
    this.title,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  }) : super(key: key);

  /// If specified, [titleValue] will be ignored.
  final Widget? title;

  /// String value for title.
  final String? titleValue;

  /// String value for subtitle.
  final String subtitleValue;

  /// If true, show a back icon button before title & subtitle.
  final bool showBackButton;

  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    final Widget titleWidget;

    if (title != null) {
      titleWidget = title as Widget;
    } else {
      titleWidget = Opacity(
        opacity: 0.8,
        child: Text(
          titleValue ?? '',
          style: Utilities.fonts.style(
            fontSize: 24.0,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return SliverToBoxAdapter(
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
                      onPressed: Beamer.of(context).popRoute,
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
                        style: Utilities.fonts.style(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w700,
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
  }
}
