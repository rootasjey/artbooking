// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upload_manager.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$UploadManager on UploadManagerBase, Store {
  final _$showUploadWindowAtom =
      Atom(name: 'UploadManagerBase.showUploadWindow');

  @override
  bool get showUploadWindow {
    _$showUploadWindowAtom.reportRead();
    return super.showUploadWindow;
  }

  @override
  set showUploadWindow(bool value) {
    _$showUploadWindowAtom.reportWrite(value, super.showUploadWindow, () {
      super.showUploadWindow = value;
    });
  }

  final _$uploadTasksListAtom = Atom(name: 'UploadManagerBase.uploadTasksList');

  @override
  List<CustomUploadTask> get uploadTasksList {
    _$uploadTasksListAtom.reportRead();
    return super.uploadTasksList;
  }

  @override
  set uploadTasksList(List<CustomUploadTask> value) {
    _$uploadTasksListAtom.reportWrite(value, super.uploadTasksList, () {
      super.uploadTasksList = value;
    });
  }

  final _$toDeleteTasksListAtom =
      Atom(name: 'UploadManagerBase.toDeleteTasksList');

  @override
  List<CustomUploadTask> get toDeleteTasksList {
    _$toDeleteTasksListAtom.reportRead();
    return super.toDeleteTasksList;
  }

  @override
  set toDeleteTasksList(List<CustomUploadTask> value) {
    _$toDeleteTasksListAtom.reportWrite(value, super.toDeleteTasksList, () {
      super.toDeleteTasksList = value;
    });
  }

  final _$bytesTransferredAtom =
      Atom(name: 'UploadManagerBase.bytesTransferred');

  @override
  int get bytesTransferred {
    _$bytesTransferredAtom.reportRead();
    return super.bytesTransferred;
  }

  @override
  set bytesTransferred(int value) {
    _$bytesTransferredAtom.reportWrite(value, super.bytesTransferred, () {
      super.bytesTransferred = value;
    });
  }

  final _$totalBytesAtom = Atom(name: 'UploadManagerBase.totalBytes');

  @override
  int get totalBytes {
    _$totalBytesAtom.reportRead();
    return super.totalBytes;
  }

  @override
  set totalBytes(int value) {
    _$totalBytesAtom.reportWrite(value, super.totalBytes, () {
      super.totalBytes = value;
    });
  }

  final _$addedTasksCountAtom = Atom(name: 'UploadManagerBase.addedTasksCount');

  @override
  int get addedTasksCount {
    _$addedTasksCountAtom.reportRead();
    return super.addedTasksCount;
  }

  @override
  set addedTasksCount(int value) {
    _$addedTasksCountAtom.reportWrite(value, super.addedTasksCount, () {
      super.addedTasksCount = value;
    });
  }

  final _$pausedTasksCountAtom =
      Atom(name: 'UploadManagerBase.pausedTasksCount');

  @override
  int get pausedTasksCount {
    _$pausedTasksCountAtom.reportRead();
    return super.pausedTasksCount;
  }

  @override
  set pausedTasksCount(int value) {
    _$pausedTasksCountAtom.reportWrite(value, super.pausedTasksCount, () {
      super.pausedTasksCount = value;
    });
  }

  final _$runningTasksCountAtom =
      Atom(name: 'UploadManagerBase.runningTasksCount');

  @override
  int get runningTasksCount {
    _$runningTasksCountAtom.reportRead();
    return super.runningTasksCount;
  }

  @override
  set runningTasksCount(int value) {
    _$runningTasksCountAtom.reportWrite(value, super.runningTasksCount, () {
      super.runningTasksCount = value;
    });
  }

  final _$successTasksCountAtom =
      Atom(name: 'UploadManagerBase.successTasksCount');

  @override
  int get successTasksCount {
    _$successTasksCountAtom.reportRead();
    return super.successTasksCount;
  }

  @override
  set successTasksCount(int value) {
    _$successTasksCountAtom.reportWrite(value, super.successTasksCount, () {
      super.successTasksCount = value;
    });
  }

  final _$abortedTasksCountAtom =
      Atom(name: 'UploadManagerBase.abortedTasksCount');

  @override
  int get abortedTasksCount {
    _$abortedTasksCountAtom.reportRead();
    return super.abortedTasksCount;
  }

  @override
  set abortedTasksCount(int value) {
    _$abortedTasksCountAtom.reportWrite(value, super.abortedTasksCount, () {
      super.abortedTasksCount = value;
    });
  }

  final _$UploadManagerBaseActionController =
      ActionController(name: 'UploadManagerBase');

  @override
  void addCustomUploadTask(CustomUploadTask customUploadTask) {
    final _$actionInfo = _$UploadManagerBaseActionController.startAction(
        name: 'UploadManagerBase.addCustomUploadTask');
    try {
      return super.addCustomUploadTask(customUploadTask);
    } finally {
      _$UploadManagerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void _addUploadTask(
      UploadTask uploadTask, CustomUploadTask customUploadTask) {
    final _$actionInfo = _$UploadManagerBaseActionController.startAction(
        name: 'UploadManagerBase._addUploadTask');
    try {
      return super._addUploadTask(uploadTask, customUploadTask);
    } finally {
      _$UploadManagerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void removeCustomUploadTask(CustomUploadTask customUploadTask) {
    final _$actionInfo = _$UploadManagerBaseActionController.startAction(
        name: 'UploadManagerBase.removeCustomUploadTask');
    try {
      return super.removeCustomUploadTask(customUploadTask);
    } finally {
      _$UploadManagerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void _addToTotalBytes(int amount) {
    final _$actionInfo = _$UploadManagerBaseActionController.startAction(
        name: 'UploadManagerBase._addToTotalBytes');
    try {
      return super._addToTotalBytes(amount);
    } finally {
      _$UploadManagerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void _removeFromTotalBytes(int amount) {
    final _$actionInfo = _$UploadManagerBaseActionController.startAction(
        name: 'UploadManagerBase._removeFromTotalBytes');
    try {
      return super._removeFromTotalBytes(amount);
    } finally {
      _$UploadManagerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void _resetTotalBytes() {
    final _$actionInfo = _$UploadManagerBaseActionController.startAction(
        name: 'UploadManagerBase._resetTotalBytes');
    try {
      return super._resetTotalBytes();
    } finally {
      _$UploadManagerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void _resetBytesTransferred() {
    final _$actionInfo = _$UploadManagerBaseActionController.startAction(
        name: 'UploadManagerBase._resetBytesTransferred');
    try {
      return super._resetBytesTransferred();
    } finally {
      _$UploadManagerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void addToBytesTransferred(int amount) {
    final _$actionInfo = _$UploadManagerBaseActionController.startAction(
        name: 'UploadManagerBase.addToBytesTransferred');
    try {
      return super.addToBytesTransferred(amount);
    } finally {
      _$UploadManagerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void removeFromBytesTransferred(int amount) {
    final _$actionInfo = _$UploadManagerBaseActionController.startAction(
        name: 'UploadManagerBase.removeFromBytesTransferred');
    try {
      return super.removeFromBytesTransferred(amount);
    } finally {
      _$UploadManagerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setUploadWindowsVisibility(bool show) {
    final _$actionInfo = _$UploadManagerBaseActionController.startAction(
        name: 'UploadManagerBase.setUploadWindowsVisibility');
    try {
      return super.setUploadWindowsVisibility(show);
    } finally {
      _$UploadManagerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void _incrAddedTasks(int amount) {
    final _$actionInfo = _$UploadManagerBaseActionController.startAction(
        name: 'UploadManagerBase._incrAddedTasks');
    try {
      return super._incrAddedTasks(amount);
    } finally {
      _$UploadManagerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void _decrAddedTasks(int amount) {
    final _$actionInfo = _$UploadManagerBaseActionController.startAction(
        name: 'UploadManagerBase._decrAddedTasks');
    try {
      return super._decrAddedTasks(amount);
    } finally {
      _$UploadManagerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void _setAddedTasksCount(int value) {
    final _$actionInfo = _$UploadManagerBaseActionController.startAction(
        name: 'UploadManagerBase._setAddedTasksCount');
    try {
      return super._setAddedTasksCount(value);
    } finally {
      _$UploadManagerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void _setPausedTasksCount(int value) {
    final _$actionInfo = _$UploadManagerBaseActionController.startAction(
        name: 'UploadManagerBase._setPausedTasksCount');
    try {
      return super._setPausedTasksCount(value);
    } finally {
      _$UploadManagerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void _setRunningTasksCount(int value) {
    final _$actionInfo = _$UploadManagerBaseActionController.startAction(
        name: 'UploadManagerBase._setRunningTasksCount');
    try {
      return super._setRunningTasksCount(value);
    } finally {
      _$UploadManagerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void _setAbortedTasksCount(int value) {
    final _$actionInfo = _$UploadManagerBaseActionController.startAction(
        name: 'UploadManagerBase._setAbortedTasksCount');
    try {
      return super._setAbortedTasksCount(value);
    } finally {
      _$UploadManagerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void _setSuccessTasksCount(int value) {
    final _$actionInfo = _$UploadManagerBaseActionController.startAction(
        name: 'UploadManagerBase._setSuccessTasksCount');
    try {
      return super._setSuccessTasksCount(value);
    } finally {
      _$UploadManagerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void _incrPausedTasks(int amount) {
    final _$actionInfo = _$UploadManagerBaseActionController.startAction(
        name: 'UploadManagerBase._incrPausedTasks');
    try {
      return super._incrPausedTasks(amount);
    } finally {
      _$UploadManagerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void _decrPausedTasks(int amount) {
    final _$actionInfo = _$UploadManagerBaseActionController.startAction(
        name: 'UploadManagerBase._decrPausedTasks');
    try {
      return super._decrPausedTasks(amount);
    } finally {
      _$UploadManagerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void _incrRunningTasks(int amount) {
    final _$actionInfo = _$UploadManagerBaseActionController.startAction(
        name: 'UploadManagerBase._incrRunningTasks');
    try {
      return super._incrRunningTasks(amount);
    } finally {
      _$UploadManagerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void _decrRunningTasks(int amount) {
    final _$actionInfo = _$UploadManagerBaseActionController.startAction(
        name: 'UploadManagerBase._decrRunningTasks');
    try {
      return super._decrRunningTasks(amount);
    } finally {
      _$UploadManagerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void _decrSuccessTasks(int amount) {
    final _$actionInfo = _$UploadManagerBaseActionController.startAction(
        name: 'UploadManagerBase._decrSuccessTasks');
    try {
      return super._decrSuccessTasks(amount);
    } finally {
      _$UploadManagerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void _incrSuccessTasks(int amount) {
    final _$actionInfo = _$UploadManagerBaseActionController.startAction(
        name: 'UploadManagerBase._incrSuccessTasks');
    try {
      return super._incrSuccessTasks(amount);
    } finally {
      _$UploadManagerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void _decrAbortedTask(int amount) {
    final _$actionInfo = _$UploadManagerBaseActionController.startAction(
        name: 'UploadManagerBase._decrAbortedTask');
    try {
      return super._decrAbortedTask(amount);
    } finally {
      _$UploadManagerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void _incrAbortedTasks(int amount) {
    final _$actionInfo = _$UploadManagerBaseActionController.startAction(
        name: 'UploadManagerBase._incrAbortedTasks');
    try {
      return super._incrAbortedTasks(amount);
    } finally {
      _$UploadManagerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
showUploadWindow: ${showUploadWindow},
uploadTasksList: ${uploadTasksList},
toDeleteTasksList: ${toDeleteTasksList},
bytesTransferred: ${bytesTransferred},
totalBytes: ${totalBytes},
addedTasksCount: ${addedTasksCount},
pausedTasksCount: ${pausedTasksCount},
runningTasksCount: ${runningTasksCount},
successTasksCount: ${successTasksCount},
abortedTasksCount: ${abortedTasksCount}
    ''';
  }
}
