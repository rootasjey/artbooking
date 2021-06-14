/// Part of the license specifing what you can do the artwork.
class LicenseUsage {
  /// remix, transform, and build upon the material
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

  ///Can be used for personal use (e.g. wallpaper).
  final bool personal;

  /// Can be freely printed.
  final bool print;

  /// Can sell outside of the official app by another individual.
  final bool sell;

  /// copy and redistribute the material in any medium or format.
  final bool share;

  /// Can view this illustration.
  final bool view;

  LicenseUsage({
    this.commercial,
    this.adapt,
    this.foss,
    this.free,
    this.oss,
    this.personal,
    this.print,
    this.sell,
    this.share,
    this.view,
  });

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

  factory LicenseUsage.fromJSON(Map<String, dynamic> data) {
    if (data == null) {
      return LicenseUsage.empty();
    }

    return LicenseUsage(
      commercial: data['commercial'],
      adapt: data['adapt'],
      foss: data['foss'],
      free: data['free'],
      oss: data['oss'],
      personal: data['personal'],
      print: data['print'],
      sell: data['sell'],
      share: data['share'],
      view: data['view'],
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
