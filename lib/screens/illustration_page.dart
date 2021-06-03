import 'package:artbooking/actions/illustrations.dart';
import 'package:artbooking/components/animated_app_icon.dart';
import 'package:artbooking/components/fade_in_y.dart';
import 'package:artbooking/components/main_app_bar.dart';
import 'package:artbooking/types/enums.dart';
import 'package:artbooking/types/illustration/illustration.dart';
import 'package:artbooking/types/illustration/license.dart';
import 'package:artbooking/utils/app_logger.dart';
import 'package:artbooking/utils/fonts.dart';
import 'package:artbooking/utils/snack.dart';
import 'package:auto_route/annotations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class IllustrationPage extends StatefulWidget {
  final String illustrationId;
  final Illustration illustration;

  const IllustrationPage({
    Key key,
    @PathParam() this.illustrationId,
    this.illustration,
  }) : super(key: key);

  @override
  _IllustrationPageState createState() => _IllustrationPageState();
}

class _IllustrationPageState extends State<IllustrationPage> {
  /// True if data is being loaded.
  bool isLoading = false;

  Illustration illustration;

  String newName = '';
  String newDesc = '';
  String newSummary = '';

  bool isEditModeOn = false;

  TextEditingController nameController;
  TextEditingController descController;
  TextEditingController summaryController;

  IllustrationLicense newLicense = IllustrationLicense();
  ContentVisibility newVisibility = ContentVisibility.private;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController();
    descController = TextEditingController();
    summaryController = TextEditingController();

    if (widget.illustration != null) {
      illustration = widget.illustration;
    } else {
      fetchIllustration();
    }
  }

  @override
  void dispose() {
    nameController?.dispose();
    descController?.dispose();
    summaryController?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          NotificationListener(
            child: CustomScrollView(
              slivers: [
                MainAppBar(),
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
    );
  }

  Widget body() {
    if (isLoading) {
      return loadingView();
    }

    return idleView();
  }

  Widget idleView() {
    return SliverPadding(
      padding: const EdgeInsets.all(60.0),
      sliver: SliverList(
        delegate: SliverChildListDelegate.fixed([
          illustrationCard(),
          userActions(),
          if (isEditModeOn) metdataEdit() else metadata(),
        ]),
      ),
    );
  }

  Widget illustrationCard() {
    return Center(
      child: SizedBox(
        width: 600.0,
        height: 600.0,
        child: Card(
          elevation: 4.0,
          child: Ink.image(
            image: NetworkImage(
              illustration.getHDThumbnail(),
            ),
            fit: BoxFit.cover,
            child: InkWell(
              onTap: () {},
            ),
          ),
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

  Widget metadata() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 24.0,
      ),
      child: Column(
        children: [
          Opacity(
            opacity: 0.8,
            child: Text(
              illustration.name ?? '',
              style: FontsUtils.mainStyle(
                fontSize: 56.0,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (illustration.description != null &&
              illustration.description.isNotEmpty)
            Opacity(
              opacity: 0.4,
              child: Text(
                illustration.description ?? '',
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
            ),
          if (illustration.summary != null && illustration.summary.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: Opacity(
                opacity: 0.6,
                child: Text(
                  illustration.summary ?? '',
                  style: FontsUtils.mainStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.w200,
                  ),
                ),
              ),
            ),
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
              controller: nameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Name",
              ),
              textInputAction: TextInputAction.next,
              onChanged: (newValue) {
                newName = newValue;
              },
            ),
          ),
          Container(
            width: 250.0,
            padding: const EdgeInsets.only(top: 12.0),
            child: TextField(
              controller: descController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Description",
              ),
              textInputAction: TextInputAction.next,
              onChanged: (newValue) {
                newDesc = newValue;
              },
            ),
          ),
          Container(
            width: 500.0,
            padding: const EdgeInsets.only(top: 24.0),
            child: TextField(
              controller: summaryController,
              decoration: InputDecoration(
                labelText: "Summary",
              ),
              maxLines: null,
              textInputAction: TextInputAction.next,
              onChanged: (newValue) {
                newSummary = newValue;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget saveChangesPanel() {
    if (!isEditModeOn) {
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
                        isEditModeOn = false;
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
                      isEditModeOn = false;
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

  Widget userActions() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Wrap(
        alignment: WrapAlignment.center,
        children: [
          IconButton(
            icon: Icon(UniconsLine.heart),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(UniconsLine.share),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(UniconsLine.edit),
            onPressed: () {
              setState(() {
                nameController.text = illustration.name;
                descController.text = illustration.description;
                summaryController.text = illustration.summary;

                newName = illustration.name;
                newDesc = illustration.description;
                newSummary = illustration.summary;
                newLicense = illustration.license;
                newVisibility = illustration.visibility;

                isEditModeOn = !isEditModeOn;
              });
            },
          ),
        ],
      ),
    );
  }

  void fetchIllustration() async {
    setState(() {
      isLoading = true;
    });

    try {
      final illusSnap = await FirebaseFirestore.instance
          .collection('illustrations')
          .doc(widget.illustrationId)
          .get();

      final illusData = illusSnap.data();

      if (!illusSnap.exists || illusData == null) {
        Snack.e(
          context: context,
          message: "The illustration with the id "
              "${widget.illustrationId} doesn't exist.",
        );

        return;
      }

      illusData['id'] = illusSnap.id;

      setState(() {
        illustration = Illustration.fromJSON(illusData);
        isLoading = false;
      });
    } catch (error) {
      appLogger.e(error);
      setState(() {
        isLoading = false;
      });
    }
  }

  void saveNewMetadata() async {
    setState(() {
      illustration.name = newName;
      illustration.description = newDesc;
      illustration.summary = newSummary;
      illustration.license = newLicense;
      illustration.visibility = newVisibility;
    });

    final result = await IllustrationsActions.updateMetadata(
      name: newName,
      description: newDesc,
      summary: newSummary,
      license: newLicense,
      visibility: newVisibility,
      illustration: illustration,
    );

    if (!result.success) {
      Snack.e(
        context: context,
        message: "Sorry, there was an error while saving your changes."
            " Try again later or contact us.",
      );

      fetchIllustration();
    }
  }
}
