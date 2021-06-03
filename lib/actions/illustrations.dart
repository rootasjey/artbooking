import 'package:artbooking/types/many_illus_op_resp.dart';
import 'package:artbooking/types/one_illus_op_resp.dart';
import 'package:artbooking/types/enums.dart';
import 'package:artbooking/types/illustration/illustration.dart';
import 'package:artbooking/types/illustration/license.dart';
import 'package:artbooking/utils/app_logger.dart';
import 'package:artbooking/utils/cloud_helper.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

class IllustrationsActions {
  static Future<OneIllusOpResp> createOne({
    @required String name,
    ContentVisibility visibility = ContentVisibility.private,
  }) async {
    try {
      final response = await Cloud.fun('illustrations-createOne').call({
        'name': name,
        'visibility': Illustration.visibilityPropToString(visibility),
      });

      return OneIllusOpResp.fromJSON(response.data);
    } on FirebaseFunctionsException catch (exception) {
      appLogger.e(exception);
      return OneIllusOpResp.fromException(exception);
    } catch (error) {
      appLogger.e(error);
      return OneIllusOpResp.fromMessage(error.toString());
    }
  }

  static Future<OneIllusOpResp> deleteOne({
    @required String illustrationId,
  }) async {
    try {
      final response = await Cloud.fun('illustrations-deleteOne').call({
        'illustrationId': illustrationId,
      });

      return OneIllusOpResp.fromJSON(response.data);
    } on FirebaseFunctionsException catch (exception) {
      appLogger.e(exception);
      return OneIllusOpResp.fromException(exception);
    } catch (error) {
      appLogger.e(error);
      return OneIllusOpResp.fromMessage(error.toString());
    }
  }

  static Future<ManyIllusOpResp> deleteMany({
    @required List<String> illustrationIds,
  }) async {
    try {
      final response = await Cloud.fun('illustrations-deleteMany').call({
        'illustrationIds': illustrationIds,
      });

      return ManyIllusOpResp.fromJSON(response.data);
    } on FirebaseFunctionsException catch (exception) {
      appLogger.e(exception);
      return ManyIllusOpResp.fromException(exception);
    } catch (error) {
      appLogger.e(error);
      return ManyIllusOpResp.fromMessage(error.toString());
    }
  }

  static Future<OneIllusOpResp> updateMetadata({
    String name,
    String description,
    String summary,
    IllustrationLicense license,
    ContentVisibility visibility = ContentVisibility.private,
    @required Illustration illustration,
  }) async {
    try {
      final response = await Cloud.fun('illustrations-updateMetadata').call({
        'illustrationId': illustration.id,
        'name': name,
        'description': description,
        'summary': summary,
        'license': license.toJSON(),
        'visibility': Illustration.visibilityPropToString(visibility),
      });

      return OneIllusOpResp.fromJSON(response.data);
    } on FirebaseFunctionsException catch (exception) {
      appLogger.e(exception);
      return OneIllusOpResp.fromException(exception);
    } catch (error) {
      appLogger.e(error);
      return OneIllusOpResp.fromMessage(error.toString());
    }
  }
}
