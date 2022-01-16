/// Book's related urls.
class BookUrls {
  /// Custom cover.
  /// Will override default cover if set (which is the last added image).
  String cover;

  /// Custom icon. Will override default icon if set.
  String icon;

  BookUrls({
    this.cover = '',
    this.icon = '',
  });

  factory BookUrls.empty() {
    return BookUrls(
      cover: '',
      icon: '',
    );
  }

  factory BookUrls.fromJSON(Map<String, dynamic>? data) {
    if (data == null) {
      return BookUrls.empty();
    }

    return BookUrls(
      cover: data['cover'] ?? '',
      icon: data['icon'] ?? '',
    );
  }
}
