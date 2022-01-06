import 'package:artbooking/components/avatar/better_avatar.dart';
import 'package:artbooking/components/form_actions_inputs.dart';
import 'package:artbooking/components/main_app_bar/main_app_bar.dart';
import 'package:artbooking/components/sheet_header.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/router/locations/dashboard_location.dart';
import 'package:artbooking/router/navigation_state_helper.dart';
import 'package:artbooking/globals/app_state.dart';
import 'package:artbooking/types/user/user_firestore.dart';
import 'package:artbooking/types/user/user_pp.dart';
import 'package:artbooking/types/user/user_pp_path.dart';
import 'package:artbooking/types/user/user_pp_url.dart';
import 'package:artbooking/types/user/user_urls.dart';
import 'package:artbooking/utils/app_logger.dart';
import 'package:artbooking/utils/snack.dart';
import 'package:beamer/beamer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:extended_image/extended_image.dart';
import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mime_type/mime_type.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:unicons/unicons.dart';
import 'package:url_launcher/url_launcher.dart';

class MyProfilePage extends ConsumerStatefulWidget {
  @override
  _MyProfilePageState createState() => _MyProfilePageState();
}

class _MyProfilePageState extends ConsumerState<MyProfilePage> {
  bool _isUpdating = false;
  String _selectedLink = '';
  var _textInputController = TextEditingController();
  var _tempUserUrls = UserUrls();

  @override
  void dispose() {
    _textInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final UserFirestore userFirestore =
        ref.watch(AppState.userProvider).firestoreUser ?? UserFirestore.empty();

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              MainAppBar(),
              SliverList(
                delegate: SliverChildListDelegate.fixed([
                  body(
                    userFirestore: userFirestore,
                  ),
                ]),
              ),
            ],
          ),
          popupProgressIndicator(),
        ],
      ),
    );
  }

  Widget addLinkButton() {
    return SizedBox(
      width: 54.0,
      height: 54.0,
      child: Card(
        elevation: 1.0,
        color: Theme.of(context).backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6.0),
          side: BorderSide(color: Colors.black26, width: 1.5),
        ),
        child: Tooltip(
          message: "link_add".tr(),
          child: InkWell(
            onTap: showAddLink,
            child: Opacity(
              opacity: 0.6,
              child: Icon(
                UniconsLine.link_add,
                size: 18.0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget addLinkContainer({
    required void Function(void Function()) childSetState,
    required UserUrls urls,
  }) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            children: [
              SheetHeader(
                title: "link".tr(),
                tooltip: "close".tr(),
                subtitle: "link_subtitle".tr(),
              ),
              Container(
                width: 600.0,
                padding: EdgeInsets.only(
                  top: 60.0,
                ),
                child: Column(
                  children: [
                    inputLink(childSetState),
                    clearInputButton(childSetState),
                    pageLinkDescription(),
                    gridLinks(
                      childSetState: childSetState,
                      urls: urls,
                    ),
                    FormActionInputs(
                      padding: const EdgeInsets.only(
                        top: 40.0,
                        bottom: 200.0,
                      ),
                      cancelTextString: "cancel".tr(),
                      saveTextString: "done".tr(),
                      onCancel: Beamer.of(context).popRoute,
                      onValidate: () {
                        setState(() {
                          ref
                              .read(AppState.userProvider)
                              .firestoreUser
                              ?.urls
                              .copyFrom(_tempUserUrls);
                        });

                        updateUser();
                        Beamer.of(context).popRoute();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget availableLinks({required UserFirestore userFirestore}) {
    return Container(
      width: 600.0,
      padding: const EdgeInsets.only(top: 8.0),
      child: Wrap(
        spacing: 4.0,
        runSpacing: 4.0,
        alignment: WrapAlignment.center,
        children: userFirestore.urls.getAvailableLinks().entries.map((entry) {
          return SizedBox(
            width: 50.0,
            height: 50.0,
            child: Tooltip(
              message: entry.key,
              child: InkWell(
                onTap: () => launch(entry.value),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.center,
                    child: Opacity(
                      opacity: 0.6,
                      child: getPicLink(entry.key),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget avatar({required UserFirestore userFirestore}) {
    final String avatarUrl = userFirestore.getPP();

    return Padding(
      padding: const EdgeInsets.only(top: 120.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Opacity(
            opacity: 0.6,
            child: IconButton(
              tooltip: "back".tr(),
              onPressed: Beamer.of(context).popRoute,
              icon: Icon(UniconsLine.arrow_left),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8.0,
            ),
            child: BetterAvatar(
              size: 160.0,
              image: NetworkImage(avatarUrl),
              colorFilter: ColorFilter.mode(
                Colors.grey,
                BlendMode.saturation,
              ),
              onTap: () {
                if (userFirestore.pp.url.edited.isEmpty) {
                  return;
                }

                NavigationStateHelper.imageToEdit =
                    ExtendedNetworkImageProvider(
                  userFirestore.pp.url.original,
                  cache: true,
                  cacheRawData: true,
                );

                context.beamToNamed(
                  DashboardLocationContent.editProfilePictureRoute,
                );
              },
            ),
          ),
          Opacity(
            opacity: 0.6,
            child: IconButton(
              tooltip: "pp_upload".tr(),
              onPressed: uploadPicture,
              icon: Icon(UniconsLine.upload),
            ),
          ),
        ],
      ),
    );
  }

  Widget body({required UserFirestore userFirestore}) {
    return Column(children: [
      avatar(userFirestore: userFirestore),
      username(userFirestore.name),
      job(userFirestore: userFirestore),
      availableLinks(userFirestore: userFirestore),
      Padding(
        padding: const EdgeInsets.only(
          top: 40.0,
        ),
        child: Wrap(
          spacing: 12.0,
          runSpacing: 12.0,
          children: [
            location(userFirestore.location),
            summaryEditButton(userFirestore.summary),
            addLinkButton(),
          ],
        ),
      ),
      summary(userFirestore.summary),
    ]);
  }

  Widget clearInputButton(void Function(void Function() p1) childSetState) {
    if (_textInputController.text.isEmpty) {
      return Container(height: 36.0);
    }

    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.only(
          top: 8.0,
          left: 32.0,
        ),
        child: Opacity(
          opacity: 0.6,
          child: TextButton.icon(
            onPressed: () {
              childSetState(() {
                _textInputController.clear();
                _tempUserUrls.setUrl(_selectedLink, '');
              });
            },
            icon: Icon(UniconsLine.times),
            label: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text("clear".tr()),
            ),
            style: TextButton.styleFrom(
              primary:
                  Theme.of(context).textTheme.bodyText1?.color ?? Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget gridLinks({
    required void Function(void Function()) childSetState,
    required UserUrls urls,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 40.0),
      child: Wrap(
        spacing: 12.0,
        runSpacing: 12.0,
        children: urls.socialMap!.entries.map((entry) {
          return SizedBox(
            width: 80.0,
            height: 80.0,
            child: Card(
              elevation: urls.socialMap![entry.key]!.isEmpty ? 0.0 : 3.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6.0),
                side: BorderSide(
                  width: 2.0,
                  color: _selectedLink == entry.key
                      ? Theme.of(context).primaryColor
                      : Colors.transparent,
                ),
              ),
              child: Tooltip(
                message: entry.key,
                child: InkWell(
                  onTap: () {
                    childSetState(() {
                      _selectedLink = entry.key;
                      _textInputController.text = urls.map![entry.key]!;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.center,
                      child: Opacity(
                        opacity: 0.6,
                        child: getPicLink(entry.key),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget getPicLink(String key) {
    switch (key) {
      case 'artbooking':
        return Image.asset(
          "assets/images/artbooking.png",
          width: 40.0,
          height: 40.0,
        );
      case 'behance':
        return FaIcon(FontAwesomeIcons.behance);
      case 'dribbble':
        return Icon(UniconsLine.dribbble);
      case 'facebook':
        return Icon(UniconsLine.facebook);
      case 'github':
        return Icon(UniconsLine.github);
      case 'gitlab':
        return FaIcon(FontAwesomeIcons.gitlab);
      case 'instagram':
        return Icon(UniconsLine.instagram);
      case 'linkedin':
        return Icon(UniconsLine.linkedin);
      case 'other':
        return Icon(UniconsLine.question);
      case 'tiktok':
        return FaIcon(FontAwesomeIcons.tiktok);
      case 'twitch':
        return FaIcon(FontAwesomeIcons.twitch);
      case 'twitter':
        return Icon(UniconsLine.twitter);
      case 'website':
        return Icon(UniconsLine.globe);
      case 'wikipedia':
        return FaIcon(FontAwesomeIcons.wikipediaW);
      case 'youtube':
        return Icon(UniconsLine.youtube);
      default:
        return Icon(UniconsLine.globe);
    }
  }

  Widget inputLink(void Function(void Function()) childSetState) {
    return TextField(
      autofocus: true,
      controller: _textInputController,
      keyboardType: TextInputType.multiline,
      decoration: InputDecoration(
        labelText: "link_label_text".tr(),
        icon: Icon(UniconsLine.link),
      ),
      onChanged: (_) {
        childSetState(() {
          _tempUserUrls.setUrl(
            _selectedLink,
            _textInputController.text,
          );
        });
      },
      onSubmitted: (_) {
        setState(() {
          ref
              .read(AppState.userProvider)
              .firestoreUser
              ?.urls
              .copyFrom(_tempUserUrls);
        });

        Beamer.of(context).popRoute();
        updateUser();
      },
    );
  }

  Widget job({required UserFirestore userFirestore}) {
    return InkWell(
      onTap: showEditJob,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8.0,
        ),
        child: Opacity(
          opacity: 0.6,
          child: Text(
            userFirestore.job,
            style: TextStyle(
              fontSize: 18.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget location(String locationValue) {
    return Card(
      elevation: 1.0,
      color: Theme.of(context).backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
        side: BorderSide(color: Colors.black26, width: 1.5),
      ),
      child: InkWell(
        onTap: () => showEditLocation(locationValue),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12.0,
            vertical: 14.0,
          ),
          child: Opacity(
            opacity: 0.6,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Icon(UniconsLine.location_point, size: 18.0),
                ),
                Text(
                  locationValue.isEmpty
                      ? "edit_location".tr().toUpperCase()
                      : locationValue.toUpperCase(),
                  style: Utilities.fonts.style(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget pageLinkDescription() {
    return Padding(
      padding: const EdgeInsets.only(top: 80.0),
      child: Opacity(
        opacity: 0.6,
        child: Text(
          _selectedLink.isEmpty
              ? "link_select_list".tr()
              : "link_selected_edit".tr(args: [_selectedLink]),
          style: TextStyle(
            fontSize: 24.0,
          ),
        ),
      ),
    );
  }

  Widget popupProgressIndicator() {
    if (!_isUpdating) {
      return Container();
    }

    return Positioned(
      top: 100.0,
      right: 24.0,
      child: SizedBox(
        width: 240.0,
        child: Card(
          elevation: 4.0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 4.0,
                child: LinearProgressIndicator(),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      UniconsLine.circle,
                      color: Theme.of(context).secondaryHeaderColor,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Opacity(
                          opacity: 0.6,
                          child: Text(
                            "user_updating".tr(),
                            style: Utilities.fonts.style(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget summary(String summaryValue) {
    return Container(
      width: 600.0,
      padding: const EdgeInsets.only(
        top: 40.0,
        bottom: 300.0,
      ),
      child: InkWell(
        onTap: () => showEditSummary(summaryValue),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Opacity(
            opacity: 0.6,
            child: Text(
              summaryValue,
              style: TextStyle(
                fontSize: 18.0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget summaryEditButton(String summaryValue) {
    return Card(
      elevation: 1.0,
      color: Theme.of(context).backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
        side: BorderSide(color: Colors.black26, width: 1.5),
      ),
      child: InkWell(
        onTap: () => showEditSummary(summaryValue),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12.0,
            vertical: 14.0,
          ),
          child: Opacity(
            opacity: 0.6,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Icon(UniconsLine.edit, size: 18.0),
                ),
                Text(
                  "summary_edit".tr().toUpperCase(),
                  style: Utilities.fonts.style(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget username(String name) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: TextButton(
        onPressed: () {
          context.beamToNamed(DashboardLocationContent.updateUsernameRoute);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 8.0,
          ),
          child: Text(
            name,
            style: TextStyle(
              fontSize: 32.0,
            ),
          ),
        ),
      ),
    );
  }

  void showAddLink() {
    final urls =
        ref.read(AppState.userProvider).firestoreUser?.urls ?? UserUrls();
    _textInputController.text =
        _selectedLink.isEmpty ? '' : urls.map?[_selectedLink] ?? '';

    _tempUserUrls = UserUrls.fromJSON(urls.map);

    showCupertinoModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, childSetState) {
        return addLinkContainer(
          childSetState: childSetState,
          urls: urls,
        );
      }),
    );
  }

  void showEditJob() {
    _textInputController.text =
        ref.read(AppState.userProvider).firestoreUser?.job ?? '';

    showCupertinoModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, childSetState) {
        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              children: [
                SheetHeader(
                  title: "job".tr(),
                  tooltip: "close".tr(),
                  subtitle: "job_subtitle".tr(),
                ),
                Container(
                  width: 600.0,
                  padding: EdgeInsets.only(
                    top: 60.0,
                  ),
                  child: Column(
                    children: [
                      TextField(
                        autofocus: true,
                        controller: _textInputController,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                          labelText: "job_label_text".tr(),
                          icon: Icon(UniconsLine.suitcase),
                        ),
                        onChanged: (_) {
                          childSetState(() {});
                        },
                        onSubmitted: (_) {
                          childSetState(() {
                            ref.read(AppState.userProvider).firestoreUser?.job =
                                _textInputController.text;
                          });

                          Beamer.of(context).popRoute();
                          updateUser();
                        },
                      ),
                      if (_textInputController.text.isNotEmpty)
                        Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              top: 8.0,
                              left: 32.0,
                            ),
                            child: Opacity(
                              opacity: 0.6,
                              child: TextButton.icon(
                                onPressed: () {
                                  childSetState(() {
                                    _textInputController.clear();
                                  });
                                },
                                icon: Icon(UniconsLine.times),
                                label: Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Text("clear".tr()),
                                ),
                                style: TextButton.styleFrom(
                                  primary: Theme.of(context)
                                          .textTheme
                                          .bodyText1
                                          ?.color ??
                                      Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 40.0,
                        ),
                        child: Align(
                          alignment: Alignment.topRight,
                          child: FormActionInputs(
                            cancelTextString: "cancel".tr(),
                            onCancel: Beamer.of(context).popRoute,
                            onValidate: () {
                              setState(() {
                                ref
                                    .read(AppState.userProvider)
                                    .firestoreUser
                                    ?.job = _textInputController.text;
                              });

                              updateUser();
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  void showEditLocation(String locationValue) {
    _textInputController.text = locationValue;

    showCupertinoModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, childSetState) {
        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              children: [
                SheetHeader(
                  title: "location".tr(),
                  tooltip: "close".tr(),
                  subtitle: "location_subtitle".tr(),
                ),
                Container(
                  width: 600.0,
                  padding: EdgeInsets.only(
                    top: 60.0,
                  ),
                  child: Column(
                    children: [
                      TextField(
                        autofocus: true,
                        controller: _textInputController,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                          labelText: "location_label_text".tr(),
                          icon: Icon(UniconsLine.location_pin_alt),
                        ),
                        onChanged: (_) {
                          childSetState(() {});
                        },
                        onSubmitted: (_) {
                          childSetState(() {
                            ref
                                .read(AppState.userProvider)
                                .firestoreUser
                                ?.location = _textInputController.text;
                          });

                          Beamer.of(context).popRoute();
                          updateUser();
                        },
                      ),
                      if (_textInputController.text.isNotEmpty)
                        Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              top: 8.0,
                              left: 32.0,
                            ),
                            child: Opacity(
                              opacity: 0.6,
                              child: TextButton.icon(
                                onPressed: () {
                                  childSetState(() {
                                    _textInputController.clear();
                                  });
                                },
                                icon: Icon(UniconsLine.times),
                                label: Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Text("clear".tr()),
                                ),
                                style: TextButton.styleFrom(
                                  primary: Theme.of(context)
                                          .textTheme
                                          .bodyText1
                                          ?.color ??
                                      Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 40.0,
                        ),
                        child: Align(
                          alignment: Alignment.topRight,
                          child: FormActionInputs(
                            cancelTextString: "cancel".tr(),
                            onCancel: Beamer.of(context).popRoute,
                            onValidate: () {
                              setState(() {
                                ref
                                    .read(AppState.userProvider)
                                    .firestoreUser
                                    ?.location = _textInputController.text;
                              });

                              updateUser();
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  void showEditSummary(String summaryValue) {
    _textInputController.text = summaryValue;

    showCupertinoModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, childSetState) {
        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              children: [
                SheetHeader(
                  title: "summary".tr(),
                  tooltip: "close".tr(),
                  subtitle: "summary_subtitle".tr(),
                ),
                Container(
                  width: 600.0,
                  padding: EdgeInsets.only(
                    top: 60.0,
                  ),
                  child: Column(
                    children: [
                      TextField(
                        autofocus: true,
                        maxLines: null,
                        controller: _textInputController,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                          labelText: "summary_label_text".tr(),
                          icon: Icon(UniconsLine.text),
                        ),
                        onChanged: (newValue) {
                          childSetState(() {});
                        },
                        onSubmitted: (_) {
                          setState(() {
                            ref
                                .read(AppState.userProvider)
                                .firestoreUser
                                ?.summary = _textInputController.text;
                          });

                          Beamer.of(context).popRoute();
                          updateUser();
                        },
                      ),
                      if (_textInputController.text.isNotEmpty)
                        Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              top: 8.0,
                              left: 32.0,
                            ),
                            child: Opacity(
                              opacity: 0.6,
                              child: TextButton.icon(
                                onPressed: () {
                                  childSetState(() {
                                    _textInputController.clear();
                                  });
                                },
                                icon: Icon(UniconsLine.times),
                                label: Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Text("clear".tr()),
                                ),
                                style: TextButton.styleFrom(
                                  primary: Theme.of(context)
                                          .textTheme
                                          .bodyText1
                                          ?.color ??
                                      Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 40.0,
                        ),
                        child: Align(
                          alignment: Alignment.topRight,
                          child: FormActionInputs(
                            cancelTextString: "cancel".tr(),
                            onCancel: Beamer.of(context).popRoute,
                            onValidate: () {
                              setState(() {
                                ref
                                    .read(AppState.userProvider)
                                    .firestoreUser
                                    ?.summary = _textInputController.text;
                              });

                              updateUser();
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
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

      setState(() => _isUpdating = false);
    } catch (error) {
      setState(() => _isUpdating = false);
      appLogger.e(error);
    }
  }

  void uploadPicture() async {
    FilePickerCross choosenFile = await FilePickerCross.importFromStorage(
      type: FileTypeCross.image,
      fileExtension: 'jpg,jpeg,png,gif',
    );

    if (choosenFile.length >= 5 * 1024 * 1024) {
      Snack.e(
        context: context,
        message: "image_size_exceeded".tr(),
      );

      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception("user_not_connected".tr());
    }

    setState(() => _isUpdating = true);

    final ext =
        choosenFile.fileName!.substring(choosenFile.fileName!.lastIndexOf('.'));

    final metadata = SettableMetadata(
      contentType: mime(choosenFile.fileName),
      customMetadata: {
        'extension': ext,
        'userId': user.uid,
      },
    );

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
        userFirestore?.pp.update(
          UserPP(
            ext: ext.replaceFirst('.', ''),
            size: choosenFile.length,
            updatedAt: DateTime.now(),
            path: UserPPPath(original: imagePath),
            url: UserPPUrl(original: downloadUrl),
          ),
        );

        _isUpdating = false;
      });

      updateUser();
    } catch (error) {
      appLogger.e(error);
      setState(() => _isUpdating = false);
    }
  }
}
