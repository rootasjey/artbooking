import 'dart:collection';

/// Cloud functions minimal object returned.
class MinimalObjectId {
  MinimalObjectId({required this.id});

  /// Object's id.
  final String id;

  factory MinimalObjectId.empty() {
    return MinimalObjectId(id: '');
  }

  factory MinimalObjectId.fromJSON(LinkedHashMap<Object?, Object?>? data) {
    if (data == null) {
      return MinimalObjectId.empty();
    }

    return MinimalObjectId(
      id: data['id'] as String? ?? '',
    );
  }
}
