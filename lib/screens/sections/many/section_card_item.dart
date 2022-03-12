import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/section.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class SectionCardItem extends StatefulWidget {
  const SectionCardItem({
    Key? key,
    required this.section,
    required this.index,
    this.onTap,
    this.onDelete,
    this.onEdit,
  }) : super(key: key);

  final int index;
  final void Function(Section, int)? onTap;

  /// onDelete callback function (after selecting 'delete' item menu)
  final Function(Section, int)? onDelete;

  /// onEdit callback function (after selecting 'edit' item menu)
  final Function(Section, int)? onEdit;

  final Section section;

  @override
  State<SectionCardItem> createState() => _SectionCardItemState();
}

class _SectionCardItemState extends State<SectionCardItem> {
  Color _borderColor = Colors.pink;
  Color _textBgColor = Colors.transparent;
  double _elevation = 2.0;
  double _borderWidth = 2.0;

  @override
  Widget build(BuildContext context) {
    final section = widget.section;

    if (_borderColor == Colors.pink) {
      _borderColor = Theme.of(context).primaryColor.withOpacity(0.6);
    }

    return SizedBox(
      width: 260.0,
      height: 300.0,
      child: Card(
        elevation: _elevation,
        color: Theme.of(context).backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6.0),
          side: BorderSide(
            color: _borderColor,
            width: _borderWidth,
          ),
        ),
        child: InkWell(
          onTap: () => widget.onTap?.call(widget.section, widget.index),
          onHover: (isHover) {
            setState(() {
              _elevation = isHover ? 4.0 : 2.0;
              _borderColor = isHover
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).primaryColor.withOpacity(0.6);
              _borderWidth = isHover ? 3.0 : 2.0;
              _textBgColor = isHover ? Colors.amber : Colors.transparent;
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Opacity(
                    opacity: 0.6,
                    child: Icon(
                      Utilities.ui.getSectionIcon(section.id),
                      size: 32.0,
                    ),
                  ),
                ),
                Hero(
                  tag: section.id,
                  child: Opacity(
                    opacity: 0.8,
                    child: Text(
                      "section_name.${section.id}".tr(),
                      maxLines: 2,
                      style: Utilities.fonts.style(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w800,
                        backgroundColor: _textBgColor,
                      ),
                    ),
                  ),
                ),
                Opacity(
                  opacity: 0.4,
                  child: Text(
                    "section_description.${section.id}".tr(),
                    maxLines: 5,
                    textAlign: TextAlign.center,
                    style: Utilities.fonts.style(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
