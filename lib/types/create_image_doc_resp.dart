import 'package:artbooking/types/cloud_func_error.dart';
import 'package:artbooking/types/partial_user.dart';

class CreateImageDocResp {
  bool success;
  final String id;
  final String message;
  final CloudFuncError error;
  final PartialUser user;

  CreateImageDocResp({
    this.id = '',
    this.success = true,
    this.message = '',
    this.error,
    this.user,
  });

  factory CreateImageDocResp.fromJSON(Map<dynamic, dynamic> data) {
    return CreateImageDocResp(
      id: data['id'],
      success: data['success'] ?? true,
      user: data['user'] != null
          ? PartialUser.fromJSON(data['user'])
          : PartialUser(),
      error: data['error'] != null
          ? CloudFuncError.fromJSON(data['error'])
          : CloudFuncError(),
    );
  }
}
