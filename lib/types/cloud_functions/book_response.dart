import 'package:artbooking/types/cloud_functions/cloud_functions_error.dart';
import 'package:artbooking/types/cloud_functions/minimal_object_id.dart';
import 'package:artbooking/types/user/partial_user.dart';
import 'package:cloud_functions/cloud_functions.dart';

/// Cloud function response after performing an action on a book.
class BookResponse {
  BookResponse({
    required this.book,
    required this.error,
    this.message = "",
    this.success = false,
    required this.user,
  });

  final MinimalObjectId book;
  final CloudFunctionsError error;
  final String message;
  final bool success;
  final PartialUser user;

  factory BookResponse.empty({bool success = false}) {
    return BookResponse(
      book: MinimalObjectId.empty(),
      error: CloudFunctionsError.empty(),
      success: success,
      user: PartialUser.empty(),
    );
  }

  factory BookResponse.fromException(FirebaseFunctionsException exception) {
    return BookResponse(
      book: MinimalObjectId.empty(),
      error: CloudFunctionsError.fromException(exception),
      success: false,
      user: PartialUser.empty(),
    );
  }

  factory BookResponse.fromJSON(Map<dynamic, dynamic> data) {
    return BookResponse(
      book: MinimalObjectId.fromJSON(data["book"]),
      success: data["success"] ?? true,
      user: PartialUser.fromJSON(data["user"]),
      error: CloudFunctionsError.fromJSON(data["error"]),
    );
  }

  factory BookResponse.fromMessage(String message) {
    return BookResponse(
      success: false,
      book: MinimalObjectId.empty(),
      error: CloudFunctionsError.fromMessage(message),
      user: PartialUser(),
    );
  }
}
