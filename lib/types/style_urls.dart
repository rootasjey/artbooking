/// External links for this art style.
class StyleUrls {
  /// An image representation of this art style.
  /// Note that this is one example among many.
  final String? image;

  /// Wikipedia link about this art style.
  /// You may find useful information.
  final String? wikipedia;

  StyleUrls({
    this.image = '',
    this.wikipedia = '',
  });

  factory StyleUrls.empty() {
    return StyleUrls(
      image: '',
      wikipedia: '',
    );
  }

  factory StyleUrls.fromJSON(Map<String, dynamic>? data) {
    if (data == null) {
      return StyleUrls.empty();
    }

    return StyleUrls(
      image: data['image'],
      wikipedia: data['wikipedia'],
    );
  }
}
