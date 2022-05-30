import 'package:artbooking/components/buttons/circle_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
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
  bool _isHover = false;
  Color _color = Colors.transparent;
  Color _baseColor = Colors.transparent;
  Color _hoverColor = Colors.pink;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: InkWell(
        onTap: () {
          widget.onShowAddSection?.call(widget.index);
        },
        onHover: (isHover) {
          setState(() {
            _color = isHover ? _hoverColor : _baseColor;
            _isHover = isHover;
          });
        },
        child: Container(
          color: widget.backgroundColor,
          child: Column(
            children: [
              Divider(
                thickness: 4.0,
                color: _color,
              ),
              if (_isHover)
                CircleButton(
                  tooltip: "section_add_new".tr(),
                  onTap: () {
                    widget.onShowAddSection?.call(widget.index);
                  },
                  icon: Icon(
                    UniconsLine.plus,
                    color: Colors.black,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
