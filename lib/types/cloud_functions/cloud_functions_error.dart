import 'package:cloud_functions/cloud_functions.dart';

class CloudFunctionsError {
  CloudFunctionsError({
    this.message = '',
    this.code = '',
    this.details = '',
  });

  final String message;
  final String code;
  final String details;

  factory CloudFunctionsError.fromException(
      FirebaseFunctionsException exception) {
    final _details = exception.details;

    final String _code = _details != null ? exception.details['code'] : '';
    final String _message = _details != null ? _details['message'] : '';

    return CloudFunctionsError(
      code: _code,
      message: _message,
      details: '',
    );
  }

  factory CloudFunctionsError.empty() {
    return CloudFunctionsError(
      message: '',
      code: '',
      details: '',
    );
  }

  factory CloudFunctionsError.fromJSON(Map<dynamic, dynamic>? data) {
    if (data == null) {
      return CloudFunctionsError.empty();
    }

    return CloudFunctionsError(
      message: data['message'] ?? '',
      code: data['code'] ?? '',
      details: data['details'] ?? '',
    );
  }

  factory CloudFunctionsError.fromMessage(String? message) {
    return CloudFunctionsError(
      message: message ?? '',
      code: '',
      details: '',
    );
  }
}
