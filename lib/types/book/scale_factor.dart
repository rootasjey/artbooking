import 'dart:convert';

class ScaleFactor {
  const ScaleFactor({
    this.height = 1,
    this.width = 1,
  });

  final int height;
  final int width;

  factory ScaleFactor.fromMap(Map<String, dynamic>? data) {
    if (data == null) {
      return ScaleFactor();
    }

    return ScaleFactor(
      height: data['height']?.toInt() ?? 1,
      width: data['width']?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'height': height,
      'width': width,
    };
  }

  ScaleFactor copyWith({
    int? height,
    int? width,
  }) {
    return ScaleFactor(
      height: height ?? this.height,
      width: width ?? this.width,
    );
  }

  String toJson() => json.encode(toMap());

  factory ScaleFactor.fromJson(String source) =>
      ScaleFactor.fromMap(json.decode(source));

  @override
  String toString() {
    return 'ScaleFactor(height: $height, width: $width)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ScaleFactor &&
        other.height == height &&
        other.width == width;
  }

  @override
  int get hashCode {
    return height.hashCode ^ width.hashCode;
  }
}
