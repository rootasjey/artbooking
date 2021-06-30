enum AniProps {
  color,
  height,
  opacity,
  translateX,
  translateY,
  width,
}

enum AppBarDevelopers {
  apiReference,
  apiStatus,
  documentation,
  github,
  portal,
}

enum AppBarDiscover {
  authors,
  references,
  random,
}

enum AppBarGroupedSectionItems {
  github,
  authors,
  references,
  random,
  about,
  contact,
  tos,
}

enum AppBarResources {
  about,
  androidApp,
  contact,
  iosApp,
  tos,
}

enum AppBarQuotesBy {
  authors,
  references,
  topics,
}

enum AppBarSettings {
  allSettings,
  selectLang,
  en,
  fr,
}

/// Actions for an illustration item.
enum IllustrationItemAction {
  /// Add this illustration to a book.
  addToBook,

  /// Delete this illustration from database.
  delete,

  /// Remove this illustration from a book.
  removeFromBook,
}

enum BookLayout {
  /// Display illustrations on a grid with a size adapted to the aspect ratio
  /// of each illustration's dimensions.
  /// e.g. if an illustration has an original size of 2000x2000,
  /// it'll be displayed as a 300x300 item — if another one is 2000x3000,
  /// it'll be displayed as a 150x300 item.
  adaptativeGrid,

  /// Display items on a grid with a custom size for each illustrations.
  /// They're 300x300 by default. With the [vScaleFactor] property,
  /// they can be larger or smaller. The grid can both be scrolled
  /// on the horizontal and vertical axis. This grid con contain a row
  /// and a column that exceed the screen's size.
  /// Items's position are stored in the [matrice] property.
  customExtendedGrid,

  /// Display items on a grid with a custom size for each illustrations.
  /// They're 300x300 by default. With the [vScaleFactor] property,
  /// they can be larger or smaller.
  /// The grid can only be scrolled on the horizontal or vertical axis
  /// according to [layoutOrientation].
  customGrid,

  /// Display items in a list with a custom size for each illustrations.
  /// They're 300x300 by default. With the [vScaleFactor] property,
  /// they can be larger or smaller.
  customList,

  /// Display illustrations in a horizontal list of 300x300px.
  horizontalList,

  ///Display illustrations in a horizontal list of 300px width, and 150px height.
  horizontalListWide,

  /// Display illustrations on a grid of 300x300.
  grid,

  /// Display illustrations on a grid of 600x600.
  largeGrid,

  /// Display illustrations on a grid of 150x150.
  smallGrid,

  /// Display two illustrations at a time on a screen.
  twoPagesBook,

  /// Display illustrations in a list with item of 300x300 pixels.
  verticalList,

  /// Display illustrations on a grid of 300px width and 150px height.
  verticalListWide,
}

enum BookLayoutOrientation {
  /// The layout can be scrolled horizontally and vertically.
  both,

  /// The layout can only be scrolled horizontally.
  horizontal,

  /// The layout can only be scrolled vertically.
  vertical,
}

enum ContentVisibility {
  acl,
  private,
  public,
  unlisted,
}

enum DiscoverType {
  authors,
  references,
}

enum ItemsLayout {
  list,
  grid,
}

enum ItemComponentType {
  card,
  row,
}

enum SnackType {
  error,
  info,
  success,
}

/// Specify where an upload task is at.
enum UploadTaskStep {
  /// Creating the Firestore document.
  Firestore,

  /// Uploading the file to Firebase Cloud Storage.
  Storage,
}

enum UserMenuSelect {
  about,
  books,
  contests,
  challenges,
  dashboard,
  galleries,
  illustrations,
  settings,
  signout,
  upload,
}
