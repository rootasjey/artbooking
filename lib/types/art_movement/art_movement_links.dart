/// External links for this art movement.
class ArtMovementLinks {
  const ArtMovementLinks({
    this.image = '',
    this.wikipedia = '',
  });

  /// An image representation of this art style.
  /// Note that this is one example among many.
  final String image;

  /// Wikipedia link about this art style.
  /// You may find useful information.
  final String wikipedia;

  factory ArtMovementLinks.empty() {
    return ArtMovementLinks(
      image: '',
      wikipedia: '',
    );
  }

  factory ArtMovementLinks.fromMap(Map<String, dynamic>? data) {
    if (data == null) {
      return ArtMovementLinks.empty();
    }

    return ArtMovementLinks(
      image: data['image'],
      wikipedia: data['wikipedia'],
    );
  }
}
