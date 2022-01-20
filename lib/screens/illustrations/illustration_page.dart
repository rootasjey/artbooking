import 'package:artbooking/actions/illustrations.dart';
import 'package:artbooking/components/icons/animated_app_icon.dart';
import 'package:artbooking/components/author_header.dart';
import 'package:artbooking/components/buttons/dark_elevated_button.dart';
import 'package:artbooking/screens/illustrations/edit/edit_illustration_page.dart';
import 'package:artbooking/components/animations/fade_in_y.dart';
import 'package:artbooking/screens/illustrations/illustration_page_poster.dart';
import 'package:artbooking/components/application_bar/application_bar.dart';
import 'package:artbooking/components/sliver_edge_padding.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/router/navigation_state_helper.dart';
import 'package:artbooking/globals/constants.dart';
import 'package:artbooking/types/enums/enum_content_visibility.dart';
import 'package:beamer/beamer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:artbooking/types/illustration/illustration.dart';
import 'package:artbooking/types/license/license.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flash/src/flash_helper.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:unicons/unicons.dart';

class IllustrationPage extends StatefulWidget {
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

class _IllustrationPageState extends State<IllustrationPage> {
  /// True if data is being loaded.
  bool _isLoading = false;

  String _newName = '';
  String _newDesc = '';
  String _newSummary = '';

  bool _isEditModeOn = false;

  License _newLicense = License.empty();
  EnumContentVisibility _newVisibility = EnumContentVisibility.private;

  var _illustration = Illustration.empty();

  var _nameController = TextEditingController();
  var _descController = TextEditingController();
  var _summaryController = TextEditingController();

  @override
  void initState() {
    super.initState();

    Illustration? illustrationFromNav = NavigationStateHelper.illustration;

    if (illustrationFromNav != null &&
        illustrationFromNav.id == widget.illustrationId) {
      _illustration = illustrationFromNav;
    } else {
      fetchIllustration();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _summaryController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HeroControllerScope(
      controller: HeroController(),
      child: Scaffold(
        floatingActionButton: fab(),
        body: Stack(
          children: [
            NotificationListener(
              child: CustomScrollView(
                slivers: [
                  SliverEdgePadding(),
                  ApplicationBar(),
                  body(),
                  SliverPadding(
                    padding: const EdgeInsets.only(
                      bottom: 120.0,
                    ),
                  ),
                ],
              ),
            ),
            saveChangesPanel(),
          ],
        ),
      ),
    );
  }

  Widget body() {
    if (_isLoading) {
      return loadingView();
    }

    return idleView();
  }

  Widget dates() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        InkWell(
          onTap: onTapDates,
          child: Opacity(
            opacity: 0.6,
            child: Text(
              Jiffy(_illustration.createdAt).fromNow(),
              style: Utilities.fonts.style(
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget fab() {
    if (!widget.fromDashboard!) {
      return Container();
    }

    return FloatingActionButton.extended(
      onPressed: showMetaDataSheet,
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      icon: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Icon(UniconsLine.edit),
      ),
      label: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          "edit".tr(),
          style: Utilities.fonts.style(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget header() {
    return Row(
      children: [
        IconButton(
          color: Theme.of(context).primaryColor,
          onPressed: () {
            Beamer.of(context).popRoute();
          },
          icon: Icon(UniconsLine.arrow_left),
        ),
        Expanded(
          child: Opacity(
            opacity: 0.8,
            child: Text(
              _illustration.name,
              style: Utilities.fonts.style(
                fontSize: 20.0,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget idleView() {
    return SliverPadding(
      padding: const EdgeInsets.all(60.0),
      sliver: SliverList(
        delegate: SliverChildListDelegate.fixed([
          header(),
          illustrationCard(),
          dates(),
          actionsRow(),
          if (_isEditModeOn) metdataEdit() else metadata(),
        ]),
      ),
    );
  }

  Widget illustrationCard() {
    final size = MediaQuery.of(context).size;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: size.width - 200.0,
          maxHeight: size.height,
        ),
        child: IllustrationPagePoster(
          illustration: _illustration,
        ),
      ),
    );
  }

  Widget loadingView() {
    return SliverPadding(
      padding: const EdgeInsets.only(top: 80.0),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              children: [
                AnimatedAppIcon(
                  textTitle: "Loading...",
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget description() {
    if (_illustration.description.isEmpty) {
      return Container();
    }

    return Container(
      width: 400.0,
      child: Opacity(
        opacity: 0.4,
        child: Text(
          _illustration.description,
          style: Utilities.fonts.style(
            fontSize: 18.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget summary() {
    if (_illustration.story.isEmpty) {
      return Container();
    }

    return Container(
      width: 400.0,
      padding: const EdgeInsets.only(top: 12.0),
      child: Opacity(
        opacity: 0.6,
        child: Text(
          _illustration.story,
          style: Utilities.fonts.style(
            fontSize: 24.0,
            fontWeight: FontWeight.w200,
          ),
        ),
      ),
    );
  }

  Widget metadata() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 60.0,
      ),
      child: Column(
        children: [
          AuthorHeader(
            authorId: _illustration.author.id,
            padding: const EdgeInsets.only(bottom: 60.0),
          ),
          description(),
          summary(),
        ],
      ),
    );
  }

  Widget metdataEdit() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 24.0,
      ),
      child: Column(
        children: [
          SizedBox(
            width: 250.0,
            child: TextField(
              autofocus: true,
              controller: _nameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Name",
              ),
              textInputAction: TextInputAction.next,
              onChanged: (newValue) {
                _newName = newValue;
              },
            ),
          ),
          Container(
            width: 250.0,
            padding: const EdgeInsets.only(top: 12.0),
            child: TextField(
              controller: _descController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Description",
              ),
              textInputAction: TextInputAction.next,
              onChanged: (newValue) {
                _newDesc = newValue;
              },
            ),
          ),
          Container(
            width: 500.0,
            padding: const EdgeInsets.only(top: 24.0),
            child: TextField(
              controller: _summaryController,
              decoration: InputDecoration(
                labelText: "Summary",
              ),
              maxLines: null,
              textInputAction: TextInputAction.next,
              onChanged: (newValue) {
                _newSummary = newValue;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget saveChangesPanel() {
    if (!_isEditModeOn) {
      return Container();
    }

    return Positioned(
      left: 0.0,
      bottom: 0.0,
      right: 0.0,
      height: 80.0,
      child: FadeInY(
        beginY: 12.0,
        child: Material(
          elevation: 4.0,
          child: Container(
            color: Color.fromRGBO(0, 0, 0, 0.2),
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Save these information?",
                  style: TextStyle(
                    fontSize: 18.0,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 24.0,
                    right: 12.0,
                  ),
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _isEditModeOn = false;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: 60.0,
                        ),
                        child: Text(
                          "Cancel",
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isEditModeOn = false;
                    });

                    saveNewMetadata();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: 60.0,
                      ),
                      child: Text(
                        "Save",
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget actionsRow() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 32.0,
        left: 12.0,
        right: 12.0,
      ),
      child: Opacity(
        opacity: 0.8,
        child: Wrap(
          spacing: 16.0,
          alignment: WrapAlignment.center,
          children: [
            IconButton(
              tooltip: "like".tr(),
              icon: Icon(UniconsLine.heart),
              onPressed: like,
            ),
            IconButton(
              tooltip: "share".tr(),
              icon: Icon(UniconsLine.share),
              onPressed: share,
            ),
            IconButton(
              tooltip: "edit".tr(),
              icon: Icon(UniconsLine.edit),
              onPressed: showMetaDataSheet,
            ),
          ],
        ),
      ),
    );
  }

  void fetchIllustration({bool silent = false}) async {
    setState(() {
      _isLoading = !silent;
    });

    try {
      final illusSnap = await FirebaseFirestore.instance
          .collection('illustrations')
          .doc(widget.illustrationId)
          .get();

      final illusData = illusSnap.data();

      if (!illusSnap.exists || illusData == null) {
        context.showErrorBar(
          content: Text(
            "The illustration with the id ${widget.illustrationId} doesn't exist.",
          ),
        );

        return;
      }

      illusData['id'] = illusSnap.id;

      setState(() {
        _illustration = Illustration.fromJSON(illusData);
        _isLoading = false;
      });
    } catch (error) {
      Utilities.logger.e(error);
      setState(() {
        _isLoading = false;
      });
    }
  }

  void saveNewMetadata() async {
    setState(() {
      _illustration.name = _newName;
      _illustration.description = _newDesc;
      _illustration.story = _newSummary;
      _illustration.license = _newLicense;
      _illustration.visibility = _newVisibility;
    });

    final result = await IllustrationsActions.updateMetadata(
      name: _newName,
      description: _newDesc,
      summary: _newSummary,
      license: _newLicense,
      visibility: _newVisibility,
      illustration: _illustration,
    );

    if (!result.success) {
      Utilities.snack.e(
        context: context,
        message: "Sorry, there was an error while saving your changes."
            " Try again later or contact us.",
      );

      fetchIllustration();
    }
  }

  void onTapDates() {
    showMyDialog(
      title: "dates",
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              text: "Created: ",
              style: Utilities.fonts.style(
                fontSize: 18.0,
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
              children: [
                TextSpan(
                  text: Jiffy(_illustration.createdAt).fromNow(),
                  style: Utilities.fonts.style(
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          Text.rich(
            TextSpan(
              text: "Updated: ",
              style: Utilities.fonts.style(
                fontSize: 18.0,
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
              children: [
                TextSpan(
                  text: Jiffy(_illustration.updatedAt).fromNow(),
                  style: Utilities.fonts.style(
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> showMyDialog({
    required String title,
    required Widget body,
  }) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Constants.colors.clairPink,
          title: Opacity(
            opacity: 0.6,
            child: Text(
              title.toUpperCase(),
            ),
          ),
          titleTextStyle: Utilities.fonts.style(
            fontSize: 14.0,
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
          titlePadding: const EdgeInsets.only(
            top: 24.0,
            left: 24.0,
            right: 24.0,
          ),
          contentPadding: const EdgeInsets.only(top: 12.0),
          actionsPadding: const EdgeInsets.only(
            top: 12.0,
            bottom: 24.0,
          ),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 700.0,
            ),
            child: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Divider(
                    thickness: 2.0,
                    color:
                        Theme.of(context).secondaryHeaderColor.withOpacity(0.4),
                    height: 0.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Opacity(
                      opacity: 0.8,
                      child: body,
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            Center(
              child: DarkElevatedButton.large(
                onPressed: context.beamBack,
                child: Text("close".tr().toUpperCase()),
              ),
            ),
          ],
        );
      },
    );
  }

  void showMetaDataSheet() async {
    await showCupertinoModalBottomSheet(
      context: context,
      builder: (context) => EditIllustrationPage(
        illustration: _illustration,
      ),
    );

    fetchIllustration(silent: true);
  }

  void like() async {}

  void share() async {}
}
