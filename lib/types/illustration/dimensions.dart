class Dimensions {
  const Dimensions({
    this.height = 0,
    this.width = 0,
  });

  /// Illustration's height.
  final int height;

  /// Illustration's width.
  final int width;

  factory Dimensions.empty() {
    return Dimensions(
      height: 0,
      width: 0,
    );
  }

  factory Dimensions.fromJSON(Map<String, dynamic>? data) {
    if (data == null) {
      return Dimensions.empty();
    }

    return Dimensions(
      height: data['height'] ?? 0,
      width: data['width'] ?? 0,
    );
  }

  /// Return a width based on the passed height
  /// and depending on this image's width.
  double getRelativeWidth(double fromHeight) {
    final double factor = fromHeight / height;
    return (width * factor).truncateToDouble();
  }
}
