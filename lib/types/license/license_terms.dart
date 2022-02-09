import 'dart:convert';

/// Restrictions related to usage.
class LicenseTerms {
  /// Create a new license instance.
  const LicenseTerms({
    this.attribution = false,
    this.noAdditionalRestriction = false,
    this.shareAlike = false,
  });

  /// You must give appropriate credit, provide a link to the license, and indicate if changes were made.
  final bool attribution;

  /// You may not apply legal terms or technological measures that legally restricts others from doing anything the license permits.
  final bool noAdditionalRestriction;

  /// Require that anyone who use the work - licensees - make that new work available under the same license terms.
  final bool shareAlike;

  /// Create an empty license instance.
  factory LicenseTerms.empty() {
    return LicenseTerms(
      attribution: false,
      noAdditionalRestriction: false,
      shareAlike: false,
    );
  }

  /// Create a license instance from JSON data.
  factory LicenseTerms.fromMap(Map<String, dynamic>? data) {
    if (data == null) {
      return LicenseTerms.empty();
    }

    return LicenseTerms(
      attribution: data['attribution'] ?? false,
      noAdditionalRestriction: data['no_additional_restriction'] ?? false,
      shareAlike: data['share_a_like'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'attribution': attribution,
      'no_additional_restriction': noAdditionalRestriction,
      'share_a_like': shareAlike,
    };
  }

  LicenseTerms copyWith({
    bool? attribution,
    bool? noAdditionalRestriction,
    bool? shareAlike,
  }) {
    return LicenseTerms(
      attribution: attribution ?? this.attribution,
      noAdditionalRestriction:
          noAdditionalRestriction ?? this.noAdditionalRestriction,
      shareAlike: shareAlike ?? this.shareAlike,
    );
  }

  String toJson() => json.encode(toMap());

  factory LicenseTerms.fromJson(String source) =>
      LicenseTerms.fromMap(json.decode(source));

  @override
  String toString() => 'LicenseTerms(attribution: $attribution, '
      'noAdditionalRestriction: $noAdditionalRestriction, '
      'shareAlike: $shareAlike)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LicenseTerms &&
        other.attribution == attribution &&
        other.noAdditionalRestriction == noAdditionalRestriction &&
        other.shareAlike == shareAlike;
  }

  @override
  int get hashCode =>
      attribution.hashCode ^
      noAdditionalRestriction.hashCode ^
      shareAlike.hashCode;
}
