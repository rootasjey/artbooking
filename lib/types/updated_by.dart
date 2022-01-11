class UpdatedBy {
  const UpdatedBy({
    this.id = '',
  });

  /// User's id.
  final String id;

  /// Create an empty instance.
  factory UpdatedBy.empty() {
    return UpdatedBy(
      id: '',
    );
  }

  /// Create an instance from JSON data.
  factory UpdatedBy.fromJSON(Map<String, dynamic>? data) {
    if (data == null) {
      return UpdatedBy.empty();
    }

    return UpdatedBy(
      id: data['id'] ?? '',
    );
  }
}
