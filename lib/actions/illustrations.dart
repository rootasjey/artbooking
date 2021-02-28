import 'package:artbooking/types/cloud_func_error.dart';
import 'package:artbooking/types/create_image_doc_resp.dart';
import 'package:artbooking/types/enums.dart';
import 'package:artbooking/utils/app_logger.dart';
import 'package:artbooking/utils/converters.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<CreateImageDocResp> createIllustrationDocument({
  @required String name,
  ContentVisibility visibility = ContentVisibility.private,
}) async {
  try {
    final callable = FirebaseFunctions.instanceFor(
      app: Firebase.app(),
      region: 'europe-west3',
    ).httpsCallable(
      'illustrations-createDocument',
    );

    final response = await callable.call({
      'name': name,
      'visibility': imageVisibilityToString(visibility),
    });

    return CreateImageDocResp.fromJSON(response.data);
  } on FirebaseFunctionsException catch (exception) {
    appLogger.e(exception);
    return CreateImageDocResp(
      success: false,
      error: CloudFuncError(
        code: exception.details != null ? exception.details['code'] : '',
        message: exception.details != null ? exception.details['message'] : '',
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

Future<CreateImageDocResp> deleteIllustrationDocument({
  @required String imageId,
}) async {
  try {
    final callable = FirebaseFunctions.instanceFor(
      app: Firebase.app(),
      region: 'europe-west3',
    ).httpsCallable(
      'illustrations-deleteDocument',
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
        message: exception.details != null ? exception.details['message'] : '',
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

Future<CreateImageDocResp> deleteIllustrationsDocuments({
  @required List<String> imagesIds,
}) async {
  try {
    final callable = FirebaseFunctions.instanceFor(
      app: Firebase.app(),
      region: 'europe-west3',
    ).httpsCallable(
      'illustrations-deleteDocuments',
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
        message: exception.details != null ? exception.details['message'] : '',
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
