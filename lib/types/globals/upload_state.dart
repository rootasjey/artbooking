import 'package:artbooking/types/custom_upload_task.dart';
import 'package:artbooking/types/globals/upload_task_list_notifier.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UploadState {
  final uploadTasksList = uploadTasksListProvider;
  final hasTasks = hasTasksProvider;
  final successTaskCount = successTaskCountProvider;
  final runningTaskCount = runningTaskCountProvider;
  final pausedTaskCount = pausedTaskCountProvider;
  final abortedTaskCount = abortedTaskCountProvider;
  final totalBytes = totalBytesProvider;
  final uploadBytesTransFerred = uploadBytesTransferredProvider;
  final showUploadWindow = showUploadWindowProvider;
  final uploadPercentage = uploadPercentageProvider;
}

final uploadTasksListProvider =
    StateNotifierProvider<UploadTaskListNotifier, List<CustomUploadTask>>(
  (ref) => UploadTaskListNotifier([]),
);

final hasTasksProvider = Provider<bool>((ref) {
  final uploadTaskList = ref.watch(uploadTasksListProvider);
  return uploadTaskList.isNotEmpty;
});

final successTaskCountProvider = Provider<int>((ref) {
  return ref.watch(uploadTasksListProvider).where((uploadTask) {
    return uploadTask.task?.snapshot.state == TaskState.success;
  }).length;
});

final runningTaskCountProvider = Provider<int>((ref) {
  return ref.watch(uploadTasksListProvider).where((uploadTask) {
    return uploadTask.task?.snapshot.state == TaskState.running;
  }).length;
});

final pausedTaskCountProvider = Provider<int>((ref) {
  return ref.watch(uploadTasksListProvider).where((uploadTask) {
    return uploadTask.task?.snapshot.state == TaskState.paused;
  }).length;
});

final abortedTaskCountProvider = Provider<int>((ref) {
  return ref
      .watch(uploadTasksListProvider)
      .where((uploadTask) =>
          uploadTask.task?.snapshot.state == TaskState.canceled ||
          uploadTask.task?.snapshot.state == TaskState.error)
      .length;
});

final uploadPercentageProvider = Provider<int>((ref) {
  final int uploadBytes = ref.watch(uploadBytesTransferredProvider);
  final int totalBytes = ref.watch(totalBytesProvider);

  double ratio = uploadBytes / totalBytes;

  if (ratio.isNaN || ratio.isInfinite) {
    ratio = 0.0;
  }

  final double percent = ratio * 100;
  return percent.round();
});

final totalBytesProvider = Provider<int>((ref) {
  return ref.watch(uploadTasksListProvider).where((customTask) {
    final UploadTask? task = customTask.task;
    if (task == null) return false;

    final TaskState state = task.snapshot.state;
    return state == TaskState.running || state == TaskState.paused;
  }).fold(0, (totalBytes, customTask) {
    final int taskBytes = customTask.task?.snapshot.totalBytes ?? 0;
    return totalBytes + taskBytes;
  });
});

final uploadBytesTransferredProvider =
    StateNotifierProvider<UploadBytesTransferredNotifier, int>((ref) {
  return UploadBytesTransferredNotifier(0);
});

/// Tasks which need to be deleted asynchronously.
class DeleteTaskListNotifier extends StateNotifier<List<CustomUploadTask>> {
  DeleteTaskListNotifier(List<CustomUploadTask> state) : super(state);

  void add(CustomUploadTask customUploadTask) {
    state = [
      ...state,
      customUploadTask,
    ];
  }

  void clear() {
    state = [];
  }

  void remove(CustomUploadTask customUploadTask) {
    state = state.where((uploadTask) {
      return uploadTask.illustrationId != customUploadTask.illustrationId;
    }).toList();
  }
}

class UploadBytesTransferredNotifier extends StateNotifier<int> {
  UploadBytesTransferredNotifier(int state) : super(state);

  void add(int amount) {
    state += amount;
  }

  void clear() {
    state = 0;
  }

  void remove(int amount) {
    state -= amount;
  }
}

final showUploadWindowProvider =
    StateNotifierProvider<ShowUploadWindowNotifier, bool>((ref) {
  final bool shouldShow = ref.watch(uploadTasksListProvider).isNotEmpty;
  return ShowUploadWindowNotifier(shouldShow);
});

class ShowUploadWindowNotifier extends StateNotifier<bool> {
  ShowUploadWindowNotifier(bool state) : super(state);

  void setVisibility(bool show) {
    state = show;
  }
}
