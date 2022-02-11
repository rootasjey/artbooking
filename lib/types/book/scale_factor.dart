import 'dart:convert';

class ScaleFactor {
  const ScaleFactor({
    this.height = 0,
    this.mobileHeight = 0,
    this.mobileWidth = 0,
    this.width = 0,
  });

  final int height;
  final int mobileHeight;
  final int mobileWidth;
  final int width;

  factory ScaleFactor.fromMap(Map<String, dynamic> data) {
    return ScaleFactor(
      height: data['height']?.toInt() ?? 1,
      mobileHeight: data['mobile_height']?.toInt() ?? 1,
      mobileWidth: data['mobile_width']?.toInt() ?? 1,
      width: data['width']?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'height': height,
      'mobile_height': mobileHeight,
      'mobile_width': mobileWidth,
      'width': width,
    };
  }

  ScaleFactor copyWith({
    int? height,
    int? mobileHeight,
    int? mobileWidth,
    int? width,
  }) {
    return ScaleFactor(
      height: height ?? this.height,
      mobileHeight: mobileHeight ?? this.mobileHeight,
      mobileWidth: mobileWidth ?? this.mobileWidth,
      width: width ?? this.width,
    );
  }

  String toJson() => json.encode(toMap());

  factory ScaleFactor.fromJson(String source) =>
      ScaleFactor.fromMap(json.decode(source));

  @override
  String toString() {
    return 'ScaleFactor(height: $height, mobileHeight: $mobileHeight, mobileWidth: $mobileWidth, width: $width)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ScaleFactor &&
        other.height == height &&
        other.mobileHeight == mobileHeight &&
        other.mobileWidth == mobileWidth &&
        other.width == width;
  }

  @override
  int get hashCode {
    return height.hashCode ^
        mobileHeight.hashCode ^
        mobileWidth.hashCode ^
        width.hashCode;
  }
}
