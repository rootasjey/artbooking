import 'package:artbooking/types/enums.dart';

String imageVisibilityToString(ContentVisibility visibility) {
  switch (visibility) {
    case ContentVisibility.acl:
      return 'acl';
    case ContentVisibility.challenge:
      return 'challenge';
    case ContentVisibility.contest:
      return 'challenge';
    case ContentVisibility.gallery:
      return 'gallery';
    case ContentVisibility.private:
      return 'private';
    case ContentVisibility.public:
      return 'public';
    default:
      return 'private';
  }
}
