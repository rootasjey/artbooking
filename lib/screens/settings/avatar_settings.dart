import 'package:artbooking/components/avatar/better_avatar.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class AvatarSettings extends StatelessWidget {
  final String profilePicture;
  final VoidCallback onUploadProfilePicture;
  final VoidCallback onTapProfilePicture;

  const AvatarSettings({
    Key? key,
    required this.profilePicture,
    required this.onUploadProfilePicture,
    required this.onTapProfilePicture,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 42.0,
              right: 8.0,
            ),
            child: BetterAvatar(
              size: 160.0,
              image: NetworkImage(profilePicture),
              colorFilter: ColorFilter.mode(
                Colors.grey,
                BlendMode.saturation,
              ),
              onTap: onTapProfilePicture,
            ),
          ),
          Opacity(
            opacity: 0.6,
            child: IconButton(
              tooltip: "pp_upload".tr(),
              onPressed: onUploadProfilePicture,
              icon: Icon(UniconsLine.upload),
            ),
          ),
        ],
      ),
    );
  }
}
