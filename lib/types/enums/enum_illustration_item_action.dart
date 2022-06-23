/// Actions for an illustration item.
enum EnumIllustrationItemAction {
  /// Allow this illustration to be visible in public spaces (admin action).
  /// Challenges, books and contests may be different from public spaces.
  approve,

  /// Add this illustration to a book.
  addToBook,

  /// Delete this illustration from database.
  delete,

  /// Prevent this illustration to be visible in public spaces (admin action).
  /// Challenges, books and contests may be different from public spaces.
  disapprove,

  /// Like an illustration..
  like,

  /// Remove this illustration from somewhere (i.e. profile section).
  remove,

  /// Remove this illustration from a book.
  removeFromBook,

  /// Use this illustration as a book's cover.
  setAsCover,

  /// Unlike an illustration..
  unlike,

  /// Update this illustration's visibility.
  updateVisibility,
}
