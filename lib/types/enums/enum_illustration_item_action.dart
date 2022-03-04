/// Actions for an illustration item.
enum EnumIllustrationItemAction {
  /// Add this illustration to a book.
  addToBook,

  /// Delete this illustration from database.
  delete,

  /// Like an illustration..
  like,

  /// Remove this illustration from somewhere (i.e. profile section).
  remove,

  /// Remove this illustration from a book.
  removeFromBook,

  /// Unlike an illustration..
  unlike,

  /// Update this illustration's visibility.
  updateVisibility,
}
