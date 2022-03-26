import 'package:artbooking/components/upload_panel/upload_panel_item_card.dart';
import 'package:artbooking/router/locations/atelier_location.dart';
import 'package:artbooking/types/custom_upload_task.dart';
import 'package:artbooking/globals/app_state.dart';
import 'package:beamer/beamer.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UploadWindowBody extends ConsumerWidget {
  const UploadWindowBody({
    Key? key,
    required this.expanded,
    required this.uploadTaskList,
    this.onToggleExpanded,
  }) : super(key: key);

  final bool expanded;
  final List<CustomUploadTask> uploadTaskList;
  final void Function()? onToggleExpanded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!expanded) {
      return Container();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(
            thickness: 1.5,
            color: Colors.black12,
            height: 20.0,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: uploadTaskList.map((customUploadTask) {
              return UploadPanelItemCard(
                customUploadTask: customUploadTask,
                onTap: () {
                  final String illustrationId =
                      customUploadTask.illustrationId ?? "";

                  if (illustrationId.isEmpty) {
                    return;
                  }

                  if (customUploadTask.task?.snapshot.state ==
                      TaskState.success) {
                    onToggleExpanded?.call();

                    final String route =
                        AtelierLocationContent.illustrationRoute.replaceFirst(
                      ":illustrationId",
                      illustrationId,
                    );

                    Beamer.of(context).beamToNamed(route, data: {
                      "illustrationId": illustrationId,
                    });
                  }
                },
                onCancel: () {
                  final int bytesTransferred =
                      customUploadTask.task?.snapshot.bytesTransferred ?? 0;

                  ref
                      .read(AppState.uploadBytesTransferredProvider.notifier)
                      .remove(bytesTransferred);
                  ref
                      .read(AppState.uploadTaskListProvider.notifier)
                      .cancel(customUploadTask);
                },
                onDone: () {
                  final int totalBytes =
                      customUploadTask.task?.snapshot.totalBytes ?? 0;

                  ref
                      .read(AppState.uploadBytesTransferredProvider.notifier)
                      .remove(totalBytes);
                  ref
                      .read(AppState.uploadTaskListProvider.notifier)
                      .removeDone(customUploadTask);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
