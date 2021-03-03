import 'package:artbooking/types/illustration/license_usage.dart';

class IllustrationLicense {
  /// If true the license used is a personal one by the user.
  final bool custom;

  /// If [custom] is true, describes this license.
  final String description;

  /// If [custom] is true, license's name.
  final String name;

  /// References an existing and well known licence.
  final String existingLicenseId;

  /// If [custom] is true, defined what is permitted and is not.
  final LicenseUsage usage;

  IllustrationLicense({
    this.custom,
    this.description,
    this.name,
    this.existingLicenseId,
    this.usage,
  });

  factory IllustrationLicense.fromJSON(Map<String, dynamic> data) {
    return IllustrationLicense(
      custom: data['custom'],
      description: data['description'],
      name: data['name'],
      existingLicenseId: data['refId'],
      usage: LicenseUsage.fromJSON(data['usage']),
    );
  }

  Map<String, dynamic> toJSON() {
    final data = Map<String, dynamic>();

    data['custom'] = custom;
    data['description'] = description;
    data['name'] = name;
    data['refId'] = existingLicenseId;
    data['usage'] = usage.toJSON();

    return data;
  }
}
