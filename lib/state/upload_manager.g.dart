// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upload_manager.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$UploadManager on UploadManagerBase, Store {
  final _$selectedFilesAtom = Atom(name: 'UploadManagerBase.selectedFiles');

  @override
  List<PlatformFile> get selectedFiles {
    _$selectedFilesAtom.reportRead();
    return super.selectedFiles;
  }

  @override
  set selectedFiles(List<PlatformFile> value) {
    _$selectedFilesAtom.reportWrite(value, super.selectedFiles, () {
      super.selectedFiles = value;
    });
  }

  final _$UploadManagerBaseActionController =
      ActionController(name: 'UploadManagerBase');

  @override
  void setSelectedFiles(List<PlatformFile> files) {
    final _$actionInfo = _$UploadManagerBaseActionController.startAction(
        name: 'UploadManagerBase.setSelectedFiles');
    try {
      return super.setSelectedFiles(files);
    } finally {
      _$UploadManagerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void addFiles(List<PlatformFile> files) {
    final _$actionInfo = _$UploadManagerBaseActionController.startAction(
        name: 'UploadManagerBase.addFiles');
    try {
      return super.addFiles(files);
    } finally {
      _$UploadManagerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
selectedFiles: ${selectedFiles}
    ''';
  }
}
