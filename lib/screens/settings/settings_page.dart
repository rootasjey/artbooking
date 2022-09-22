import 'dart:typed_data';

import 'package:artbooking/components/application_bar/application_bar.dart';
import 'package:artbooking/components/popup_progress_indicator.dart';
import 'package:artbooking/router/locations/atelier_location.dart';
import 'package:artbooking/components/dialogs/input_dialog.dart';
import 'package:artbooking/screens/edit_image/edit_image_page.dart';
import 'package:artbooking/screens/settings/settings_page_empty.dart';
import 'package:artbooking/globals/app_state.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/screens/settings/settings_page_body.dart';
import 'package:artbooking/screens/settings/settings_page_header.dart';
import 'package:artbooking/types/user/user.dart';
import 'package:artbooking/types/user/user_firestore.dart';
import 'package:artbooking/types/user/user_social_links.dart';
import 'package:beamer/beamer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:extended_image/extended_image.dart';
import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flash/src/flash_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mime_type/mime_type.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({
    Key? key,
    this.showAppBar = true,
  }) : super(key: key);

  final bool showAppBar;

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _isUpdating = false;
  final String heroTag = "profilePicture";
  final _pageScrollController = ScrollController();

  @override
  void dispose() {
    _pageScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final User userState = ref.watch(AppState.userProvider);
    final UserFirestore? userFirestore = userState.firestoreUser;

    if (userFirestore == null) {
      return SettingsPageEmpty(
        scrollController: _pageScrollController,
      );
    }

    final double windowWidth = MediaQuery.of(context).size.width;
    final bool isMobileSize = windowWidth < Utilities.size.mobileWidthTreshold;

    return Scaffold(
      body: NotificationListener<ScrollNotification>(
        child: Stack(
          children: [
            CustomScrollView(
              controller: _pageScrollController,
              slivers: <Widget>[
                ApplicationBar(
                  minimal: true,
                  pinned: false,
                  bottom: PreferredSize(
                    child: SettingsPageHeader(
                      isMobileSize: isMobileSize,
                    ),
                    preferredSize: isMobileSize
                        ? Size.fromHeight(120.0)
                        : Size.fromHeight(160.0),
                  ),
                ),
                SettingsPageBody(
                  isMobileSize: isMobileSize,
                  profilePictureHeroTag: heroTag,
                  userFirestore: userFirestore,
                  onEditLocation: onEditLocation,
                  onEditPicture: onGoToEditProfilePicture,
                  onEditBio: onEditBio,
                  onGoToDeleteAccount: onGoToDeleteAccount,
                  onGoToUpdateEmail: onGoToUpdateEmail,
                  onGoToUpdatePasssword: onGoToUpdatePasssword,
                  onGoToUpdateUsername: onGoToUpdateUsername,
                  onUploadPicture: onUploadProfilePicture,
                  onLinkChanged: onUrlChanged,
                  windowWidth: windowWidth,
                ),
              ],
            ),
            Positioned(
              top: 100.0,
              right: 24.0,
              child: PopupProgressIndicator(
                show: _isUpdating,
                message: "user_updating".tr(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onEditLocation() {
    final _locationController = TextEditingController();

    final UserFirestore? userFirestore =
        ref.read(AppState.userProvider).firestoreUser;

    if (userFirestore != null) {
      _locationController.text = userFirestore.location;
    }

    showDialog(
      context: context,
      builder: (context) => InputDialog.singleInput(
        nameController: _locationController,
        label: "location".tr(),
        submitButtonValue: "location_update".tr(),
        subtitleValue: "location_update_description".tr(),
        titleValue: "location_use_new".tr().toUpperCase(),
        onCancel: Beamer.of(context).popRoute,
        onSubmitted: (value) {
          tryUpdateLocation(_locationController.text);
          Beamer.of(context).popRoute();
        },
      ),
    );
  }

  void onGoToEditProfilePicture() {
    final UserFirestore? firestoreUser =
        ref.read(AppState.userProvider).firestoreUser;

    if (firestoreUser == null) {
      throw Exception("user_not_connected".tr());
    }

    showCupertinoModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return EditImagePage(
          heroTag: heroTag,
          onSave: onSaveEditedProfilePicture,
          dimensions: firestoreUser.profilePicture.dimensions,
          imageToEdit: ExtendedNetworkImageProvider(
            firestoreUser.profilePicture.links.original,
            cache: true,
            cacheRawData: true,
            cacheMaxAge: const Duration(seconds: 3),
          ),
        );
      },
    );
  }

  void onSaveEditedProfilePicture(Uint8List? editedImageData) async {
    if (editedImageData == null) {
      return;
    }

    setState(() => _isUpdating = true);

    final firestoreUser = ref.read(AppState.userProvider).firestoreUser;
    if (firestoreUser == null) {
      throw Exception("user_not_connected".tr());
    }

    final String extension =
        firestoreUser.profilePicture.extension.replaceFirst(".", "");
    final String uid = firestoreUser.id;

    try {
      final String imagePath =
          "users/${uid}/profile/picture/original.$extension";

      final metadata = SettableMetadata(
        contentType: mimeFromExtension(extension),
        customMetadata: {
          "extension": extension,
          "userId": uid,
          "target": "profile_picture",
          "file_type": "profile_picture",
        },
      );

      final UploadTask task = FirebaseStorage.instance.ref(imagePath).putData(
            editedImageData,
            metadata,
          );

      await task;
    } catch (error) {
      Utilities.logger.e(error);
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  void onEditBio() {
    final _bioController = TextEditingController();

    final userFirestore = ref.read(AppState.userProvider).firestoreUser;

    if (userFirestore != null) {
      _bioController.text = userFirestore.bio;
    }

    showDialog(
      context: context,
      builder: (context) => InputDialog.singleInput(
        nameController: _bioController,
        maxLines: null,
        label: "bio".tr(),
        submitButtonValue: "bio_update".tr(),
        subtitleValue: "bio_update_description".tr(),
        titleValue: "bio_use_new".tr().toUpperCase(),
        onCancel: Beamer.of(context).popRoute,
        onSubmitted: (value) {
          tryUpdateBio(_bioController.text);
          Beamer.of(context).popRoute();
        },
      ),
    );
  }

  void onGoToDeleteAccount() {
    Beamer.of(context).beamToNamed(
      AtelierLocationContent.deleteAccountRoute,
    );
  }

  void onGoToUpdatePasssword() {
    Beamer.of(context).beamToNamed(
      AtelierLocationContent.updatePasswordRoute,
    );
  }

  void onGoToUpdateUsername() {
    Beamer.of(context).beamToNamed(
      AtelierLocationContent.updateUsernameRoute,
    );
  }

  void onGoToUpdateEmail() async {
    Beamer.of(context).beamToNamed(
      AtelierLocationContent.updateEmailRoute,
    );
  }

  void onTapProfilePicture() {}

  void onUploadProfilePicture() async {
    try {
      final FilePickerCross choosenFile =
          await FilePickerCross.importFromStorage(
        type: FileTypeCross.image,
        fileExtension: 'jpg,jpeg,png,gif',
      ).catchError((error) {
        Utilities.logger.i("Probably cancelled file picker or denied right.");
        return Future<FilePickerCross>.error(error);
      });

      if (choosenFile.length >= 5 * 1024 * 1024) {
        context.showErrorBar(
          content: Text("image_size_exceeded".tr()),
        );

        return;
      }

      setState(() => _isUpdating = true);

      final authUser = ref.read(AppState.userProvider).authUser;
      if (authUser == null) {
        throw Exception("user_not_connected".tr());
      }

      final fileName = choosenFile.fileName;
      if (fileName == null) {
        return;
      }

      final extension =
          fileName.substring(fileName.lastIndexOf('.')).replaceFirst('.', '');

      final metadata = SettableMetadata(
        contentType: mime(fileName),
        customMetadata: {
          "extension": extension,
          "userId": authUser.uid,
          "target": "profile_picture",
          "file_type": "profile_picture",
        },
      );

      final imagePath =
          "users/${authUser.uid}/profile/picture/original.$extension";

      final task = FirebaseStorage.instance
          .ref(imagePath)
          .putData(choosenFile.toUint8List(), metadata);

      await task;
    } catch (error) {
      Utilities.logger.e(error);
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  void onUrlChanged(UserSocialLinks userUrls) async {
    setState(() {
      _isUpdating = true;
    });

    try {
      await Utilities.cloud.fun("users-updateSocialLinks").call({
        "social_links": userUrls.toMap(),
      });
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  void tryUpdateLocation(String location) async {
    setState(() {
      _isUpdating = true;
    });

    try {
      final userFirestore = ref.read(AppState.userProvider).firestoreUser;
      final String bio = userFirestore?.bio ?? '';

      await Utilities.cloud.fun("users-updatePublicStrings").call({
        "location": location,
        "bio": bio,
      });
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  void tryUpdateBio(String bio) async {
    setState(() {
      _isUpdating = true;
    });

    try {
      final userFirestore = ref.read(AppState.userProvider).firestoreUser;
      final String location = userFirestore?.location ?? '';

      await Utilities.cloud.fun("users-updatePublicStrings").call({
        "location": location,
        "bio": bio,
      });
    } catch (error) {
      Utilities.logger.e(error);
      context.showErrorBar(content: Text(error.toString()));
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }
}
