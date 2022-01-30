import 'dart:collection';

import 'package:artbooking/components/dialogs/themed_dialog.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/screens/illustrations/illustration_poster_actions.dart';
import 'package:artbooking/screens/illustrations/illustration_poster_description.dart';
import 'package:artbooking/screens/illustrations/illustration_poster_story.dart';
import 'package:artbooking/types/illustration/illustration.dart';
import 'package:artbooking/types/user/user_firestore.dart';
import 'package:beamer/beamer.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:supercharged/supercharged.dart';

class IllustrationPoster extends StatefulWidget {
  const IllustrationPoster({
    Key? key,
    required this.illustration,
    this.onTapUser,
    this.onLike,
    this.onShare,
    this.onEdit,
  }) : super(key: key);

  final Function()? onEdit;
  final Function()? onLike;
  final Function()? onShare;
  final void Function(UserFirestore)? onTapUser;
  final Illustration illustration;

  @override
  _IllustrationPosterState createState() => _IllustrationPosterState();
}

class _IllustrationPosterState extends State<IllustrationPoster> {
  String _imageUrl = '';
  var _user = UserFirestore.empty();

  @override
  initState() {
    super.initState();
    _imageUrl = widget.illustration.getThumbnail();
    fetchHighResImage();
    fetchAuthor();
  }

  @override
  Widget build(BuildContext context) {
    final illustration = widget.illustration;
    final windowSize = MediaQuery.of(context).size;
    final double maxHeight = windowSize.height * 60 / 100;
    final double maxWidth = illustration.dimensions.getRelativeWidth(
      maxHeight,
    );

    return Column(
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxWidth,
            maxHeight: maxHeight,
          ),
          child: Hero(
            tag: illustration.id,
            child: Card(
              elevation: 6.0,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2.0),
              ),
              child: Ink.image(
                image: NetworkImage(
                  _imageUrl,
                ),
                fit: BoxFit.cover,
                child: InkWell(),
              ),
            ),
          ),
        ),
        Opacity(
          opacity: 0.8,
          child: Text(
            illustration.name,
            style: Utilities.fonts.style(
              fontSize: 20.0,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Wrap(
          children: [
            Opacity(
              opacity: 0.4,
              child: Text(
                "made_by".tr(),
                style: Utilities.fonts.style(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            InkWell(
              onTap: () => widget.onTapUser?.call(_user),
              child: Opacity(
                opacity: 0.6,
                child: Text(
                  " ${_user.name} ",
                  style: Utilities.fonts.style(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Text(
              "• ",
              style: Utilities.fonts.style(
                color: Theme.of(context).primaryColor,
                fontSize: 14.0,
                fontWeight: FontWeight.w600,
              ),
            ),
            InkWell(
              onTap: onTapDate,
              child: Opacity(
                opacity: 0.6,
                child: Text(
                  Jiffy(illustration.createdAt).fromNow(),
                  style: Utilities.fonts.style(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
        IllustrationPosterActions(
          onEdit: widget.onEdit,
          onLike: widget.onLike,
          onShare: widget.onShare,
        ),
        Padding(
          padding: const EdgeInsets.only(
            top: 60.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IllustrationPosterDescription(
                description: illustration.description,
              ),
              IllustrationPosterStory(
                story: illustration.story,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void fetchHighResImage() {
    Future.delayed(
      1.seconds,
      () {
        setState(() {
          _imageUrl = widget.illustration.getHDThumbnail();
        });
      },
    );
  }

  void fetchAuthor() async {
    try {
      final resp = await Utilities.cloud.fun('users-fetchUser').call({
        'userId': widget.illustration.author.id,
      });

      final hashMap = LinkedHashMap.from(resp.data);
      final data = Utilities.cloud.convertFromFun(hashMap);

      if (!mounted) {
        return;
      }

      setState(() => _user = UserFirestore.fromMap(data));
    } catch (error) {
      Utilities.logger.e(error);
    }
  }

  void onTapDate() {
    showDialog(
      context: context,
      builder: (context) {
        return ThemedDialog(
          spaceActive: false,
          centerTitle: false,
          autofocus: true,
          title: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Opacity(
              opacity: 0.8,
              child: Text(
                "dates".tr().toUpperCase(),
                style: Utilities.fonts.style(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          body: Container(
            width: 300.0,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12.0,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      text: "• ${'date_created_at'.tr()} ",
                      style: Utilities.fonts.style(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context)
                            .textTheme
                            .bodyText2
                            ?.color
                            ?.withOpacity(0.6),
                      ),
                      children: [
                        TextSpan(
                          text: Jiffy(widget.illustration.createdAt).fromNow(),
                          style: Utilities.fonts.style(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context)
                                .textTheme
                                .bodyText2
                                ?.color
                                ?.withOpacity(1.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text.rich(
                    TextSpan(
                      text: "• ${'date_updated_at'.tr()} ",
                      style: Utilities.fonts.style(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context)
                            .textTheme
                            .bodyText2
                            ?.color
                            ?.withOpacity(0.6),
                      ),
                      children: [
                        TextSpan(
                          text: Jiffy(widget.illustration.updatedAt).fromNow(),
                          style: Utilities.fonts.style(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context)
                                .textTheme
                                .bodyText2
                                ?.color
                                ?.withOpacity(1.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          textButtonValidation: "close".tr(),
          onValidate: () {
            Beamer.of(context).popRoute();
          },
          onCancel: Beamer.of(context).popRoute,
        );
      },
    );
  }
}
