import 'package:cloud_functions/cloud_functions.dart';

class CloudFunctionError {
  final String? message;
  final String? code;
  final String? details;

  CloudFunctionError({
    this.message = '',
    this.code = '',
    this.details = '',
  });

  factory CloudFunctionError.fromException(
      FirebaseFunctionsException exception) {
    final _details = exception.details;

    final String? _code = _details != null ? exception.details['code'] : '';
    final String? _message = _details != null ? _details['message'] : '';

    return CloudFunctionError(
      code: _code,
      message: _message,
      details: '',
    );
  }

  factory CloudFunctionError.empty() {
    return CloudFunctionError(
      message: '',
      code: '',
      details: '',
    );
  }

  factory CloudFunctionError.fromJSON(Map<dynamic, dynamic>? data) {
    if (data == null) {
      return CloudFunctionError.empty();
    }

    return CloudFunctionError(
      message: data['message'] ?? '',
      code: data['code'] ?? '',
      details: data['details'] ?? '',
    );
  }

  factory CloudFunctionError.fromMessage(String? message) {
    return CloudFunctionError(
      message: message ?? '',
      code: '',
      details: '',
    );
  }
}
