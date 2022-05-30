import 'dart:async';

import 'package:artbooking/components/buttons/circle_button.dart';
import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/types/drag_data.dart';
import 'package:artbooking/types/section.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:supercharged/supercharged.dart';
import 'package:unicons/unicons.dart';

class LineDropZone extends StatefulWidget {
  const LineDropZone({
    Key? key,
    required this.index,
    this.backgroundColor = Colors.transparent,
    this.onShowAddSection,
    this.onDropSection,
  }) : super(key: key);

  final int index;
  final Color backgroundColor;
  final void Function(int index)? onShowAddSection;

  /// Callback when drag and dropping items on this book card.
  final void Function(
    int dropTargetIndex,
    List<int> dragIndexes,
  )? onDropSection;

  @override
  State<LineDropZone> createState() => _LineDropZoneState();
}

class _LineDropZoneState extends State<LineDropZone> {
  Color _baseColor = Colors.transparent;
  Color _dividerColor = Colors.transparent;
  Color _hoverColor = Constants.colors.tertiary;

  double _containerHeight = 16.0;
  double _iconHeight = 0.0;

  Timer? _iconAnimationTimer;

  @override
  void dispose() {
    _iconAnimationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: InkWell(
        onTap: () {
          widget.onShowAddSection?.call(widget.index);
        },
        onHover: (isHover) {
          if (!isHover) {
            _iconHeight = 0.0;
            _iconAnimationTimer?.cancel();
          } else {
            _iconAnimationTimer?.cancel();
            _iconAnimationTimer = Timer(
              150.milliseconds,
              () => setState(() => _iconHeight = 30.0),
            );
          }

          setState(() {
            _dividerColor = isHover ? _hoverColor : _baseColor;
            _containerHeight = isHover ? 30.0 : 16.0;
          });
        },
        child: AnimatedContainer(
          height: _containerHeight,
          duration: Duration(milliseconds: 250),
          color: widget.backgroundColor,
          child: DragTarget<DragData>(
            builder: (
              BuildContext context,
              List<DragData?> candidateData,
              List rejectedData,
            ) {
              IconData iconData = UniconsLine.plus;
              Color accentColor = _dividerColor;
              Color iconColor = Colors.black;

              if (candidateData.isNotEmpty) {
                accentColor = Colors.green.shade300;
                iconColor = Colors.white;
                iconData = UniconsLine.map_marker_plus;
              }

              return Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Divider(
                      thickness: 4.0,
                      color: accentColor,
                    ),
                  ),
                  Positioned(
                    left: 0.0,
                    right: 0.0,
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 100),
                      height: _iconHeight,
                      child: Opacity(
                        opacity: 1.0,
                        child: CircleButton(
                          backgroundColor: accentColor,
                          tooltip: "section_add_new".tr(),
                          onTap: () {
                            widget.onShowAddSection?.call(widget.index);
                          },
                          icon: Icon(
                            iconData,
                            color: iconColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
            onAccept: (DragData dragData) {
              widget.onDropSection?.call(widget.index, [dragData.index]);
            },
            onWillAccept: (DragData? dragData) {
              if (dragData == null) {
                return false;
              }

              if (dragData.type != Section) {
                return false;
              }

              return true;
            },
          ),
        ),
      ),
    );
  }
}
