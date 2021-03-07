import 'package:artbooking/types/v_scale_factor.dart';

class BookIllustration {
  /// Firesotre id.
  final String id;

  VScaleFactor vScaleFactor;

  BookIllustration({
    this.id,
    this.vScaleFactor,
  });

  factory BookIllustration.fromJSON(Map<String, dynamic> data) {
    return BookIllustration(
      id: data['id'],
      vScaleFactor: VScaleFactor.fromJSON(data['vScaleFactor']),
    );
  }
}
