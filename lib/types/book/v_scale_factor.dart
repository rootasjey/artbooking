class VScaleFactor {
  final int height;
  final int mobileHeight;
  final int mobileWidth;
  final int width;

  VScaleFactor({
    required this.height,
    required this.mobileHeight,
    required this.mobileWidth,
    required this.width,
  });

  factory VScaleFactor.fromJSON(Map<String, dynamic> data) {
    return VScaleFactor(
      height: data['height'] ?? 1,
      mobileHeight: data['mobileHeight'] ?? 1,
      mobileWidth: data['mobileWidth'] ?? 1,
      width: data['width'] ?? 1,
    );
  }

  Map<String, int> toJSON() {
    final data = Map<String, int>();

    data['height'] = height;
    data['mobileHeight'] = mobileHeight;
    data['mobileWidth'] = mobileWidth;
    data['width'] = width;

    return data;
  }
}
