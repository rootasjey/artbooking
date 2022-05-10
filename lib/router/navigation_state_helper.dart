import 'package:artbooking/types/book/book.dart';
import 'package:artbooking/types/illustration/illustration.dart';
import 'package:artbooking/types/post.dart';
import 'package:artbooking/types/section.dart';
import 'package:flutter/widgets.dart';

/// State helper to keep track of passing arguments
/// which are not strings and simple types.
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

  /// Last post selected.
  /// This should be affected before navigating to PostPage.
  /// This state's property allow us to pass post data
  /// outside the page's state (because of the router behavior).
  static Post? post;

  /// Last section selected.
  /// This should be affected before navigating to SectionPage.
  /// This state's property allow us to pass section data
  /// outside the page's state (because of the router behavior).
  static Section? section;
}
