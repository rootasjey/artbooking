import 'dart:typed_data';

import 'package:animations/animations.dart';
import 'package:artbooking/components/buttons/visibility_button.dart';
import 'package:artbooking/components/custom_scroll_behavior.dart';
import 'package:artbooking/components/dialogs/share_dialog.dart';
import 'package:artbooking/components/dialogs/themed_dialog.dart';
import 'package:artbooking/components/popup_progress_indicator.dart';
import 'package:artbooking/globals/app_state.dart';
import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/router/locations/atelier_location.dart';
import 'package:artbooking/router/locations/home_location.dart';
import 'package:artbooking/screens/edit_image/edit_image_page.dart';
import 'package:artbooking/screens/illustrations/edit/edit_illustration_page.dart';
import 'package:artbooking/screens/illustrations/illustration_page_body.dart';
import 'package:artbooking/components/application_bar/application_bar.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/router/navigation_state_helper.dart';
import 'package:artbooking/screens/illustrations/illustration_page_fab.dart';
import 'package:artbooking/types/enums/enum_content_visibility.dart';
import 'package:artbooking/types/enums/enum_share_content_type.dart';
import 'package:artbooking/types/firestore/doc_snapshot_stream_subscription.dart';
import 'package:artbooking/types/firestore/document_map.dart';
import 'package:artbooking/types/firestore/document_snapshot_map.dart';
import 'package:artbooking/types/illustration/illustration.dart';
import 'package:artbooking/types/json_types.dart';
import 'package:artbooking/types/user/user_firestore.dart';
import 'package:beamer/beamer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:extended_image/extended_image.dart';
import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flash/src/flash_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_improved_scrolling/flutter_improved_scrolling.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mime_type/mime_type.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:unicons/unicons.dart';
import 'package:url_launcher/url_launcher.dart';

class IllustrationPage extends ConsumerStatefulWidget {
  const IllustrationPage({
    Key? key,
    required this.illustrationId,
    this.heroTag = "",
  }) : super(key: key);

  /// Illustration's id, used if direct navigation by url.
  final String illustrationId;

  /// Custom hero tag (if `illustration.id` default tag is not unique).
  final String heroTag;

  @override
  _IllustrationPageState createState() => _IllustrationPageState();
}

class _IllustrationPageState extends ConsumerState<IllustrationPage> {
  /// Listen to route to deaactivate file drop on this page
  /// (see `DropTarget.enable` property for more information).
  BeamerDelegate? _beamer;

  /// True if the illustration is being downloaded.
  bool _downloading = false;

  /// Disable file drop when navigating to a new page.
  bool _enableFileDrop = true;

  /// If true, a file is being dragged on the app window.
  bool _isDraggingFile = false;

  /// True if data is loading.
  bool _loading = false;

  /// True if the illustration is being updated.
  bool _updatingImage = false;

  /// True if the illustration is liked by the current authenticated user.
  bool _liked = false;

  /// Illustration of this page.
  var _illustration = Illustration.empty();

  /// Listen to changes for this illustration.
  DocSnapshotStreamSubscription? _illustrationSubscription;

  /// Listen to changes for this illustration's like status.
  DocSnapshotStreamSubscription? _likeSubscription;

  /// Page scroll controller.
  final _pageScrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // NOTE: Beamer state isn't ready on 1st frame.
    // So we use [addPostFrameCallback] to access the state in the next frame.
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      _beamer = Beamer.of(context);
      Beamer.of(context).addListener(onRouteUpdate);
    });

    final Illustration? illustrationFromNav =
        NavigationStateHelper.illustration;

    if (illustrationFromNav != null &&
        illustrationFromNav.id == widget.illustrationId) {
      _illustration = illustrationFromNav;

      final DocumentMap query = FirebaseFirestore.instance
          .collection("illustrations")
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
    _pageScrollController.dispose();
    _beamer?.removeListener(onRouteUpdate);
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
          show: true,
          isOwner: isOwner,
          onDownload: tryDownload,
          onCreateNewVersion: onCreateNewVersion,
        ),
        body: DropTarget(
          // for file drop -> upload illustration.
          enable: _enableFileDrop && isOwner,
          onDragDone: onDragFileDone,
          onDragEntered: onDragFileEntered,
          onDragExited: onDragFileExited,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Constants.colors.tertiary,
                    width: 4.0,
                    style:
                        _isDraggingFile ? BorderStyle.solid : BorderStyle.none,
                  ),
                ),
                child: ImprovedScrolling(
                  scrollController: _pageScrollController,
                  child: ScrollConfiguration(
                    behavior: CustomScrollBehavior(),
                    child: CustomScrollView(
                      controller: _pageScrollController,
                      slivers: [
                        ApplicationBar(),
                        IllustrationPageBody(
                          isOwner: isOwner,
                          loading: _loading,
                          heroTag: widget.heroTag,
                          updatingImage: _updatingImage,
                          illustration: _illustration,
                          onShowEditMetadataPanel: onShowEditMetadataPanel,
                          onGoToEditImagePage: onGoToEditImagePage,
                          onLike: authenticated ? onLike : null,
                          onShare: onShare,
                          liked: _liked,
                          onTapUser: onTapUser,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              popupProgressIndicator(),
              dropHint(),
            ],
          ),
        ),
      ),
    );
  }

  Widget dropHint() {
    if (!_isDraggingFile) {
      return Container();
    }

    return Positioned(
      bottom: 24.0,
      left: 0.0,
      right: 0.0,
      child: Align(
        alignment: Alignment.center,
        child: SizedBox(
          width: 500.0,
          child: Card(
            elevation: 6.0,
            color: Constants.colors.tertiary,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Icon(
                      UniconsLine.tear,
                      color: Colors.black,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "illustration_upload_file_to_existing".tr(),
                      style: Utilities.fonts.body(
                        color: Colors.black,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget popupProgressIndicator() {
    String message = "";

    if (_downloading) {
      message = "downloading".tr();
    } else if (_updatingImage) {
      message = "image_updating".tr();
    }

    return Positioned(
      top: 100.0,
      right: 24.0,
      child: PopupProgressIndicator(
        icon: Icon(
          _downloading ? UniconsLine.download_alt : UniconsLine.upload_alt,
          color: Constants.colors.secondary,
        ),
        show: _updatingImage || _downloading,
        message: message + "...",
        onClose: () {
          setState(() {
            _updatingImage = false;
            _downloading = false;
          });
        },
      ),
    );
  }

  void fetchIllustration({bool silent = false}) async {
    if (!mounted) {
      return;
    }

    setState(() {
      _loading = !silent;
    });

    try {
      final DocumentMap query = FirebaseFirestore.instance
          .collection("illustrations")
          .doc(widget.illustrationId);

      listenToIllustrationChanges(query);

      final DocumentSnapshotMap snapshot = await query.get();
      final Json? data = snapshot.data();

      if (!snapshot.exists || data == null) {
        context.showErrorBar(
          content: Text(
            "illustration_not_found_with_id".tr(args: [_illustration.id]),
          ),
        );

        return;
      }

      data["id"] = snapshot.id;

      setState(() {
        _illustration = Illustration.fromMap(data);
        _loading = false;
      });

      fetchLike();
    } catch (error) {
      Utilities.logger.e(error);

      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
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

  String getUserRoute(UserFirestore userFirestore) {
    final location = Beamer.of(context)
        .beamingHistory
        .last
        .history
        .last
        .routeInformation
        .location;

    if (location == null) {
      return HomeLocation.profileRoute
          .replaceFirst(":userId", userFirestore.id);
    }

    if (location.contains("atelier")) {
      return AtelierLocationContent.profileRoute
          .replaceFirst(":userId", userFirestore.id);
    }

    return HomeLocation.profileRoute.replaceFirst(":userId", userFirestore.id);
  }

  void goToEditIllustrationMetada() async {
    await Beamer.of(context).popRoute();
    onShowEditMetadataPanel();
  }

  void goToEditImagePage() async {
    await Beamer.of(context).popRoute();
    onGoToEditImagePage();
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

  void onChangedVisibility(
    BuildContext context, {
    required Illustration illustration,
    required int index,
    required EnumContentVisibility visibility,
  }) {
    final Future<EnumContentVisibility?>? futureResult = tryUpdateVisibility(
      illustration,
      visibility,
      index,
    );

    Navigator.pop(context, futureResult);
  }

  void onCreateNewVersion() async {
    ref
        .read(AppState.uploadTaskListProvider.notifier)
        .pickImageForNewVersion(_illustration);
  }

  /// Callback event fired when files are dropped on this page.
  /// Try to upload them as image and create correspondig illustrations.
  void onDragFileDone(DropDoneDetails dropDoneDetails) async {
    if (!_enableFileDrop) {
      return;
    }

    if (dropDoneDetails.files.isEmpty) {
      return;
    }

    final firstFile = dropDoneDetails.files.first;
    final int length = await firstFile.length();

    if (length > 25000000) {
      context.showErrorBar(
        content: Text(
          "illustration_upload_size_limit".tr(
            args: [firstFile.name, length.toString(), "25"],
          ),
        ),
      );
      return;
    }

    final int dotIndex = firstFile.path.lastIndexOf(".");
    final String extension = firstFile.path.substring(dotIndex + 1);

    if (!Constants.allowedImageExt.contains(extension)) {
      context.showErrorBar(
        content: Text(
          "illustration_upload_invalid_extension".tr(
            args: [firstFile.name, Constants.allowedImageExt.join(", ")],
          ),
        ),
      );
      return;
    }

    final FilePickerCross filePickerCross = FilePickerCross(
      await firstFile.readAsBytes(),
      path: firstFile.path,
      type: FileTypeCross.image,
      fileExtension: extension,
    );

    ref.read(AppState.uploadTaskListProvider.notifier).handleDropForNewVersion(
          filePickerCross,
          _illustration,
        );
  }

  /// Callback event fired when a pointer enters this page with files.
  void onDragFileEntered(DropEventDetails dropEventDetails) {
    if (!_enableFileDrop) {
      return;
    }
    setState(() => _isDraggingFile = true);
  }

  /// Callback event fired when a pointer exits this page with files.
  void onDragFileExited(DropEventDetails dropEventDetails) {
    if (!_enableFileDrop) {
      return;
    }
    setState(() {
      _isDraggingFile = false;
    });
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

  /// Callback fired when route changes.
  void onRouteUpdate() {
    final String? stringLocation = Beamer.of(context)
        .beamingHistory
        .last
        .history
        .last
        .routeInformation
        .location;

    _enableFileDrop =
        stringLocation == AtelierLocationContent.illustrationRoute;
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
                "firestore_id": illustrationId,
                "file_type": "illustration",
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

  void onShare() async {
    showDialog(
      context: context,
      builder: (context) => ShareDialog(
        extension: _illustration.extension,
        itemId: _illustration.id,
        imageProvider: NetworkImage(_illustration.getThumbnail()),
        name: _illustration.name,
        imageUrl: _illustration.getThumbnail(),
        shareContentType: EnumShareContentType.illustration,
        userId: _illustration.userId,
        username: "",
        visibility: _illustration.visibility,
        onShowVisibilityDialog: () => showVisibilityDialog(_illustration, 0),
      ),
    );
  }

  void onShowEditMetadataPanel() async {
    await showCupertinoModalBottomSheet(
      context: context,
      expand: true,
      builder: (BuildContext context) {
        return EditIllustrationPage(
          illustration: _illustration,
          goToEditImagePage: goToEditImagePage,
        );
      },
    );
  }

  void onTapUser(UserFirestore userFirestore) {
    final String route = getUserRoute(userFirestore);
    Beamer.of(context).beamToNamed(
      route,
      data: {"userId": userFirestore.id},
    );
  }

  Future<EnumContentVisibility?>? showVisibilityDialog(
    Illustration illustration,
    int index,
  ) async {
    final double width = 310.0;

    return await showDialog<Future<EnumContentVisibility?>?>(
      context: context,
      builder: (context) => ThemedDialog(
        showDivider: true,
        titleValue: "illustration_visibility_change".plural(0),
        textButtonValidation: "close".tr(),
        onValidate: Beamer.of(context).popRoute,
        onCancel: Beamer.of(context).popRoute,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.only(left: 16.0),
                  width: width,
                  child: Opacity(
                    opacity: 0.6,
                    child: Text(
                      "illustration_visibility_choose".plural(0),
                      style: Utilities.fonts.body(
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ),
                VisibilityButton(
                  maxWidth: width,
                  visibility: illustration.visibility,
                  onChangedVisibility: (EnumContentVisibility visibility) =>
                      onChangedVisibility(
                    context,
                    visibility: visibility,
                    illustration: illustration,
                    index: index,
                  ),
                  padding: const EdgeInsets.only(
                    left: 16.0,
                    top: 12.0,
                    bottom: 32.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool hasImageExtension(String name) {
    return Constants.allowedImageExt.any((String ext) => name.endsWith(ext));
  }

  String createLocalFilePath() {
    if (hasImageExtension(_illustration.name)) {
      return _illustration.name;
    }

    return "${_illustration.name}.${_illustration.extension}";
  }

  void tryDownload() async {
    setState(() => _downloading = true);

    try {
      final Reference storageRef = FirebaseStorage.instance.ref();
      final Reference fileRef = storageRef.child(_illustration.links.storage);

      // if file's size > 10mb, use a web browser.
      if (_illustration.size > 10000000) {
        final HttpsCallableResult response = await Utilities.cloud
            .illustrations("getSignedUrl")
            .call({"illustration_id": _illustration.id});

        if (!response.data["success"]) {
          throw ErrorDescription("download_file_error".tr());
        }

        final String downloadUrl = response.data["url"];

        final Uri url = Uri.parse(downloadUrl);
        await launchUrl(url);
        return;
      }

      // Load the file in memory
      // ----------
      final Uint8List? fileData = await fileRef.getData();
      if (fileData == null) {
        context.showErrorBar(
          content: Text("download_file_error".tr()),
        );

        return;
      }

      final fileCross = FilePickerCross(
        fileData,
        fileExtension: _illustration.extension,
        type: FileTypeCross.image,
      );

      fileCross.exportToStorage(
        fileName: _illustration.name,
      );
    } catch (error) {
      Utilities.logger.i(error);
      context.showErrorBar(content: Text(error.toString()));
    } finally {
      setState(() => _downloading = false);
    }
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

  Future<EnumContentVisibility?> tryUpdateVisibility(
    Illustration illustration,
    EnumContentVisibility visibility,
    int index,
  ) async {
    try {
      final HttpsCallableResult response =
          await Utilities.cloud.fun("illustrations-updateVisibility").call({
        "illustration_id": illustration.id,
        "visibility": visibility.name,
      });

      if (response.data["success"] as bool) {
        return visibility;
      }

      throw Error();
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
      return null;
    }
  }
}
