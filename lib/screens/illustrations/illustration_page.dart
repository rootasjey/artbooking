import 'dart:typed_data';

import 'package:animations/animations.dart';
import 'package:artbooking/components/custom_scroll_behavior.dart';
import 'package:artbooking/components/popup_progress_indicator.dart';
import 'package:artbooking/globals/app_state.dart';
import 'package:artbooking/screens/edit_image/edit_image_page.dart';
import 'package:artbooking/screens/illustrations/edit/edit_illustration_page.dart';
import 'package:artbooking/screens/illustrations/illustration_page_body.dart';
import 'package:artbooking/components/application_bar/application_bar.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/router/navigation_state_helper.dart';
import 'package:artbooking/screens/illustrations/illustration_page_fab.dart';
import 'package:artbooking/types/firestore/doc_snapshot_stream_subscription.dart';
import 'package:artbooking/types/illustration/illustration.dart';
import 'package:artbooking/types/json_types.dart';
import 'package:beamer/beamer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:extended_image/extended_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flash/src/flash_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_improved_scrolling/flutter_improved_scrolling.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mime_type/mime_type.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class IllustrationPage extends ConsumerStatefulWidget {
  const IllustrationPage({
    Key? key,
    required this.illustrationId,
  }) : super(key: key);

  /// Illustration's id, used if direct navigation by url.
  final String illustrationId;

  @override
  _IllustrationPageState createState() => _IllustrationPageState();
}

class _IllustrationPageState extends ConsumerState<IllustrationPage> {
  /// True if data is loading.
  bool _isLoading = false;
  bool _updatingImage = false;
  bool _liked = false;

  var _illustration = Illustration.empty();

  /// Listen to changes for this illustration.
  DocSnapshotStreamSubscription? _illustrationSubscription;

  /// Listent to changes for this illustration's like status.
  DocSnapshotStreamSubscription? _likeSubscription;

  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final Illustration? illustrationFromNav =
        NavigationStateHelper.illustration;

    if (illustrationFromNav != null &&
        illustrationFromNav.id == widget.illustrationId) {
      _illustration = illustrationFromNav;

      final query = FirebaseFirestore.instance
          .collection('illustrations')
          .doc(_illustration.id);

      listenToIllustrationChanges(query);
      fetchLike();
      return;
    }

    fetchIllustration();
  }

  @override
  void dispose() {
    _illustrationSubscription?.cancel();
    _likeSubscription?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String? userId = ref.watch(AppState.userProvider).firestoreUser?.id;

    final bool authenticated = userId != null && userId.isNotEmpty;
    final bool isOwner = userId == _illustration.userId;

    return HeroControllerScope(
      controller: HeroController(),
      child: Scaffold(
        floatingActionButton: IllustrationPageFab(
          isVisible: isOwner,
          onShowEditMetadataPanel: onShowEditMetadataPanel,
        ),
        body: Stack(
          children: [
            ImprovedScrolling(
              scrollController: _scrollController,
              child: ScrollConfiguration(
                behavior: CustomScrollBehavior(),
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    ApplicationBar(),
                    IllustrationPageBody(
                      isOwner: isOwner,
                      isLoading: _isLoading,
                      updatingImage: _updatingImage,
                      illustration: _illustration,
                      onShowEditMetadataPanel: onShowEditMetadataPanel,
                      onGoToEditImagePage: onGoToEditImagePage,
                      onLike: authenticated ? onLike : null,
                      onShare: onShare,
                      liked: _liked,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 100.0,
              right: 24.0,
              child: PopupProgressIndicator(
                show: _updatingImage,
                message: "image_updating".tr() + "...",
                onClose: () {
                  setState(() {
                    _updatingImage = false;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void fetchIllustration({bool silent = false}) async {
    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = !silent;
    });

    try {
      final query = FirebaseFirestore.instance
          .collection('illustrations')
          .doc(widget.illustrationId);

      listenToIllustrationChanges(query);

      final snapshot = await query.get();
      final data = snapshot.data();

      if (!snapshot.exists || data == null) {
        context.showErrorBar(
          content: Text(
            "The illustration with the id ${widget.illustrationId} doesn't exist.",
          ),
        );

        return;
      }

      data['id'] = snapshot.id;

      setState(() {
        _illustration = Illustration.fromMap(data);
        _isLoading = false;
      });

      fetchLike();
    } catch (error) {
      Utilities.logger.e(error);

      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  void fetchLike() async {
    final String? userId = ref.read(AppState.userProvider).firestoreUser?.id;
    if (userId == null || userId.isEmpty) {
      return;
    }

    try {
      _likeSubscription = await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("user_likes")
          .doc(_illustration.id)
          .snapshots()
          .listen((snapshot) {
        setState(() {
          _liked = snapshot.exists;
        });
      }, onDone: () {
        _likeSubscription?.cancel();
      });
    } catch (error) {
      Utilities.logger.e(error);
    }
  }

  /// Listen to Firestore document changes.
  void listenToIllustrationChanges(
      DocumentReference<Map<String, dynamic>> query) {
    _illustrationSubscription = query.snapshots().skip(1).listen(
      (snapshot) {
        if (!snapshot.exists) {
          _illustrationSubscription?.cancel();
          return;
        }

        final Json? data = snapshot.data();
        if (data == null) {
          return;
        }

        if (!mounted) {
          return;
        }

        setState(() {
          data['id'] = snapshot.id;
          _illustration = Illustration.fromMap(data);
          _updatingImage = false;
        });
      },
      onError: (error, stack) {
        Utilities.logger.e(error);
        Utilities.logger.e(stack);
        context.showErrorBar(content: Text(error.toString()));
      },
      onDone: () {
        _illustrationSubscription?.cancel();
      },
    );
  }

  void onShowEditMetadataPanel() async {
    await showCupertinoModalBottomSheet(
      context: context,
      builder: (context) => EditIllustrationPage(
          illustration: _illustration, goToEditImagePage: goToEditImagePage),
    );
  }

  void onGoToEditImagePage() {
    Navigator.of(context).push(
      PageRouteBuilder(pageBuilder: (context, animation, secondaryAnimation) {
        return EditImagePage(
          heroTag: _illustration.id,
          onSave: onSaveEditedIllustration,
          dimensions: _illustration.dimensions,
          imageToEdit: ExtendedNetworkImageProvider(
            _illustration.links.original,
            cache: true,
            cacheRawData: true,
            cacheMaxAge: const Duration(seconds: 3),
          ),
          goToEditIllustrationMetada: goToEditIllustrationMetada,
        );
      }, transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeScaleTransition(
          animation: animation,
          child: child,
        );
      }),
    );
  }

  void onLike() async {
    if (_illustration.id.isEmpty) {
      return;
    }

    if (_liked) {
      return tryUnLike();
    }

    return tryLike();
  }

  void tryLike() async {
    try {
      final String? userId = ref.read(AppState.userProvider).firestoreUser?.id;

      await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("user_likes")
          .doc(_illustration.id)
          .set({
        "type": "illustration",
        "target_id": _illustration.id,
        "user_id": userId,
      });
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    }
  }

  void tryUnLike() async {
    try {
      final String? userId = ref.read(AppState.userProvider).firestoreUser?.id;

      await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("user_likes")
          .doc(_illustration.id)
          .delete();
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    }
  }

  void onSaveEditedIllustration(Uint8List? editedImageData) async {
    if (editedImageData == null) {
      return;
    }

    Beamer.of(context).popRoute();

    setState(() => _updatingImage = true);

    try {
      final firestoreUser = ref.read(AppState.userProvider).firestoreUser;
      if (firestoreUser == null) {
        throw Exception("user_not_connected".tr());
      }

      final String userId = firestoreUser.id;
      final String illustrationId = _illustration.id;

      if (userId.isEmpty) {
        throw Exception("user_not_connected".tr());
      }

      final String extension = _illustration.extension;

      final String cloudStorageFilePath =
          "users/$userId/illustrations/$illustrationId/original.$extension";

      final storage = FirebaseStorage.instance;
      final UploadTask uploadTask = storage.ref(cloudStorageFilePath).putData(
            editedImageData,
            SettableMetadata(
              customMetadata: {
                "extension": extension,
                "firestoreId": illustrationId,
                "userId": userId,
                "visibility": "public",
              },
              contentType: mimeFromExtension(extension),
            ),
          );

      await uploadTask;
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    }
  }

  void onShare() async {}

  void goToEditIllustrationMetada() async {
    await Beamer.of(context).popRoute();
    onShowEditMetadataPanel();
  }

  void goToEditImagePage() async {
    await Beamer.of(context).popRoute();
    onGoToEditImagePage();
  }
}
