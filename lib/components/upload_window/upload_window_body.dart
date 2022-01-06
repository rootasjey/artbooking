import 'package:artbooking/components/upload_item_card.dart';
import 'package:artbooking/types/custom_upload_task.dart';
import 'package:artbooking/types/globals/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UploadWindowBody extends ConsumerWidget {
  const UploadWindowBody({
    Key? key,
    required this.isExpanded,
    required this.uploadTaskList,
  }) : super(key: key);

  final bool isExpanded;
  final List<CustomUploadTask> uploadTaskList;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!isExpanded) {
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
              return UploadItemCard(
                customUploadTask: customUploadTask,
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
