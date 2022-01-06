import 'package:artbooking/globals/app_state.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicons/unicons.dart';

class UploadButton extends ConsumerWidget {
  const UploadButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      tooltip: "upload".tr(),
      onPressed: () {
        ref.read(AppState.uploadTaskListProvider.notifier).pickImage();
      },
      icon: Icon(
        UniconsLine.plus,
        color: Theme.of(context).textTheme.bodyText1?.color?.withOpacity(0.6),
      ),
    );
  }
}
