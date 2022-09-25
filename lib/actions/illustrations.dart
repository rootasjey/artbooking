import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/cloud_functions/check_urls_response.dart';
import 'package:artbooking/types/cloud_functions/illustrations_response.dart';
import 'package:artbooking/types/cloud_functions/illustration_response.dart';
import 'package:artbooking/types/enums/enum_content_visibility.dart';
import 'package:cloud_functions/cloud_functions.dart';

class IllustrationsActions {
  static Future<IllustrationResponse> approve({
    required String illustrationId,
    required bool approved,
  }) async {
    try {
      final HttpsCallableResult response =
          await Utilities.cloud.fun("illustrations-approve").call({
        "illustration_id": illustrationId,
        "approved": approved,
      });

      return IllustrationResponse.fromJSON(response.data);
    } on FirebaseFunctionsException catch (exception) {
      Utilities.logger.e(exception);
      return IllustrationResponse.fromException(exception);
    } catch (error) {
      Utilities.logger.e(error);
      return IllustrationResponse.fromMessage(error.toString());
    }
  }

  /// Check an illustration document in Firestore from its id [illustrationId].
  /// If the document has missing properties, try to populate them from storage file.
  /// If there's no corresponding storage file, delete the firestore document.
  /// (The missing values may be due to a cloud function execution error)
  static Future<CheckPropertiesResponse> checkProperties({
    required String illustrationId,
  }) async {
    try {
      final HttpsCallableResult response =
          await Utilities.cloud.fun("illustrations-checkProperties").call({
        "illustration_id": illustrationId,
      });

      return CheckPropertiesResponse.fromJSON(response.data);
    } on FirebaseFunctionsException catch (exception) {
      Utilities.logger.e(exception);
      return CheckPropertiesResponse.fromException(exception);
    } catch (error) {
      Utilities.logger.e(error);
      return CheckPropertiesResponse.fromMessage(error.toString());
    }
  }

  static Future<IllustrationResponse> createOne({
    required String name,
    EnumContentVisibility visibility = EnumContentVisibility.private,
  }) async {
    try {
      final HttpsCallableResult response =
          await Utilities.cloud.fun("illustrations-createOne").call({
        "name": name,
        "visibility": visibility.name,
      });

      return IllustrationResponse.fromJSON(response.data);
    } on FirebaseFunctionsException catch (exception) {
      Utilities.logger.e(exception);
      return IllustrationResponse.fromException(exception);
    } catch (error) {
      Utilities.logger.e(error);
      return IllustrationResponse.fromMessage(error.toString());
    }
  }

  static Future<IllustrationResponse> deleteOne({
    required String illustrationId,
  }) async {
    try {
      final HttpsCallableResult response =
          await Utilities.cloud.fun("illustrations-deleteOne").call({
        "illustration_id": illustrationId,
      });

      return IllustrationResponse.fromJSON(response.data);
    } on FirebaseFunctionsException catch (exception) {
      Utilities.logger.e(exception);
      return IllustrationResponse.fromException(exception);
    } catch (error) {
      Utilities.logger.e(error);
      return IllustrationResponse.fromMessage(error.toString());
    }
  }

  static Future<IllustrationsResponse> deleteMany({
    required List<String?> illustrationIds,
  }) async {
    try {
      final HttpsCallableResult response =
          await Utilities.cloud.fun("illustrations-deleteMany").call({
        "illustration_ids": illustrationIds,
      });

      return IllustrationsResponse.fromJSON(response.data);
    } on FirebaseFunctionsException catch (exception) {
      Utilities.logger.e(exception);
      return IllustrationsResponse.fromException(exception);
    } catch (error) {
      Utilities.logger.e(error);
      return IllustrationsResponse.fromMessage(error.toString());
    }
  }
}
