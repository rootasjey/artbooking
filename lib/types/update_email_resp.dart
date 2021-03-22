import 'package:artbooking/types/cloud_func_error.dart';
import 'package:artbooking/types/user/partial_user.dart';

class UpdateEmailResp {
  bool success;
  final CloudFuncError error;
  final PartialUser user;

  UpdateEmailResp({
    this.success = true,
    this.error,
    this.user,
  });

  factory UpdateEmailResp.fromJSON(Map<dynamic, dynamic> data) {
    return UpdateEmailResp(
      success: data['success'] ?? true,
      user: PartialUser.fromJSON(data['user']),
      error: CloudFuncError.fromJSON(data['error']),
    );
  }
}
