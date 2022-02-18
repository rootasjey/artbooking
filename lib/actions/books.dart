import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/cloud_functions/books_response.dart';
import 'package:artbooking/types/cloud_functions/illustrations_response.dart';
import 'package:artbooking/types/cloud_functions/book_response.dart';
import 'package:cloud_functions/cloud_functions.dart';

class BooksActions {
  static Future<IllustrationsResponse> addIllustrations({
    required String bookId,
    required List<String> illustrationIds,
  }) async {
    try {
      final response =
          await Utilities.cloud.fun("books-addIllustrations").call({
        "book_id": bookId,
        "illustration_ids": illustrationIds,
      });

      return IllustrationsResponse.fromJSON(response.data);
    } on FirebaseFunctionsException catch (exception) {
      Utilities.logger.e(exception);
      return IllustrationsResponse.fromException(exception);
    } catch (error) {
      Utilities.logger.e(error);
      return IllustrationsResponse.fromMessage(error.toString());
    }
  }

  static Future<BookResponse> createOne({
    required String name,
    String description = "",
    List<String?> illustrationIds = const [],
  }) async {
    try {
      final response = await Utilities.cloud.fun("books-createOne").call({
        "name": name,
        "description": description,
        "illustration_ids": illustrationIds,
      });

      return BookResponse.fromJSON(response.data);
    } on FirebaseFunctionsException catch (exception) {
      Utilities.logger.e(exception);
      return BookResponse.fromException(exception);
    } catch (error) {
      Utilities.logger.e(error);
      return BookResponse.fromMessage(error.toString());
    }
  }

  static Future<BookResponse> deleteOne({
    required String? bookId,
  }) async {
    try {
      final response = await Utilities.cloud.fun("books-deleteOne").call({
        "book_id": bookId,
      });

      return BookResponse.fromJSON(response.data);
    } on FirebaseFunctionsException catch (exception) {
      Utilities.logger.e(exception);
      return BookResponse.fromException(exception);
    } catch (error) {
      Utilities.logger.e(error);
      return BookResponse.fromMessage(error.toString());
    }
  }

  static Future<BooksResponse> deleteMany({
    required List<String?> bookIds,
  }) async {
    try {
      final response = await Utilities.cloud.fun("books-deleteMany").call({
        "book_ids": bookIds,
      });

      return BooksResponse.fromJSON(response.data);
    } on FirebaseFunctionsException catch (exception) {
      Utilities.logger.e(exception);
      return BooksResponse.fromException(exception);
    } catch (error) {
      Utilities.logger.e(error);
      return BooksResponse.fromMessage(error.toString());
    }
  }

  static Future<IllustrationsResponse> removeIllustrations({
    required String? bookId,
    required List<String?> illustrationIds,
  }) async {
    try {
      final response =
          await Utilities.cloud.fun("books-removeIllustrations").call({
        "book_id": bookId,
        "illustration_ids": illustrationIds,
      });

      return IllustrationsResponse.fromJSON(response.data);
    } on FirebaseFunctionsException catch (exception) {
      Utilities.logger.e(exception);
      return IllustrationsResponse.fromException(exception);
    } catch (error) {
      Utilities.logger.e(error);
      return IllustrationsResponse.fromMessage(error.toString());
    }
  }

  /// Rename one book with a new name and a new description.
  static Future<BookResponse> renameOne({
    required String name,
    String description = "",
    required String bookId,
  }) async {
    try {
      final response = await Utilities.cloud.fun("books-renameOne").call({
        "name": name,
        "description": description,
        "book_id": bookId,
      });

      return BookResponse.fromJSON(response.data);
    } on FirebaseFunctionsException catch (exception) {
      Utilities.logger.e(exception);
      return BookResponse.fromException(exception);
    } catch (error) {
      Utilities.logger.e(error);
      return BookResponse.fromMessage(error.toString());
    }
  }
}
