import 'package:cloud_functions/cloud_functions.dart';

class CloudFuncError {
  final String message;
  final String code;
  final String details;

  CloudFuncError({
    this.message = '',
    this.code = '',
    this.details = '',
  });

  factory CloudFuncError.fromException(FirebaseFunctionsException exception) {
    final _details = exception.details;

    final String _code = _details != null ? exception.details['code'] : '';
    final String _message = _details != null ? _details['message'] : '';

    return CloudFuncError(
      code: _code,
      message: _message,
      details: '',
    );
  }

  factory CloudFuncError.empty() {
    return CloudFuncError(
      message: '',
      code: '',
      details: '',
    );
  }

  factory CloudFuncError.fromJSON(Map<dynamic, dynamic> data) {
    if (data == null) {
      return CloudFuncError.empty();
    }

    return CloudFuncError(
      message: data['message'],
      code: data['code'],
      details: data['details'],
    );
  }

  factory CloudFuncError.fromMessage(String message) {
    return CloudFuncError(
      message: message,
      code: '',
      details: '',
    );
  }
}
