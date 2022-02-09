class ScaleFactor {
  const ScaleFactor({
    required this.height,
    required this.mobileHeight,
    required this.mobileWidth,
    required this.width,
  });

  final int height;
  final int mobileHeight;
  final int mobileWidth;
  final int width;

  factory ScaleFactor.fromJSON(Map<String, dynamic> data) {
    return ScaleFactor(
      height: data['height'] ?? 1,
      mobileHeight: data['mobile_height'] ?? 1,
      mobileWidth: data['mobile_width'] ?? 1,
      width: data['width'] ?? 1,
    );
  }

  Map<String, int> toJSON() {
    final data = Map<String, int>();

    data['height'] = height;
    data['mobile_height'] = mobileHeight;
    data['mobile_width'] = mobileWidth;
    data['width'] = width;

    return data;
  }
}
