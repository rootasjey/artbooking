import 'package:artbooking/types/globals/globals.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicons/unicons.dart';

// TODO: rename "upload button"
class AddButton extends ConsumerWidget {
  const AddButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      tooltip: "upload".tr(),
      onPressed: () {
        ref.read(Globals.state.upload.uploadTasksList.notifier).pickImage();
      },
      icon: Icon(
        UniconsLine.plus,
        color: Theme.of(context).textTheme.bodyText1?.color?.withOpacity(0.6),
      ),
    );
  }
}
