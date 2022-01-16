class LicenseUpdatedBy {
  const LicenseUpdatedBy({
    this.id = '',
  });

  /// User's id.
  final String id;

  /// Create an empty instance.
  factory LicenseUpdatedBy.empty() {
    return LicenseUpdatedBy(
      id: '',
    );
  }

  /// Create an instance from JSON data.
  factory LicenseUpdatedBy.fromJSON(Map<String, dynamic>? data) {
    if (data == null) {
      return LicenseUpdatedBy.empty();
    }

    return LicenseUpdatedBy(
      id: data['id'] ?? '',
    );
  }
}
