import 'package:artbooking/components/circle_button.dart';
import 'package:artbooking/types/globals/app_state.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicons/unicons.dart';

class CancelButton extends ConsumerWidget {
  const CancelButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: CircleButton(
        onTap: () {
          ref.read(AppState.uploadTaskListProvider.notifier).cancelAll();
          ref.read(AppState.uploadBytesTransferredProvider.notifier).clear();
        },
        tooltip: "cancel".tr(),
        radius: 16.0,
        icon: Icon(
          UniconsLine.times,
          size: 16.0,
          color: Colors.black87,
        ),
      ),
    );
  }
}
