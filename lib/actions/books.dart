import 'package:artbooking/types/many_books_op_resp.dart';
import 'package:artbooking/types/one_book_op_resp.dart';
import 'package:artbooking/utils/app_logger.dart';
import 'package:artbooking/utils/cloud_helper.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

class BooksActions {
  static Future<OneBookOpResp> createOne({
    @required String name,
    String description = '',
  }) async {
    try {
      final response = await CloudHelper.fun('books-createOne').call({
        'name': name,
        'description': description,
      });

      return OneBookOpResp.fromJSON(response.data);
    } on FirebaseFunctionsException catch (exception) {
      appLogger.e(exception);
      return OneBookOpResp.fromException(exception);
    } catch (error) {
      appLogger.e(error);
      return OneBookOpResp.fromMessage(error.toString());
    }
  }

  static Future<OneBookOpResp> deleteOne({
    @required String bookId,
  }) async {
    try {
      final response = await CloudHelper.fun('books-deleteOne').call({
        'bookId': bookId,
      });

      return OneBookOpResp.fromJSON(response.data);
    } on FirebaseFunctionsException catch (exception) {
      appLogger.e(exception);
      return OneBookOpResp.fromException(exception);
    } catch (error) {
      appLogger.e(error);
      return OneBookOpResp.fromMessage(error.toString());
    }
  }

  static Future<ManyBooksOpResp> deleteMany({
    @required List<String> bookIds,
  }) async {
    try {
      final response = await CloudHelper.fun('books-deleteMany').call({
        'bookIds': bookIds,
      });

      return ManyBooksOpResp.fromJSON(response.data);
    } on FirebaseFunctionsException catch (exception) {
      appLogger.e(exception);
      return ManyBooksOpResp.fromException(exception);
    } catch (error) {
      appLogger.e(error);
      return ManyBooksOpResp.fromMessage(error.toString());
    }
  }
}