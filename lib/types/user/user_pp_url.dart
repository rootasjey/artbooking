class UserPPUrl {
  final String edited;
  final String original;

  const UserPPUrl({
    this.edited = '',
    this.original = '',
  });

  factory UserPPUrl.empty() {
    return UserPPUrl(
      edited: '',
      original: '',
    );
  }

  factory UserPPUrl.fromJSON(Map<String, dynamic>? data) {
    if (data == null) {
      return UserPPUrl.empty();
    }

    return UserPPUrl(
      edited: data['edited'] ?? '',
      original: data['original'] ?? '',
    );
  }

  UserPPUrl mergeFromValues({
    String? edited,
    String? original,
  }) {
    final newEditedValue = edited ?? this.edited;
    final newOriginalValue = original ?? this.original;

    return UserPPUrl(
      edited: newEditedValue,
      original: newOriginalValue,
    );
  }

  UserPPUrl merge(UserPPUrl userPPUrl) {
    final newEditedValue =
        userPPUrl.edited.isNotEmpty ? userPPUrl.edited : this.edited;
    final newOriginalValue =
        userPPUrl.original.isNotEmpty ? userPPUrl.original : this.original;

    return UserPPUrl(
      edited: newEditedValue,
      original: newOriginalValue,
    );
  }

  Map<String, dynamic> toJSON() {
    final data = Map<String, dynamic>();

    data['edited'] = edited;
    data['original'] = original;

    return data;
  }
}
