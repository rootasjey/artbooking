import 'package:artbooking/components/animations/themed_circular_progress.dart';
import 'package:artbooking/globals/app_state.dart';
import 'package:artbooking/router/locations/atelier_location.dart';
import 'package:beamer/beamer.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicons/unicons.dart';

class ApplicationBarUploadButton extends ConsumerWidget {
  const ApplicationBarUploadButton({
    Key? key,
    this.isMobileSize = false,
  }) : super(key: key);

  /// Will behave slightly differently if true.
  /// This, in order to adapt UI to mobile size;
  final bool isMobileSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int pendingTasksCount =
        ref.watch(AppState.uploadTaskListProvider.notifier).pendingTaskCount;

    final String tooltip = pendingTasksCount > 0
        ? "illustration_uploading_files".plural(
            pendingTasksCount,
            args: [pendingTasksCount.toString()],
          )
        : "upload".tr();

    return IconButton(
      tooltip: tooltip,
      onPressed: () {
        final int localPendingTasksCount =
            ref.read(AppState.uploadTaskListProvider.notifier).pendingTaskCount;

        if (localPendingTasksCount > 0) {
          Beamer.of(context).beamToNamed(
            AtelierLocationContent.illustrationsRoute,
          );
          return;
        }

        ref.read(AppState.uploadTaskListProvider.notifier).pickImage();
      },
      icon: Stack(
        children: [
          Positioned(
            left: isMobileSize ? 4.0 : 0.0,
            top: isMobileSize ? 2.0 : 0.0,
            child: Icon(
              UniconsLine.upload,
              color: Theme.of(context)
                  .textTheme
                  .bodyText1
                  ?.color
                  ?.withOpacity(0.6),
            ),
          ),
          if (pendingTasksCount > 0) ThemedCircularProgress(),
        ],
      ),
    );
  }
}
