class Dimensions {
  /// Illustration's height.
  final int height;

  /// Illustration's width.
  final int width;

  Dimensions({
    this.height = 0,
    this.width = 0,
  });

  factory Dimensions.empty() {
    return Dimensions(
      height: 0,
      width: 0,
    );
  }

  factory Dimensions.fromJSON(Map<String, dynamic> data) {
    return Dimensions(
      height: data['height'],
      width: data['width'],
    );
  }
}
