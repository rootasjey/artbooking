class MinimalIllustrationResp {
  final String id;

  MinimalIllustrationResp({required this.id});

  factory MinimalIllustrationResp.empty() {
    return MinimalIllustrationResp(
      id: '',
    );
  }

  factory MinimalIllustrationResp.fromJSON(Map<dynamic, dynamic>? data) {
    if (data == null) {
      return MinimalIllustrationResp.empty();
    }

    return MinimalIllustrationResp(
      id: data['id'],
    );
  }
}
