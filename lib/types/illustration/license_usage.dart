/// Part of the license specifing what you can do the artwork.
class LicenseUsage {
  const LicenseUsage({
    this.commercial = false,
    this.adapt = false,
    this.foss = false,
    this.free = false,
    this.oss = false,
    this.personal = false,
    this.print = false,
    this.sell = false,
    this.share = false,
    this.view = false,
  });

  /// Remix, transform, and build upon the material
  /// for any purpose, even commercially.
  final bool adapt;

  /// Can be used in commercial projects & products.
  final bool commercial;

  /// Can be used in other free and open source projects.
  final bool foss;

  /// Can be used in other free softwares and projects.
  final bool free;

  /// Can be used in other open source projects.
  final bool oss;

  /// Can be used for personal use (e.g. wallpaper).
  final bool personal;

  /// Can be freely printed.
  final bool print;

  /// Can sell outside of the official app by another individual.
  final bool sell;

  /// Copy and redistribute the material in any medium or format.
  final bool share;

  /// Can view this illustration.
  final bool view;

  factory LicenseUsage.empty() {
    return LicenseUsage(
      commercial: false,
      adapt: false,
      foss: false,
      free: false,
      oss: false,
      personal: false,
      print: false,
      sell: false,
      share: false,
      view: false,
    );
  }

  factory LicenseUsage.fromJSON(Map<String, dynamic>? data) {
    if (data == null) {
      return LicenseUsage.empty();
    }

    return LicenseUsage(
      commercial: data['commercial'] ?? false,
      adapt: data['adapt'] ?? false,
      foss: data['foss'] ?? false,
      free: data['free'] ?? false,
      oss: data['oss'] ?? false,
      personal: data['personal'] ?? false,
      print: data['print'] ?? false,
      sell: data['sell'] ?? false,
      share: data['share'] ?? false,
      view: data['view'] ?? false,
    );
  }

  Map<String, bool> toJSON() {
    final data = Map<String, bool>();

    data['commercial'] = commercial;
    data['adapt'] = adapt;
    data['foss'] = foss;
    data['free'] = free;
    data['oss'] = oss;
    data['personal'] = personal;
    data['print'] = print;
    data['sell'] = sell;
    data['share'] = share;
    data['view'] = view;

    return data;
  }
}
