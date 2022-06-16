/// Actions for an illustration item.
enum EnumBookItemAction {
  /// Allow this book to be shown on public spaces (admin action).
  /// Challenges and contests may be different from public spaces.
  approve,

  /// Delete this book from database.
  delete,

  /// Prevent this book to be visible in public spaces (admin action).
  /// Challenges and contests may be different from public spaces.
  disapprove,

  /// Like a book.
  like,

  /// Remove a book from a profile page section.
  remove,

  /// Rename book's title.
  rename,

  /// Unlike a book.
  unlike,

  /// Update properties of this book.
  update,

  /// Update this book's description.
  updateDescription,

  /// Update this book's visibility.
  updateVisibility,

  /// Upload new illustrations and add them to the target book.
  uploadIllustrations,
}
