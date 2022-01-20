/// Related urls to this license.
class LicenseUrls {
  LicenseUrls({
    this.image = '',
    this.wikipedia = '',
    this.website = '',
  });

  /// License logo or image.
  String image;

  /// Wikipedia url on this license.
  String wikipedia;

  /// Official website of this license.
  String website;

  /// Create an empty instance of this class.
  factory LicenseUrls.empty() {
    return LicenseUrls(
      image: '',
      wikipedia: '',
      website: '',
    );
  }

  /// Parse JSON data corresponding to this object and return a new instance.
  factory LicenseUrls.fromJSON(Map<String, dynamic>? data) {
    if (data == null) {
      return LicenseUrls.empty();
    }

    return LicenseUrls(
      image: data['image'] ?? '',
      wikipedia: data['wikipedia'] ?? '',
      website: data['website'] ?? '',
    );
  }

  Map<String, dynamic> toJSON() {
    final Map<String, dynamic> data = {};

    data['image'] = image;
    data['wikipedia'] = wikipedia;
    data['website'] = website;

    return data;
  }
}