import 'dart:collection';

class MinimalObjectId {
  MinimalObjectId({required this.id});

  final String id;

  factory MinimalObjectId.empty() {
    return MinimalObjectId(id: '');
  }

  factory MinimalObjectId.fromJson(LinkedHashMap<Object?, Object?>? data) {
    if (data == null) {
      return MinimalObjectId.empty();
    }

    return MinimalObjectId(
      id: data['id'] as String? ?? '',
    );
  }
}
