import 'package:artbooking/types/cloud_func_error.dart';
import 'package:artbooking/types/create_image_doc_resp.dart';
import 'package:artbooking/utils/app_logger.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class BooksActions {
  static Future create({
    @required String name,
    String description = '',
  }) async {
    try {
      final callable = FirebaseFunctions.instanceFor(
        app: Firebase.app(),
        region: 'europe-west3',
      ).httpsCallable(
        'books-createOne',
      );

      final response = await callable.call({
        'name': name,
        'description': description,
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
