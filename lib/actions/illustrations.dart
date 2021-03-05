import 'package:artbooking/types/multiple_illus_op_resp.dart';
import 'package:artbooking/types/single_illus_op_resp.dart';
import 'package:artbooking/types/enums.dart';
import 'package:artbooking/types/illustration/illustration.dart';
import 'package:artbooking/types/illustration/license.dart';
import 'package:artbooking/utils/app_logger.dart';
import 'package:artbooking/utils/cloud_helper.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

class IllustrationsActions {
  static Future<SingleIllusOpResp> createOne({
    @required String name,
    ContentVisibility visibility = ContentVisibility.private,
  }) async {
    try {
      final response = await CloudHelper.fun('illustrations-createOne').call({
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

  static Future<SingleIllusOpResp> deleteOne({
    @required String illustrationId,
  }) async {
    try {
      final response = await CloudHelper.fun('illustrations-deleteOne').call({
        'illustrationId': illustrationId,
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

  static Future<MultipleIllusOpResp> deleteMany({
    @required List<String> illustrationsIds,
  }) async {
    try {
      final response = await CloudHelper.fun('illustrations-deleteMany').call({
        'illustrationIds': illustrationsIds,
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
      final response =
          await CloudHelper.fun('illustrations-updateMetadata').call({
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
