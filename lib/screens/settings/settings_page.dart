import 'package:artbooking/components/application_bar/application_bar.dart';
import 'package:artbooking/components/popup_progress_indicator.dart';
import 'package:artbooking/router/locations/dashboard_location.dart';
import 'package:artbooking/router/navigation_state_helper.dart';
import 'package:artbooking/screens/settings/settings_page_empty.dart';
import 'package:artbooking/globals/app_state.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/screens/settings/settings_page_body.dart';
import 'package:artbooking/types/user/user_firestore.dart';
import 'package:artbooking/types/user/profile_picture.dart';
import 'package:artbooking/types/string_map.dart';
import 'package:beamer/beamer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:extended_image/extended_image.dart';
import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flash/src/flash_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mime_type/mime_type.dart';
import 'package:unicons/unicons.dart';

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
  final _pageScrollController = ScrollController();

  @override
  void dispose() {
    _pageScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(AppState.userProvider);
    final userFirestore = userState.firestoreUser;

    if (userFirestore == null) {
      return SettingsPageEmpty(
        scrollController: _pageScrollController,
      );
    }

    return Scaffold(
      body: NotificationListener<ScrollNotification>(
        child: Stack(
          children: [
            CustomScrollView(
              controller: _pageScrollController,
              slivers: <Widget>[
                ApplicationBar(),
                SettingsPageBody(
                  userFirestore: userFirestore,
                  onEditLocation: onEditLocation,
                  onEditPicture: onEditPicture,
                  onEditSummary: onEditSummary,
                  onGoToDeleteAccount: onGoToDeleteAccount,
                  onGoToUpdateEmail: onGoToUpdateEmail,
                  onGoToUpdatePasssword: onGoToUpdatePasssword,
                  onGoToUpdateUsername: onGoToUpdateUsername,
                  onUploadPicture: onUploadProfilePicture,
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

  Widget deleteAccountButton() {
    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(10.0),
          width: 90.0,
          height: 90.0,
          child: Card(
            elevation: 4.0,
            child: InkWell(
              onTap: () => context.beamToNamed(
                DashboardLocationContent.deleteAccountRoute,
              ),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Opacity(
                  opacity: 0.6,
                  child: Icon(UniconsLine.trash),
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          width: 80.0,
          child: Opacity(
            opacity: 0.8,
            child: Text(
              "account_delete".tr(),
              textAlign: TextAlign.center,
              style: Utilities.fonts.style(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        )
      ],
    );
  }

  void onEditLocation() {}

  void onEditPicture() {}

  void onEditSummary() {}

  void onGoToDeleteAccount() {
    Beamer.of(context).beamToNamed(
      DashboardLocationContent.deleteAccountRoute,
    );
  }

  void onGoToUpdatePasssword() {
    Beamer.of(context).beamToNamed(
      DashboardLocationContent.updatePasswordRoute,
    );
  }

  void onGoToUpdateUsername() {
    Beamer.of(context).beamToNamed(
      DashboardLocationContent.updateUsernameRoute,
    );
  }

  void onGoToUpdateEmail() async {
    Beamer.of(context).beamToNamed(
      DashboardLocationContent.updateEmailRoute,
    );
  }

  void onTapProfilePicture() {
    final UserFirestore? userFirestore =
        ref.read(AppState.userProvider).firestoreUser;

    if (userFirestore == null ||
        userFirestore.profilePicture.url.edited.isEmpty) {
      return;
    }

    NavigationStateHelper.imageToEdit = ExtendedNetworkImageProvider(
      userFirestore.profilePicture.url.original,
      cache: true,
      cacheRawData: true,
    );

    Beamer.of(context).beamToNamed(
      DashboardLocationContent.editProfilePictureRoute,
    );
  }

  void onUploadProfilePicture() async {
    FilePickerCross choosenFile = await FilePickerCross.importFromStorage(
      type: FileTypeCross.image,
      fileExtension: 'jpg,jpeg,png,gif',
    );

    if (choosenFile.length >= 5 * 1024 * 1024) {
      context.showErrorBar(
        content: Text("image_size_exceeded".tr()),
      );

      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("user_not_connected".tr());
    }

    final fileName = choosenFile.fileName;
    if (fileName == null) {
      return;
    }

    final ext = fileName.substring(fileName.lastIndexOf('.'));

    final metadata = SettableMetadata(
      contentType: mime(fileName),
      customMetadata: {
        'extension': ext,
        'userId': user.uid,
      },
    );

    setState(() => _isUpdating = true);

    try {
      final response =
          await Utilities.cloud.fun('users-clearProfilePicture').call();
      final bool success = response.data['success'];

      if (!success) {
        throw "Error while calling cloud function.";
      }

      final imagePath = "images/users/${user.uid}/pp/original$ext";

      final task = FirebaseStorage.instance
          .ref(imagePath)
          .putData(choosenFile.toUint8List(), metadata);

      final snapshot = await task;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      final UserFirestore? userFirestore =
          ref.read(AppState.userProvider).firestoreUser;

      setState(() {
        userFirestore?.urls.setUrl('image', downloadUrl);
        userFirestore?.profilePicture.update(
          ProfilePicture(
            ext: ext.replaceFirst('.', ''),
            size: choosenFile.length,
            updatedAt: DateTime.now(),
            path: StringMap(original: imagePath),
            url: StringMap(original: downloadUrl),
          ),
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
        'updatePayload': ref.read(AppState.userProvider).firestoreUser?.toMap(),
      });

      setState(() => _isUpdating = false);
    } catch (error) {
      setState(() => _isUpdating = false);
      Utilities.logger.e(error);
    }
  }
}
