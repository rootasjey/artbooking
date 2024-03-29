import 'package:artbooking/components/buttons/circle_button.dart';
import 'package:artbooking/globals/app_state.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicons/unicons.dart';

class UploadPanelPauseButton extends ConsumerWidget {
  const UploadPanelPauseButton({
    Key? key,
    required this.hide,
    this.margin: const EdgeInsets.only(),
  }) : super(key: key);

  final bool hide;
  final EdgeInsets margin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (hide) {
      return Container();
    }

    return CircleButton(
      onTap: () {
        ref.read(AppState.uploadTaskListProvider.notifier).pauseAll();
      },
      radius: 16.0,
      tooltip: "pause".tr(),
      icon: Icon(
        UniconsLine.pause,
        size: 16.0,
        color: Colors.black87,
      ),
    );
  }
}
