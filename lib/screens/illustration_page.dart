import 'package:artbooking/components/desktop_app_bar.dart';
import 'package:artbooking/types/illustration/illustration.dart';
import 'package:artbooking/utils/app_logger.dart';
import 'package:artbooking/utils/snack.dart';
import 'package:auto_route/annotations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();

    if (widget.illustration != null) {
      illustration = widget.illustration;
    } else {
      fetchIllustration();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NotificationListener(
        child: CustomScrollView(
          slivers: [
            DesktopAppBar(),
            body(),
            SliverPadding(
              padding: const EdgeInsets.only(bottom: 100.0),
            ),
          ],
        ),
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
          captions(),
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

  Widget captions() {
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
              style: TextStyle(
                fontSize: 40.0,
                fontWeight: FontWeight.w800,
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
                )),
        ],
      ),
    );
  }

  Widget loadingView() {
    return SliverList(
      delegate: SliverChildListDelegate([
        CircularProgressIndicator(),
        Text("Loading..."),
      ]),
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
}
