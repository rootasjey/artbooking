import 'dart:convert';

/// Related urls to this license.
class LicenseLinks {
  const LicenseLinks({
    this.image = '',
    this.legalCode = '',
    this.privacy = '',
    this.terms = '',
    this.wikipedia = '',
    this.website = '',
  });

  /// License logo or image.
  final String image;
  final String legalCode;
  final String privacy;
  final String terms;

  /// Official website of this license.
  final String website;

  /// Wikipedia url on this license.
  final String wikipedia;

  /// Create an empty instance of this class.
  factory LicenseLinks.empty() {
    return LicenseLinks();
  }

  /// Parse JSON data corresponding to this object and return a new instance.
  factory LicenseLinks.fromMap(Map<String, dynamic>? data) {
    if (data == null) {
      return LicenseLinks.empty();
    }

    return LicenseLinks(
      image: data['image'] ?? '',
      legalCode: data['legal_code'] ?? '',
      privacy: data['privacy'] ?? '',
      terms: data['terms'] ?? '',
      wikipedia: data['wikipedia'] ?? '',
      website: data['website'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'image': image,
      'legal_code': legalCode,
      'privacy': privacy,
      'terms': terms,
      'wikipedia': wikipedia,
      'website': website,
    };
  }

  LicenseLinks copyWith({
    String? image,
    String? legalCode,
    String? privacy,
    String? terms,
    String? wikipedia,
    String? website,
  }) {
    return LicenseLinks(
      image: image ?? this.image,
      legalCode: legalCode ?? this.legalCode,
      privacy: privacy ?? this.privacy,
      terms: terms ?? this.terms,
      wikipedia: wikipedia ?? this.wikipedia,
      website: website ?? this.website,
    );
  }

  String toJson() => json.encode(toMap());

  factory LicenseLinks.fromJson(String source) =>
      LicenseLinks.fromMap(json.decode(source));

  @override
  String toString() =>
      'LicenseLinks(image: $image, legalCode: $legalCode, privacy: $privacy, '
      'terms: $terms, wikipedia: $wikipedia, website: $website )';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LicenseLinks &&
        other.image == image &&
        other.legalCode == legalCode &&
        other.privacy == privacy &&
        other.terms == terms &&
        other.wikipedia == wikipedia &&
        other.website == website;
  }

  @override
  int get hashCode =>
      image.hashCode ^
      legalCode.hashCode ^
      privacy.hashCode ^
      terms.hashCode ^
      wikipedia.hashCode ^
      website.hashCode;
}
