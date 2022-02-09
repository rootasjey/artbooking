import 'dart:convert';

class Dimensions {
  const Dimensions({
    this.height = 0,
    this.width = 0,
  });

  /// Illustration's height.
  final int height;

  /// Illustration's width.
  final int width;

  Dimensions copyWith({
    int? height,
    int? width,
  }) {
    return Dimensions(
      height: height ?? this.height,
      width: width ?? this.width,
    );
  }

  factory Dimensions.empty() {
    return Dimensions(
      height: 0,
      width: 0,
    );
  }

  factory Dimensions.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return Dimensions.empty();
    }

    return Dimensions(
      height: map['height']?.toInt() ?? 0,
      width: map['width']?.toInt() ?? 0,
    );
  }

  /// Return a width based on the passed height
  /// and depending on this image's width.
  double getRelativeWidth(double fromHeight) {
    final double factor = fromHeight / height;
    return (width * factor).truncateToDouble();
  }

  Map<String, dynamic> toMap() {
    return {
      'height': height,
      'width': width,
    };
  }

  String toJson() => json.encode(toMap());

  factory Dimensions.fromJson(String source) =>
      Dimensions.fromMap(json.decode(source));

  @override
  String toString() => 'Dimensions(height: $height, width: $width)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Dimensions &&
        other.height == height &&
        other.width == width;
  }

  @override
  int get hashCode => height.hashCode ^ width.hashCode;
}
