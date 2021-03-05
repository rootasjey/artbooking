import 'package:artbooking/types/multiple_illus_op_resp.dart';
import 'package:artbooking/types/single_illus_op_resp.dart';
import 'package:artbooking/types/enums.dart';
import 'package:artbooking/types/illustration/illustration.dart';
import 'package:artbooking/types/illustration/license.dart';
import 'package:artbooking/utils/app_logger.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class IllustrationsActions {
  static Future<SingleIllusOpResp> createDoc({
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

      return SingleIllusOpResp.fromJSON(response.data);
    } on FirebaseFunctionsException catch (exception) {
      appLogger.e(exception);
      return SingleIllusOpResp.fromException(exception);
    } catch (error) {
      appLogger.e(error);
      return SingleIllusOpResp.fromMessage(error.toString());
    }
  }

  static Future<SingleIllusOpResp> deleteDoc({
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
        'illustrationId': imageId,
      });

      return SingleIllusOpResp.fromJSON(response.data);
    } on FirebaseFunctionsException catch (exception) {
      appLogger.e(exception);
      return SingleIllusOpResp.fromException(exception);
    } catch (error) {
      appLogger.e(error);
      return SingleIllusOpResp.fromMessage(error.toString());
    }
  }

  static Future<MultipleIllusOpResp> deleteDocs({
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
        'illustrationIds': imagesIds,
      });

      return MultipleIllusOpResp.fromJSON(response.data);
    } on FirebaseFunctionsException catch (exception) {
      appLogger.e(exception);
      return MultipleIllusOpResp.fromException(exception);
    } catch (error) {
      appLogger.e(error);
      return MultipleIllusOpResp.fromMessage(error.toString());
    }
  }

  static Future<SingleIllusOpResp> updateMetadata({
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
        'illustrationId': illustration.id,
        'name': name,
        'description': description,
        'summary': summary,
        'license': license.toJSON(),
        'visibility': Illustration.visibilityPropToString(visibility),
      });

      return SingleIllusOpResp.fromJSON(response.data);
    } on FirebaseFunctionsException catch (exception) {
      appLogger.e(exception);
      return SingleIllusOpResp.fromException(exception);
    } catch (error) {
      appLogger.e(error);
      return SingleIllusOpResp.fromMessage(error.toString());
    }
  }
}
