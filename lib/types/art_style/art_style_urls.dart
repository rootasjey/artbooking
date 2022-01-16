/// External links for this art style.
class ArtStyleUrls {
  const ArtStyleUrls({
    this.image = '',
    this.wikipedia = '',
  });

  /// An image representation of this art style.
  /// Note that this is one example among many.
  final String image;

  /// Wikipedia link about this art style.
  /// You may find useful information.
  final String wikipedia;

  factory ArtStyleUrls.empty() {
    return ArtStyleUrls(
      image: '',
      wikipedia: '',
    );
  }

  factory ArtStyleUrls.fromJSON(Map<String, dynamic>? data) {
    if (data == null) {
      return ArtStyleUrls.empty();
    }

    return ArtStyleUrls(
      image: data['image'],
      wikipedia: data['wikipedia'],
    );
  }
}
