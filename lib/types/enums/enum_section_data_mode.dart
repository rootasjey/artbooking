/// How a section's data is populated.
enum EnumSectionDataMode {
  /// Chosen items. User picks which items to add.
  manual,

  /// Items are automatically fetched from user's data
  /// ordered by ascending last created.
  lastCreated,

  /// Items are automatically fetched from user's data
  /// ordered by ascending last updated.
  lastUpdated,
}
