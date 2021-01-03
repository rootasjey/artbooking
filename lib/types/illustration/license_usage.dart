class LicenseUsage {
  /// Can add or remove part of the illustration.
  final bool edit;

  /// Allowed to print the illustration.
  final bool print;

  /// Can sell outside of the official app by another individual.
  final bool sell;

  /// Can share outside of the official app.
  final bool share;

  /// Can be used in another free software
  final bool useInOtherFree;

  /// Show illustrations's credits (author, source, url).
  final bool showAttribution;

  /// Can be used in another open source software.
  final bool useInOtherOss;

  /// Can be used in another paid software.
  final bool useInOtherPaid;

  /// Can view this illustration.
  final bool view;

  LicenseUsage({
    this.edit,
    this.print,
    this.sell,
    this.share,
    this.showAttribution,
    this.useInOtherFree,
    this.useInOtherOss,
    this.useInOtherPaid,
    this.view,
  });

  factory LicenseUsage.fromJSON(Map<String, dynamic> data) {
    return LicenseUsage(
      edit: data['edit'],
      print: data['print'],
      sell: data['sell'],
      share: data['share'],
      showAttribution: data['showAttribution'],
      useInOtherFree: data['useInOtherFree'],
      useInOtherOss: data['useInOtherOss'],
      useInOtherPaid: data['useInOtherPaid'],
      view: data['view'],
    );
  }
}
