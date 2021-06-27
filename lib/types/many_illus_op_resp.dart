import 'package:artbooking/types/cloud_func_error.dart';
import 'package:artbooking/types/processed_illus.dart';
import 'package:artbooking/types/user/partial_user.dart';
import 'package:cloud_functions/cloud_functions.dart';

class ManyIllusOpResp {
  bool hasErrors;
  final int? successCount;
  final List<ProcessedIllustration> illustrations;
  final String message;
  final CloudFuncError? error;
  final PartialUser? user;

  ManyIllusOpResp({
    this.illustrations = const [],
    this.hasErrors = false,
    this.message = '',
    this.error,
    this.successCount = 0,
    this.user,
  });

  factory ManyIllusOpResp.fromException(FirebaseFunctionsException exception) {
    return ManyIllusOpResp(
      error: CloudFuncError.fromException(exception),
      hasErrors: true,
      illustrations: [],
      user: PartialUser.empty(),
    );
  }

  factory ManyIllusOpResp.empty() {
    return ManyIllusOpResp(
      error: CloudFuncError.empty(),
      hasErrors: true,
      illustrations: [],
      user: PartialUser.empty(),
    );
  }

  factory ManyIllusOpResp.fromJSON(Map<dynamic, dynamic>? data) {
    if (data == null) {
      return ManyIllusOpResp.empty();
    }

    final _illustrations = <ProcessedIllustration>[];

    if (data['items'] != null) {
      for (Map<dynamic, dynamic> item in data['items']) {
        _illustrations.add(ProcessedIllustration.fromJSON(item));
      }
    }

    return ManyIllusOpResp(
      illustrations: _illustrations,
      successCount: data['successCount'],
      hasErrors: data['hasErrors'] ?? true,
      user: PartialUser.fromJSON(data['user']),
      error: CloudFuncError.fromJSON(data['error']),
    );
  }

  factory ManyIllusOpResp.fromMessage(String message) {
    return ManyIllusOpResp(
      hasErrors: true,
      illustrations: [],
      error: CloudFuncError.fromMessage(message),
      user: PartialUser(),
    );
  }
}
