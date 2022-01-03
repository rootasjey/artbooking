import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdaptiveUserAvatar extends ConsumerWidget {
  const AdaptiveUserAvatar({
    Key? key,
    this.avatarURL = '',
    this.initials = '',
  }) : super(key: key);

  /// If set, this will take priority over [initials] property.
  final String avatarURL;

  /// Show initials letters if [avatarURL] is empty.
  final String initials;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (avatarURL.isNotEmpty) {
      return CircleAvatar(
        backgroundColor: Theme.of(context).backgroundColor,
        radius: 20.0,
        backgroundImage: NetworkImage(avatarURL),
      );
    }

    if (initials.isNotEmpty) {
      return CircleAvatar(
        backgroundColor: Theme.of(context).backgroundColor,
        radius: 20.0,
        child: Text(initials),
      );
    }

    return CircleAvatar();
  }
}
