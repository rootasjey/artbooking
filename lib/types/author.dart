class Author {
  Author({
    required this.id,
  });

  /// Author's id.
  String id;

  factory Author.empty() {
    return Author(
      id: '',
    );
  }

  factory Author.fromJSON(Map<String, dynamic> data) {
    return Author(
      id: data['id'],
    );
  }
}
