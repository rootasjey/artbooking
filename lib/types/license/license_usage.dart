import 'dart:convert';

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

  factory LicenseUsage.fromMap(Map<String, dynamic>? data) {
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

  Map<String, dynamic> toMap() {
    return {
      'adapt': adapt,
      'commercial': commercial,
      'foss': foss,
      'free': free,
      'oss': oss,
      'personal': personal,
      'print': print,
      'sell': sell,
      'share': share,
      'view': view,
    };
  }

  LicenseUsage copyWith({
    bool? adapt,
    bool? commercial,
    bool? foss,
    bool? free,
    bool? oss,
    bool? personal,
    bool? print,
    bool? sell,
    bool? share,
    bool? view,
  }) {
    return LicenseUsage(
      adapt: adapt ?? this.adapt,
      commercial: commercial ?? this.commercial,
      foss: foss ?? this.foss,
      free: free ?? this.free,
      oss: oss ?? this.oss,
      personal: personal ?? this.personal,
      print: print ?? this.print,
      sell: sell ?? this.sell,
      share: share ?? this.share,
      view: view ?? this.view,
    );
  }

  String toJson() => json.encode(toMap());

  factory LicenseUsage.fromJson(String source) =>
      LicenseUsage.fromMap(json.decode(source));

  @override
  String toString() {
    return 'LicenseUsage(adapt: $adapt, commercial: $commercial, foss: $foss, '
        'free: $free, oss: $oss, personal: $personal, print: $print, sell: $sell, '
        'share: $share, view: $view)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LicenseUsage &&
        other.adapt == adapt &&
        other.commercial == commercial &&
        other.foss == foss &&
        other.free == free &&
        other.oss == oss &&
        other.personal == personal &&
        other.print == print &&
        other.sell == sell &&
        other.share == share &&
        other.view == view;
  }

  @override
  int get hashCode {
    return adapt.hashCode ^
        commercial.hashCode ^
        foss.hashCode ^
        free.hashCode ^
        oss.hashCode ^
        personal.hashCode ^
        print.hashCode ^
        sell.hashCode ^
        share.hashCode ^
        view.hashCode;
  }
}
