import 'package:artbooking/types/enums.dart';

String imageVisibilityToString(ImageVisibility visibility) {
  switch (visibility) {
    case ImageVisibility.acl:
      return 'acl';
    case ImageVisibility.challenge:
      return 'challenge';
    case ImageVisibility.contest:
      return 'challenge';
    case ImageVisibility.gallery:
      return 'gallery';
    case ImageVisibility.private:
      return 'private';
    case ImageVisibility.public:
      return 'public';
    default:
      return 'private';
  }
}
