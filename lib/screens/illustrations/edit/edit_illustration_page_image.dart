import 'dart:typed_data';

import 'package:artbooking/components/form_actions_inputs.dart';
import 'package:artbooking/components/loading_view.dart';
import 'package:artbooking/components/application_bar/application_bar.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/router/navigation_state_helper.dart';
import 'package:artbooking/globals/app_state.dart';
import 'package:artbooking/types/user/user_pp_path.dart';
import 'package:artbooking/types/user/user_pp_url.dart';
import 'package:beamer/beamer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:extended_image/extended_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mime_type/mime_type.dart';
import 'package:unicons/unicons.dart';

/// A widget to edit an image (crop, resize, flip, rotate).
class EditIllustrationPageImage extends ConsumerStatefulWidget {
  const EditIllustrationPageImage({
    Key? key,
  }) : super(key: key);

  @override
  _EditImagePageState createState() => _EditImagePageState();
}

class _EditImagePageState extends ConsumerState<EditIllustrationPageImage> {
  bool _isCropping = false;
  bool _isUpdating = false;

  /// Image object. Should be defined is navigating from another page.
  /// It's null when reloading the page for example.
  ImageProvider<Object>? imageToEdit;

  final GlobalKey<ExtendedImageEditorState> _editorKey =
      GlobalKey<ExtendedImageEditorState>();

  @override
  void initState() {
    super.initState();

    imageToEdit = NavigationStateHelper.imageToEdit;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          ApplicationBar(),
          header(),
          body(),
        ],
      ),
    );
  }

  Widget body() {
    Widget child;

    if (_isCropping) {
      child = LoadingView(
        title: Text("image_cropping".tr()),
      );
    } else if (_isUpdating) {
      child = LoadingView(
        title: Text("image_update_cloud".tr()),
      );
    } else {
      child = idleView();
    }

    return SliverList(
      delegate: SliverChildListDelegate.fixed([
        child,
      ]),
    );
  }

  Widget idleView() {
    return Column(children: [
      ExtendedImage(
        width: 600.0,
        height: 400.0,
        image: imageToEdit!,
        fit: BoxFit.contain,
        mode: ExtendedImageMode.editor,
        extendedImageEditorKey: _editorKey,
        initEditorConfigHandler: (state) {
          return EditorConfig(
            maxScale: 8.0,
            cropRectPadding: const EdgeInsets.all(20.0),
            hitTestSize: 20.0,
          );
        },
      ),
      imageActions(),
      FormActionInputs(
        padding: const EdgeInsets.only(
          bottom: 300.0,
        ),
        cancelTextString: "cancel".tr(),
        onCancel: Beamer.of(context).popRoute,
        onValidate: () {
          _cropImage(useNativeLib: false);
        },
      ),
    ]);
  }

  Widget imageActions() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Wrap(
        spacing: 20.0,
        runSpacing: 20.0,
        children: [
          IconButton(
            icon: Icon(UniconsLine.crop_alt_rotate_left),
            onPressed: () {
              _editorKey.currentState!.rotate(right: false);
            },
          ),
          IconButton(
            icon: Icon(UniconsLine.crop_alt_rotate_right),
            onPressed: () {
              _editorKey.currentState!.rotate(right: true);
            },
          ),
          IconButton(
            icon: Icon(UniconsLine.flip_v),
            onPressed: () {
              _editorKey.currentState!.flip();
            },
          ),
          IconButton(
            icon: Icon(UniconsLine.history),
            onPressed: () {
              _editorKey.currentState!.reset();
            },
          ),
        ],
      ),
    );
  }

  Widget header() {
    return SliverList(
      delegate: SliverChildListDelegate.fixed([
        Padding(
          padding: const EdgeInsets.only(top: 60.0),
          child: Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 24.0),
                    child: Opacity(
                      opacity: 0.8,
                      child: IconButton(
                        onPressed: Beamer.of(context).popRoute,
                        icon: Icon(UniconsLine.arrow_left),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Opacity(
                        opacity: 0.4,
                        child: Text(
                          "edit".tr().toUpperCase(),
                          style: Utilities.fonts.style(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Opacity(
                        opacity: 0.8,
                        child: Text(
                          "pp".tr(),
                          style: Utilities.fonts.style(
                            fontSize: 50.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 400.0,
                        child: Opacity(
                          opacity: 0.5,
                          child: Text(
                            "pp_description".tr(),
                            style: Utilities.fonts.style(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ]),
    );
  }

  Future<void> _cropImage({required bool useNativeLib}) async {
    setState(() => _isCropping = true);

    try {
      Uint8List? fileData;

      if (useNativeLib) {
        fileData = await Utilities.cropEditor.cropImageDataWithNativeLibrary(
          state: _editorKey.currentState!,
        );
      } else {
        // Delay due to cropImageDataWithDartLibrary is time consuming on main thread
        // it will block showBusyingDialog
        // if you don't want to block ui, use compute/isolate,but it costs more time.
        // await Future.delayed(Duration(milliseconds: 200));

        // If you don't want to block ui, use compute/isolate,but it costs more time.
        fileData = await Utilities.cropEditor.cropImageDataWithDartLibrary(
          state: _editorKey.currentState!,
        );
      }

      uploadPicture(imageData: fileData!);
    } catch (error) {
      Utilities.logger.e(error);
    }
  }

  void uploadPicture({required Uint8List imageData}) async {
    final User? userAuth = FirebaseAuth.instance.currentUser;

    if (userAuth == null) {
      throw Exception("You're not connected.");
    }

    setState(() => _isUpdating = true);

    final String ext =
        ref.read(AppState.userProvider).firestoreUser?.pp.ext ?? '';

    try {
      final String imagePath = "images/users/${userAuth.uid}/pp/edited.$ext";

      final UploadTask task = FirebaseStorage.instance.ref(imagePath).putData(
          imageData,
          SettableMetadata(
            contentType: mimeFromExtension(ext),
            customMetadata: {
              'extension': ext,
              'userId': userAuth.uid,
            },
          ));

      final TaskSnapshot snapshot = await task;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      setState(() {
        ref
            .read(AppState.userProvider)
            .firestoreUser
            ?.urls
            .setUrl('image', downloadUrl);

        ref.read(AppState.userProvider).firestoreUser?.pp.merge(
              path: UserPPPath(edited: imagePath),
              url: UserPPUrl(edited: downloadUrl),
            );

        _isUpdating = false;
      });

      updateUser();
    } catch (error) {
      Utilities.logger.e(error);
      setState(() => _isUpdating = false);
    }
  }

  void updateUser() async {
    setState(() => _isUpdating = true);

    try {
      final String uid = FirebaseAuth.instance.currentUser?.uid ?? '';

      await Utilities.cloud.fun('users-updateUser').call({
        'userId': uid,
        'updatePayload':
            ref.read(AppState.userProvider).firestoreUser?.toJSON(),
      });

      Beamer.of(context).popRoute();
    } catch (error) {
      Utilities.logger.e(error);
    } finally {
      setState(() => _isUpdating = false);
    }
  }
}