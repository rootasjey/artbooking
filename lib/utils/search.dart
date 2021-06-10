import 'package:algolia/algolia.dart';
import 'package:flutter/foundation.dart';

/// Algolia search helper.
class SearchHelper {
  static Algolia _algolia;

  /// Agolia instance.
  static Algolia get algolia => _algolia;

  /// Initialize algolia instance.
  static void init({
    @required applicationId,
    @required searchApiKey,
  }) {
    _algolia = Algolia.init(
      applicationId: applicationId,
      apiKey: searchApiKey,
    );
  }
}
