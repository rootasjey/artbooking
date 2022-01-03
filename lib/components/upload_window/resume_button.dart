import 'package:artbooking/components/circle_button.dart';
import 'package:artbooking/types/globals/globals.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicons/unicons.dart';

class ResumeButton extends ConsumerWidget {
  const ResumeButton({
    Key? key,
    required this.hide,
  }) : super(key: key);

  final bool hide;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (hide) {
      return Container();
    }

    return CircleButton(
      onTap: () {
        ref.read(Globals.state.upload.uploadTasksList.notifier).resumeAll();
      },
      radius: 16.0,
      tooltip: "resume".tr(),
      icon: Icon(
        UniconsLine.play,
        size: 16.0,
        color: Colors.black87,
      ),
    );
  }
}
