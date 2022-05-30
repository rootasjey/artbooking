import 'dart:async';

import 'package:artbooking/components/buttons/circle_button.dart';
import 'package:artbooking/globals/constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:supercharged/supercharged.dart';
import 'package:unicons/unicons.dart';

class LineDropZone extends StatefulWidget {
  const LineDropZone({
    Key? key,
    required this.index,
    required this.usingAsDropTarget,
    this.backgroundColor = Colors.transparent,
    this.onShowAddSection,
  }) : super(key: key);

  final bool usingAsDropTarget;
  final int index;
  final Color backgroundColor;
  final void Function(int index)? onShowAddSection;

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
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Divider(
                  thickness: 4.0,
                  color: _dividerColor,
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
                      backgroundColor: _hoverColor,
                      tooltip: "section_add_new".tr(),
                      onTap: () {
                        widget.onShowAddSection?.call(widget.index);
                      },
                      icon: Icon(
                        UniconsLine.plus,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
