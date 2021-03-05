import 'package:artbooking/types/single_book_op_resp.dart';
import 'package:artbooking/utils/app_logger.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class BooksActions {
  static Future<SingleBookOpResp> create({
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

      return SingleBookOpResp.fromJSON(response.data);
    } on FirebaseFunctionsException catch (exception) {
      appLogger.e(exception);
      return SingleBookOpResp.fromException(exception);
    } catch (error) {
      appLogger.e(error);
      return SingleBookOpResp.fromMessage(error.toString());
    }
  }

  static Future<SingleBookOpResp> deleteOne({
    @required String bookId,
  }) async {
    try {
      final callable = FirebaseFunctions.instanceFor(
        app: Firebase.app(),
        region: 'europe-west3',
      ).httpsCallable(
        'books-deleteOne',
      );

      final response = await callable.call({
        'bookId': bookId,
      });

      return SingleBookOpResp.fromJSON(response.data);
    } on FirebaseFunctionsException catch (exception) {
      appLogger.e(exception);
      return SingleBookOpResp.fromException(exception);
    } catch (error) {
      appLogger.e(error);
      return SingleBookOpResp.fromMessage(error.toString());
    }
  }
}
