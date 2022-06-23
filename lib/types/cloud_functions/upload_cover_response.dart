import 'dart:convert';

import 'package:file_picker_cross/file_picker_cross.dart';

/// An operation response when trying to upload a custom cover for a book.
class UploadCoverResponse {
  UploadCoverResponse({
    required this.success,
    required this.errorMessage,
    this.file,
  });

  /// The operation succeeded if true.
  final bool success;

  /// Error message.
  final String errorMessage;

  /// File which was selected if any.
  final FilePickerCross? file;

  UploadCoverResponse copyWith({
    bool? success,
    String? errorMessage,
    FilePickerCross? file,
  }) {
    return UploadCoverResponse(
      success: success ?? this.success,
      errorMessage: errorMessage ?? this.errorMessage,
      file: file ?? this.file,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'success': success,
      'errorMessage': errorMessage,
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'UploadCoverResponse(success: $success, errorMessage: $errorMessage, file: $file)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UploadCoverResponse &&
        other.success == success &&
        other.errorMessage == errorMessage &&
        other.file == file;
  }

  @override
  int get hashCode => success.hashCode ^ errorMessage.hashCode ^ file.hashCode;
}
