import 'package:artbooking/globals/utilities.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:artbooking/types/cloud_functions/cloud_functions_error.dart';
import 'package:artbooking/types/cloud_functions/create_account_response.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Network interface for user's actions.
class UsersActions {
  /// Check email availability accross the app.
  static Future<bool> checkEmailAvailability(String email) async {
    try {
      final response = await Utilities.cloud
          .fun("users-checkEmailAvailability")
          .call({"email": email});

      final isAvailable = response.data["isAvailable"] as bool?;
      return isAvailable ?? false;
    } on FirebaseFunctionsException catch (exception) {
      debugPrint("[code: ${exception.code}] - ${exception.message}");
      return false;
    } catch (error) {
      debugPrint(error.toString());
      return false;
    }
  }

  /// Create a new account.
  static Future<CreateAccountResponse> createAccount({
    required String email,
    required String username,
    required String password,
  }) async {
    try {
      final response = await Utilities.cloud.fun("users-createAccount").call({
        "username": username,
        "password": password,
        "email": email,
      });

      return CreateAccountResponse.fromJSON(response.data);
    } on FirebaseFunctionsException catch (exception) {
      debugPrint("[code: ${exception.code}] - ${exception.message}");
      return CreateAccountResponse(
        success: false,
        error: CloudFunctionsError(
          code: exception.code,
          message: exception.message ?? '',
        ),
      );
    } catch (error) {
      return CreateAccountResponse(
        success: false,
        error: CloudFunctionsError(
          code: '',
          message: error.toString(),
        ),
      );
    }
  }

  /// Check email format.
  static bool checkEmailFormat(String email) {
    return RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]{2,}")
        .hasMatch(email);
  }

  /// Check username availability.
  static Future<bool> checkUsernameAvailability(String username) async {
    try {
      final response = await Utilities.cloud
          .fun("users-checkUsernameAvailability")
          .call({"usernname": username});

      final isAvailable = response.data["isAvailable"] as bool?;
      return isAvailable ?? false;
    } on FirebaseFunctionsException catch (exception) {
      debugPrint("[code: ${exception.code}] - ${exception.message}");
      return false;
    } catch (error) {
      debugPrint(error.toString());
      return false;
    }
  }

  /// Check username format.
  /// Must contains 3 or more alpha-numerical characters.
  static bool checkUsernameFormat(String username) {
    final str = RegExp("[a-zA-Z0-9_]{3,}").stringMatch(username);
    return username == str;
  }
}
