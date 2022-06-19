import 'package:artbooking/globals/utilities.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:unicons/unicons.dart';

/// Wrap "created at" and "updated at" dates in chips.
class DatesWrap extends StatelessWidget {
  const DatesWrap({
    Key? key,
    required this.createdAt,
    required this.updatedAt,
    this.margin = EdgeInsets.zero,
  }) : super(key: key);

  /// DateTime when this section was created.
  final DateTime createdAt;

  /// Last time this this section updated.
  final DateTime updatedAt;

  /// External padding (blank space around this widget).
  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    String createdAtString = "";
    String updatedAtString = "";

    final Duration createdAtDiff = DateTime.now().difference(createdAt);

    if (createdAtDiff.inDays > 15) {
      createdAtString = Jiffy(createdAt).yMMMd;
    } else {
      createdAtString = "date_created_ago".tr(
        args: [Jiffy(createdAt).fromNow()],
      ).toLowerCase();
    }

    if (createdAt.compareTo(updatedAt) != 0) {
      final Duration updatedAtDiff = DateTime.now().difference(updatedAt);

      if (updatedAtDiff.inDays > 15) {
        updatedAtString = Jiffy(createdAt).yMMMd;
      } else {
        updatedAtString = "date_updated_ago"
            .tr(args: [Jiffy(updatedAt).fromNow()]).toLowerCase();
      }
    }

    return Padding(
      padding: margin,
      child: Wrap(
        spacing: 12.0,
        runSpacing: 12.0,
        children: [
          Chip(
            avatar: CircleAvatar(
              child: Icon(UniconsLine.jackhammer, size: 16.0),
              backgroundColor: Colors.white38,
              foregroundColor: Colors.black54,
            ),
            label: Opacity(
              opacity: 0.8,
              child: Text(
                createdAtString,
                style: Utilities.fonts.body(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          if (updatedAtString.isNotEmpty)
            Chip(
              avatar: CircleAvatar(
                child: Icon(UniconsLine.refresh, size: 16.0),
                backgroundColor: Colors.white38,
                foregroundColor: Colors.black54,
              ),
              label: Opacity(
                opacity: 0.8,
                child: Text(
                  updatedAtString,
                  style: Utilities.fonts.body(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
