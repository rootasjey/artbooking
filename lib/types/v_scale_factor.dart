class VScaleFactor {
  final double height;
  final double mobileHeight;
  final double mobileWidth;
  final double width;

  VScaleFactor({
    this.height,
    this.mobileHeight,
    this.mobileWidth,
    this.width,
  });

  factory VScaleFactor.fromJSON(Map<String, dynamic> data) {
    return VScaleFactor(
      height: data['height'] ?? 1.0,
      mobileHeight: data['mobileHeight'] ?? 1.0,
      mobileWidth: data['mobileWidth'] ?? 1.0,
      width: data['width'] ?? 1.0,
    );
  }

  Map<String, double> toJSON() {
    final data = Map<String, double>();

    data['height'] = height;
    data['mobileHeight'] = mobileHeight;
    data['mobileWidth'] = mobileWidth;
    data['width'] = width;

    return data;
  }
}
