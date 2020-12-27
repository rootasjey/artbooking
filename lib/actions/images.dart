import 'package:artbooking/types/cloud_func_error.dart';
import 'package:artbooking/types/create_image_doc_resp.dart';
import 'package:artbooking/types/enums.dart';
import 'package:artbooking/utils/converters.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<CreateImageDocResp> createImageDocument({
  @required String name,
  ImageVisibility visibility = ImageVisibility.private,
}) async {
  try {
    final callable = FirebaseFunctions.instanceFor(
      app: Firebase.app(),
      region: 'europe-west3',
    ).httpsCallable(
      'images-createDocument',
    );

    final response = await callable.call({
      'name': name,
      'visibility': imageVisibilityToString(visibility),
    });

    return CreateImageDocResp.fromJSON(response.data);
  } on FirebaseFunctionsException catch (exception) {
    debugPrint("[code: ${exception.code}] - ${exception.message}");
    return CreateImageDocResp(
      success: false,
      error: CloudFuncError(
        code: exception.details['code'],
        message: exception.details['message'],
      ),
    );
  } on PlatformException catch (exception) {
    debugPrint(exception.toString());

    return CreateImageDocResp(
      success: false,
      error: CloudFuncError(
        code: exception.details['code'],
        message: exception.details['message'],
      ),
    );
  } catch (error) {
    debugPrint(error.toString());

    return CreateImageDocResp(
      success: false,
      error: CloudFuncError(
        code: '',
        message: error.toString(),
      ),
    );
  }
}

Future<CreateImageDocResp> deleteImageDocument({
  @required String imageId,
}) async {
  try {
    final callable = FirebaseFunctions.instanceFor(
      app: Firebase.app(),
      region: 'europe-west3',
    ).httpsCallable(
      'images-deleteDocument',
    );

    final response = await callable.call({
      'id': imageId,
    });

    return CreateImageDocResp.fromJSON(response.data);
  } on FirebaseFunctionsException catch (exception) {
    debugPrint("[code: ${exception.code}] - ${exception.message}");
    return CreateImageDocResp(
      success: false,
      error: CloudFuncError(
        code: exception.details['code'],
        message: exception.details['message'],
      ),
    );
  } on PlatformException catch (exception) {
    debugPrint(exception.toString());

    return CreateImageDocResp(
      success: false,
      error: CloudFuncError(
        code: exception.details['code'],
        message: exception.details['message'],
      ),
    );
  } catch (error) {
    debugPrint(error.toString());

    return CreateImageDocResp(
      success: false,
      error: CloudFuncError(
        code: '',
        message: error.toString(),
      ),
    );
  }
}

Future<CreateImageDocResp> deleteImagesDocuments({
  @required List<String> imagesIds,
}) async {
  try {
    final callable = FirebaseFunctions.instanceFor(
      app: Firebase.app(),
      region: 'europe-west3',
    ).httpsCallable(
      'images-deleteDocuments',
    );

    final response = await callable.call({
      'ids': imagesIds,
    });

    return CreateImageDocResp.fromJSON(response.data);
  } on FirebaseFunctionsException catch (exception) {
    debugPrint("[code: ${exception.code}] - ${exception.message}");
    return CreateImageDocResp(
      success: false,
      error: CloudFuncError(
        code: exception.details['code'],
        message: exception.details['message'],
      ),
    );
  } on PlatformException catch (exception) {
    debugPrint(exception.toString());

    return CreateImageDocResp(
      success: false,
      error: CloudFuncError(
        code: exception.details['code'],
        message: exception.details['message'],
      ),
    );
  } catch (error) {
    debugPrint(error.toString());

    return CreateImageDocResp(
      success: false,
      error: CloudFuncError(
        code: '',
        message: error.toString(),
      ),
    );
  }
}
