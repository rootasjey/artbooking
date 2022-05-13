import 'package:artbooking/components/avatar/better_avatar.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/router/locations/home_location.dart';
import 'package:artbooking/types/json_types.dart';
import 'package:artbooking/types/user/user_firestore.dart';
import 'package:beamer/beamer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// A component showing user's avatar, name, and location.
/// Tapping on the avatar will redirect to user's profile page.
class UserAvatarExtended extends StatefulWidget {
  final String userId;
  final EdgeInsets padding;

  const UserAvatarExtended({
    Key? key,
    required this.userId,
    this.padding = EdgeInsets.zero,
  }) : super(key: key);

  @override
  _UserAvatarExtendedState createState() => _UserAvatarExtendedState();
}

class _UserAvatarExtendedState extends State<UserAvatarExtended> {
  UserFirestore _user = UserFirestore.empty();

  @override
  void initState() {
    super.initState();
    fetchAuthor();
  }

  @override
  Widget build(BuildContext context) {
    final profilePicture = _user.getProfilePicture();

    final avatarUrl = profilePicture.isNotEmpty
        ? profilePicture
        : "https://img.icons8.com/plasticine/100/000000/flower.png";

    return Padding(
      padding: widget.padding,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Hero(
            tag: 'pp',
            child: BetterAvatar(
              size: 60.0,
              image: NetworkImage(avatarUrl),
              colorFilter: ColorFilter.mode(
                Colors.grey,
                BlendMode.saturation,
              ),
              onTap: goToUserProfile,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Opacity(
                  opacity: 0.8,
                  child: Text(
                    _user.name,
                    style: Utilities.fonts.body(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Opacity(
                  opacity: 0.4,
                  child: Text(
                    _user.location,
                    style: Utilities.fonts.body(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Fetch author from Firestore doc public data (fast).
  void fetchAuthor() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.userId)
          .collection("user_public_fields")
          .doc("base")
          .get();

      final Json? data = snapshot.data();

      if (!snapshot.exists || data == null) {
        return;
      }

      setState(() {
        data["id"] = widget.userId;
        _user = UserFirestore.fromMap(data);
      });
    } catch (error) {
      Utilities.logger.e(error);
    }
  }

  void goToUserProfile() {
    Beamer.of(context).beamToNamed(
      HomeLocation.profileRoute.replaceFirst(":userId", widget.userId),
      data: {"userId": widget.userId},
    );
  }
}
