import 'dart:collection';

import 'package:artbooking/components/better_avatar.dart';
import 'package:artbooking/types/user/user_firestore.dart';
import 'package:artbooking/utils/app_logger.dart';
import 'package:artbooking/utils/cloud_helper.dart';
import 'package:artbooking/utils/fonts.dart';
import 'package:flutter/material.dart';

class AuthorHeader extends StatefulWidget {
  final String? authorId;
  final EdgeInsets padding;

  const AuthorHeader({
    Key? key,
    required this.authorId,
    this.padding = EdgeInsets.zero,
  }) : super(key: key);

  @override
  _AuthorHeaderState createState() => _AuthorHeaderState();
}

class _AuthorHeaderState extends State<AuthorHeader> {
  UserFirestore _user = UserFirestore.empty();

  @override
  void initState() {
    super.initState();
    fetch();
  }

  @override
  Widget build(BuildContext context) {
    final userPP = _user.getPP();

    final avatarUrl = userPP.isNotEmpty
        ? userPP
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
              onTap: () {},
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
                    _user.name!,
                    style: FontsUtils.mainStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Opacity(
                  opacity: 0.4,
                  child: Text(
                    _user.location,
                    style: FontsUtils.mainStyle(
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

  void fetch() async {
    try {
      final resp = await Cloud.fun('users-fetchUser').call({
        'userId': widget.authorId,
      });

      final hashMap = LinkedHashMap.from(resp.data);
      final data = Cloud.convertFromFun(hashMap);

      if (!mounted) {
        return;
      }

      setState(() => _user = UserFirestore.fromJSON(data));
    } catch (error) {
      appLogger.e(error);
    }
  }
}
