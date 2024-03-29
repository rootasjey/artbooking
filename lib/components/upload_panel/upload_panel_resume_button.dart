import 'package:artbooking/components/buttons/circle_button.dart';
import 'package:artbooking/globals/app_state.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicons/unicons.dart';

class UploadPanelResumeButton extends ConsumerWidget {
  const UploadPanelResumeButton({
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
        ref.read(AppState.uploadTaskListProvider.notifier).resumeAll();
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
