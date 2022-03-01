/// How a section's data is populated.
enum EnumSectionDataMode {
  /// user chooses which items appear on this section.
  chosen,

  /// Automatically fetch items (illustrations, books) in the order their
  /// appear on a user’s personal illustrations/books page, and are public.
  sync,
}
