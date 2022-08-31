import 'package:artbooking/components/dialogs/themed_dialog.dart';
import 'package:artbooking/components/hero_image.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/screens/illustrations/illustration_poster_actions.dart';
import 'package:artbooking/screens/illustrations/illustration_poster_description.dart';
import 'package:artbooking/screens/illustrations/illustration_poster_story.dart';
import 'package:artbooking/types/illustration/illustration.dart';
import 'package:artbooking/types/json_types.dart';
import 'package:artbooking/types/user/user_firestore.dart';
import 'package:beamer/beamer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:supercharged/supercharged.dart';

class IllustrationPoster extends StatefulWidget {
  const IllustrationPoster({
    Key? key,
    required this.illustration,
    this.isOwner = false,
    this.liked = false,
    this.onTapUser,
    this.onLike,
    this.onShare,
    this.onShowEditMetadataPanel,
    this.onGoToEditImagePage,
    this.updatingImage = false,
    this.heroTag = "",
  }) : super(key: key);

  /// True if the current authenticated user is the owner of this illustration.
  final bool isOwner;

  /// True if the current authenticated user has liked this illustration.
  final bool liked;

  /// True if the image is being updated
  /// after a transformation (crop, rotate, flip).
  final bool updatingImage;

  /// Edit metadata (title, description, license, ...).
  final Function()? onShowEditMetadataPanel;

  /// Fired on crop, rotate, or flip image.
  final Function()? onGoToEditImagePage;

  /// Fired when an user likes this illustration.
  final Function()? onLike;

  /// Fired when an user wants to share this illustration.
  final Function()? onShare;

  /// Callback when tapping on this illustration's owner.
  final void Function(UserFirestore)? onTapUser;

  /// This component's data.
  final Illustration illustration;

  /// Custom hero tag.
  /// To use when default `illustration.id` hero tag is not enough
  /// (Use-case: inside a book where there can be duplicated illustrations).
  final String heroTag;

  @override
  _IllustrationPosterState createState() => _IllustrationPosterState();
}

class _IllustrationPosterState extends State<IllustrationPoster> {
  /// Illustration image url.
  String _imageUrl = "";

  /// Illustration image version.
  /// When version changes, image url is fetched.
  int _version = -1;

  /// Illustration's owner.
  var _user = UserFirestore.empty();

  @override
  initState() {
    super.initState();
    _imageUrl = widget.illustration.getThumbnail();
    fetchAuthor();
  }

  @override
  Widget build(BuildContext context) {
    final Illustration illustration = widget.illustration;
    final Size windowSize = MediaQuery.of(context).size;
    final bool isMobileSize =
        windowSize.width < Utilities.size.mobileWidthTreshold;

    final double maxHeight =
        isMobileSize ? windowSize.width - 20.0 : windowSize.height * 60 / 100;

    final double maxWidth = illustration.dimensions.getRelativeWidth(
      maxHeight,
    );

    if (_version != illustration.version) {
      _version = illustration.version;
      fetchHighResImage();
    }

    final String heroTag =
        widget.heroTag.isNotEmpty ? widget.heroTag : illustration.id;

    final void Function()? onTapUserOrNull =
        widget.onTapUser != null ? () => widget.onTapUser?.call(_user) : null;

    return Column(
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxWidth,
            maxHeight: maxHeight,
          ),
          child: Hero(
            tag: heroTag,
            child: Card(
              elevation: 6.0,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2.0),
              ),
              child: Ink.image(
                image: ExtendedNetworkImageProvider(
                  _imageUrl,
                  cache: true,
                  imageCacheName: widget.illustration.id,
                  cacheKey: widget.illustration.id,
                ),
                fit: BoxFit.cover,
                child: InkWell(
                  onTap: onTapImage,
                ),
              ),
            ),
          ),
        ),
        Opacity(
          opacity: 0.8,
          child: Text(
            illustration.name,
            textAlign: isMobileSize ? TextAlign.center : TextAlign.start,
            style: Utilities.fonts.body(
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
                style: Utilities.fonts.body(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            InkWell(
              onTap: onTapUserOrNull,
              child: Opacity(
                opacity: 0.6,
                child: Text(
                  " ${_user.name} ",
                  style: Utilities.fonts.body(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Text(
              "• ",
              style: Utilities.fonts.body(
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
                  Jiffy(illustration.updatedAt).fromNow(),
                  style: Utilities.fonts.body(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
        IllustrationPosterActions(
          isOwner: widget.isOwner,
          liked: widget.liked,
          onEdit: widget.onShowEditMetadataPanel,
          onEditImage: widget.onGoToEditImagePage,
          onLike: widget.onLike,
          onShare: widget.onShare,
          updatingImage: widget.updatingImage,
        ),
        Container(
          width: 500.0,
          padding: const EdgeInsets.only(
            top: 60.0,
            left: 12.0,
            right: 12.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IllustrationPosterDescription(
                description: illustration.description,
              ),
              IllustrationPosterStory(
                story: illustration.lore,
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

  /// Fetch author from Firestore doc public data (fast).
  Future<bool> fetchAuthor() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.illustration.userId)
          .collection("user_public_fields")
          .doc("base")
          .get();

      final Json? data = snapshot.data();

      if (!snapshot.exists || data == null) {
        return false;
      }

      setState(() {
        data["id"] = widget.illustration.userId;
        _user = UserFirestore.fromMap(data);
      });

      return true;
    } catch (error) {
      Utilities.logger.e(error);
      return false;
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
                style: Utilities.fonts.body(
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
                      style: Utilities.fonts.body(
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
                          style: Utilities.fonts.body(
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
                      style: Utilities.fonts.body(
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
                          style: Utilities.fonts.body(
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

  void onTapImage() {
    context.pushTransparentRoute(
      HeroImage(
        heroTag: widget.heroTag,
        imageProvider: NetworkImage(_imageUrl),
      ),
    );
  }
}
