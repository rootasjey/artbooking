import 'package:artbooking/types/cloud_func_error.dart';
import 'package:artbooking/types/create_image_doc_resp.dart';
import 'package:artbooking/types/enums.dart';
import 'package:artbooking/types/illustration/illustration.dart';
import 'package:artbooking/types/illustration/license.dart';
import 'package:artbooking/utils/app_logger.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class IllustrationsActions {
  static Future<CreateImageDocResp> createDoc({
    @required String name,
    ContentVisibility visibility = ContentVisibility.private,
  }) async {
    try {
      final callable = FirebaseFunctions.instanceFor(
        app: Firebase.app(),
        region: 'europe-west3',
      ).httpsCallable(
        'illustrations-createOne',
      );

      final response = await callable.call({
        'name': name,
        'visibility': Illustration.visibilityPropToString(visibility),
      });

      return CreateImageDocResp.fromJSON(response.data);
    } on FirebaseFunctionsException catch (exception) {
      appLogger.e(exception);
      return CreateImageDocResp(
        success: false,
        error: CloudFuncError(
          code: exception.details != null ? exception.details['code'] : '',
          message:
              exception.details != null ? exception.details['message'] : '',
        ),
      );
    } catch (error) {
      appLogger.e(error);

      return CreateImageDocResp(
        success: false,
        error: CloudFuncError(
          code: '',
          message: error.toString(),
        ),
      );
    }
  }

  static Future<CreateImageDocResp> deleteDoc({
    @required String imageId,
  }) async {
    try {
      final callable = FirebaseFunctions.instanceFor(
        app: Firebase.app(),
        region: 'europe-west3',
      ).httpsCallable(
        'illustrations-deleteOne',
      );

      final response = await callable.call({
        'id': imageId,
      });

      return CreateImageDocResp.fromJSON(response.data);
    } on FirebaseFunctionsException catch (exception) {
      appLogger.e(exception);
      return CreateImageDocResp(
        success: false,
        error: CloudFuncError(
          code: exception.details != null ? exception.details['code'] : '',
          message:
              exception.details != null ? exception.details['message'] : '',
        ),
      );
    } catch (error) {
      appLogger.e(error);

      return CreateImageDocResp(
        success: false,
        error: CloudFuncError(
          code: '',
          message: error.toString(),
        ),
      );
    }
  }

  static Future<CreateImageDocResp> deleteDocs({
    @required List<String> imagesIds,
  }) async {
    try {
      final callable = FirebaseFunctions.instanceFor(
        app: Firebase.app(),
        region: 'europe-west3',
      ).httpsCallable(
        'illustrations-deleteMany',
      );

      final response = await callable.call({
        'ids': imagesIds,
      });

      return CreateImageDocResp.fromJSON(response.data);
    } on FirebaseFunctionsException catch (exception) {
      appLogger.e(exception);
      return CreateImageDocResp(
        success: false,
        error: CloudFuncError(
          code: exception.details != null ? exception.details['code'] : '',
          message:
              exception.details != null ? exception.details['message'] : '',
        ),
      );
    } catch (error) {
      appLogger.e(error);

      return CreateImageDocResp(
        success: false,
        error: CloudFuncError(
          code: '',
          message: error.toString(),
        ),
      );
    }
  }

  static Future<CreateImageDocResp> updateMetadata({
    String name,
    String description,
    String summary,
    IllustrationLicense license,
    ContentVisibility visibility = ContentVisibility.private,
    @required Illustration illustration,
  }) async {
    try {
      final callable = FirebaseFunctions.instanceFor(
        app: Firebase.app(),
        region: 'europe-west3',
      ).httpsCallable(
        'illustrations-updateMetadata',
      );

      final response = await callable.call({
        'id': illustration.id,
        'name': name,
        'description': description,
        'summary': summary,
        'license': license.toJSON(),
        'visibility': Illustration.visibilityPropToString(visibility),
      });

      return CreateImageDocResp.fromJSON(response.data);
    } on FirebaseFunctionsException catch (exception) {
      appLogger.e(exception);
      return CreateImageDocResp(
        success: false,
        error: CloudFuncError(
          code: exception.details != null ? exception.details['code'] : '',
          message:
              exception.details != null ? exception.details['message'] : '',
        ),
      );
    } catch (error) {
      appLogger.e(error);

      return CreateImageDocResp(
        success: false,
        error: CloudFuncError(
          code: '',
          message: error.toString(),
        ),
      );
    }
  }
}
