import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/user/user_pp_path.dart';
import 'package:artbooking/types/user/user_pp_url.dart';

class UserPP {
  String ext;
  int size;
  DateTime? updatedAt;
  UserPPPath path;
  UserPPUrl url;

  UserPP({
    this.ext = '',
    this.size = 0,
    this.updatedAt,
    this.path = const UserPPPath(),
    this.url = const UserPPUrl(),
  });

  factory UserPP.empty() {
    return UserPP(
      ext: '',
      size: 0,
      updatedAt: DateTime.now(),
      path: UserPPPath.empty(),
      url: UserPPUrl.empty(),
    );
  }

  factory UserPP.fromJSON(Map<String, dynamic>? data) {
    if (data == null) {
      return UserPP.empty();
    }

    return UserPP(
      ext: data['ext'],
      updatedAt: Utilities.date.fromFirestore(data['updatedAt']),
      path: UserPPPath.fromJSON(data['path']),
      url: UserPPUrl.fromJSON(data['url']),
    );
  }

  Map<String, dynamic> toJSON() {
    final data = Map<String, dynamic>();

    data['ext'] = ext;
    data['size'] = size;
    data['updatedAt'] = updatedAt!.millisecondsSinceEpoch;
    data['path'] = path.toJSON();
    data['url'] = url.toJSON();

    return data;
  }

  void merge({
    String? ext,
    int? size,
    UserPPPath? path,
    UserPPUrl? url,
  }) {
    if (ext != null) {
      this.ext = ext;
    }

    if (size != null) {
      this.size = size;
    }

    this.updatedAt = DateTime.now();

    if (path != null) {
      this.path = this.path.merge(path);
    }

    if (url != null) {
      this.url = this.url.merge(url);
    }
  }

  void update(UserPP userPP) {
    ext = userPP.ext;
    size = userPP.size;
    updatedAt = userPP.updatedAt;
    path = userPP.path;
    url = userPP.url;
  }
}
