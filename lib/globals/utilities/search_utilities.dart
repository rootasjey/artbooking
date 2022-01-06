import 'package:algolia/algolia.dart';

/// Algolia search helper.
class SearchUtilities {
  const SearchUtilities();

  static Algolia? _algolia;

  /// Agolia instance.
  static Algolia? get algolia => _algolia;

  /// Initialize algolia instance.
  void init({
    required applicationId,
    required searchApiKey,
  }) {
    _algolia = Algolia.init(
      applicationId: applicationId,
      apiKey: searchApiKey,
    );
  }
}
