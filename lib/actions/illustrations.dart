import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/cloud_functions/check_urls_response.dart';
import 'package:artbooking/types/cloud_functions/illustrations_response.dart';
import 'package:artbooking/types/cloud_functions/illustration_response.dart';
import 'package:artbooking/types/enums/enum_content_visibility.dart';
import 'package:artbooking/types/illustration/illustration.dart';
import 'package:artbooking/types/license/license.dart';
import 'package:cloud_functions/cloud_functions.dart';

class IllustrationsActions {
  /// Check an illustration document in Firestore from its id [illustrationId].
  /// If the document has missing properties, try to populate them from storage file.
  /// If there's no corresponding storage file, delete the firestore document.
  /// (The missing values may be due to a cloud function execution error)
  static Future<CheckPropertiesResponse> checkProperties({
    required String illustrationId,
  }) async {
    try {
      final response =
          await Utilities.cloud.fun('illustrations-checkProperties').call({
        'illustrationId': illustrationId,
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
      final response =
          await Utilities.cloud.fun('illustrations-createOne').call({
        'name': name,
        'visibility': Illustration.visibilityPropToString(visibility),
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
      final response =
          await Utilities.cloud.fun('illustrations-deleteOne').call({
        'illustrationId': illustrationId,
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
      final response =
          await Utilities.cloud.fun('illustrations-deleteMany').call({
        'illustrationIds': illustrationIds,
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

  static Future<IllustrationResponse> updateMetadata({
    String? name,
    String? description,
    String? summary,
    required License license,
    EnumContentVisibility visibility = EnumContentVisibility.private,
    required Illustration illustration,
  }) async {
    try {
      final response =
          await Utilities.cloud.fun('illustrations-updateMetadata').call({
        'illustrationId': illustration.id,
        'name': name,
        'description': description,
        'summary': summary,
        'license': license.toJSON(),
        'visibility': Illustration.visibilityPropToString(visibility),
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
}
