/// A book class with only an id.
class MinimalBookResp {
  final String id;

  MinimalBookResp({required this.id});

  factory MinimalBookResp.empty() {
    return MinimalBookResp(
      id: '',
    );
  }

  factory MinimalBookResp.fromJSON(Map<dynamic, dynamic>? data) {
    if (data == null) {
      return MinimalBookResp.empty();
    }

    return MinimalBookResp(
      id: data['id'],
    );
  }
}
