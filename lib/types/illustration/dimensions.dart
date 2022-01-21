class Dimensions {
  Dimensions({
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

  factory Dimensions.fromJSON(Map<String, dynamic> data) {
    return Dimensions(
      height: data['height'] ?? 0,
      width: data['width'] ?? 0,
    );
  }

  double getRelativeWidth(double fromHeight) {
    final double factor = fromHeight / height;
    return (width * factor).truncateToDouble();
  }
}
