import 'package:artbooking/types/multiple_books_op_resp.dart';
import 'package:artbooking/types/single_book_op_resp.dart';
import 'package:artbooking/utils/app_logger.dart';
import 'package:artbooking/utils/cloud_helper.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

class BooksActions {
  static Future<SingleBookOpResp> createOne({
    @required String name,
    String description = '',
  }) async {
    try {
      final response = await CloudHelper.fun('books-createOne').call({
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
      final response = await CloudHelper.fun('books-deleteOne').call({
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

  static Future<MultipleBooksOpResp> deleteMany({
    @required List<String> bookIds,
  }) async {
    try {
      final response = await CloudHelper.fun('books-deleteMany').call({
        'bookIds': bookIds,
      });

      return MultipleBooksOpResp.fromJSON(response.data);
    } on FirebaseFunctionsException catch (exception) {
      appLogger.e(exception);
      return MultipleBooksOpResp.fromException(exception);
    } catch (error) {
      appLogger.e(error);
      return MultipleBooksOpResp.fromMessage(error.toString());
    }
  }
}
