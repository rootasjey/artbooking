class CreatedBy {
  /// User's id.
  final String? id;

  CreatedBy({
    this.id = '',
  });

  /// Create an empty instance.
  factory CreatedBy.empty() {
    return CreatedBy(
      id: '',
    );
  }

  /// Create an instance from JSON data.
  factory CreatedBy.fromJSON(Map<String, dynamic>? data) {
    if (data == null) {
      return CreatedBy.empty();
    }

    return CreatedBy(
      id: data['id'],
    );
  }
}
