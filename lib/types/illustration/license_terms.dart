/// Restrictions related to usage.
class LicenseTerms {
  /// You must give appropriate credit, provide a link to the license, and indicate if changes were made.
  final bool attribution;

  /// You may not apply legal terms or technological measures that legally restricts others from doing anything the license permits.
  final bool noAdditionalRestriction;

  /// Require that anyone who use the work - licensees - make that new work available under the same license terms.
  final bool shareAlike;

  /// Create a new license instance.
  LicenseTerms({
    this.attribution = false,
    this.noAdditionalRestriction = false,
    this.shareAlike,
  });

  /// Create an empty license instance.
  factory LicenseTerms.empty() {
    return LicenseTerms(
      attribution: false,
      noAdditionalRestriction: false,
      shareAlike: false,
    );
  }

  /// Create a license instance from JSON data.
  factory LicenseTerms.fromJSON(Map<String, dynamic> data) {
    if (data == null) {
      return LicenseTerms.empty();
    }

    return LicenseTerms(
      attribution: data['attribution'] ?? false,
      noAdditionalRestriction: data['noAdditionalRestriction'] ?? false,
      shareAlike: data['shareAlike'] ?? false,
    );
  }

  Map<String, dynamic> toJSON() {
    final Map<String, dynamic> data = {};

    data['attribution'] = attribution;
    data['noAdditionalRestriction'] = noAdditionalRestriction;
    data['shareAlike'] = shareAlike;

    return data;
  }
}
