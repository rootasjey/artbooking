import 'package:artbooking/types/book.dart';
import 'package:artbooking/types/illustration/illustration.dart';
import 'package:flutter/widgets.dart';

/// State helper to keep track of passing arguments
/// which are not string and simple types.
/// Very useful to avoid re-fetching an already loaded data,
/// and makes forward hero animation work.
class NavigationStateHelper {
  /// Last book selected.
  /// This should be affected before navigating to BookPage.
  /// This external state avoid re-fetching book's data,
  /// and make hero forward hero animation work.
  static Book? book;

  /// Last illustration selected.
  /// This should be affected before navigating to IllustrationPage.
  /// This external state avoid re-fetching illustration's data,
  /// and make hero forward hero animation work.
  static Illustration? illustration;

  /// Last image selected.
  /// This should be affected before navigating to EditImagePage.
  /// This state's property allow us to pass image data
  /// outside the page's state (because of the router behavior).
  static ImageProvider<Object>? imageToEdit;
}
