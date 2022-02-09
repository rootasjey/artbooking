import 'dart:typed_data';

import 'package:animations/animations.dart';
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
import 'package:artbooking/types/user/user_firestore.dart';
import 'package:beamer/beamer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:extended_image/extended_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flash/src/flash_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mime_type/mime_type.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class IllustrationPage extends ConsumerStatefulWidget {
  /// Illustration's id, used if direct navigation by url.
  final String illustrationId;

  /// True if navigating from dashboard.
  final bool? fromDashboard;

  const IllustrationPage({
    Key? key,
    required this.illustrationId,
    this.fromDashboard = false,
  }) : super(key: key);

  @override
  _IllustrationPageState createState() => _IllustrationPageState();
}

class _IllustrationPageState extends ConsumerState<IllustrationPage> {
  /// True if data is loading.
  bool _isLoading = false;
  bool _updatingImage = false;
  var _illustration = Illustration.empty();

  DocSnapshotStreamSubscription? _subscription;

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
      return;
    }

    fetchIllustration();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final UserFirestore? userFirestore =
        ref.watch(AppState.userProvider).firestoreUser;

    final bool isOwner = userFirestore?.id == _illustration.userId;

    return HeroControllerScope(
      controller: HeroController(),
      child: Scaffold(
        floatingActionButton: IllustrationPageFab(
          isVisible: isOwner,
          onShowEditMetadataPanel: onShowEditMetadataPanel,
        ),
        body: Stack(
          children: [
            NotificationListener(
              child: CustomScrollView(
                slivers: [
                  ApplicationBar(),
                  IllustrationPageBody(
                    isLoading: _isLoading,
                    updatingImage: _updatingImage,
                    illustration: _illustration,
                    onShowEditMetadataPanel: onShowEditMetadataPanel,
                    onGoToEditImagePage: onGoToEditImagePage,
                    onLike: onLike,
                    onShare: onShare,
                  ),
                ],
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

  /// Listen to Firestore document changes.
  void listenToIllustrationChanges(
      DocumentReference<Map<String, dynamic>> query) {
    _subscription = query.snapshots().skip(1).listen(
      (snapshot) {
        if (!snapshot.exists) {
          _subscription?.cancel();
          return;
        }

        final Json? data = snapshot.data();
        if (data == null) {
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
        _subscription?.cancel();
      },
    );
  }

  void onShowEditMetadataPanel() async {
    await showCupertinoModalBottomSheet(
      context: context,
      builder: (context) => EditIllustrationPage(
        illustration: _illustration,
      ),
    );

    fetchIllustration(silent: true);
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

    try {
      final firestoreUser = ref.read(AppState.userProvider).firestoreUser;
      if (firestoreUser == null) {
        throw ErrorDescription("user_not_connected".tr());
      }

      await FirebaseFirestore.instance
          .collection("users")
          .doc(firestoreUser.id)
          .collection("likes")
          .doc(_illustration.id)
          .set({
        "type": "illustration",
        "targetId": _illustration.id,
      });
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
}
