import 'package:artbooking/components/loading_view.dart';
import 'package:artbooking/components/main_app_bar/main_app_bar.dart';
import 'package:artbooking/components/sliver_edge_padding.dart';
import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/screens/licenses/license_urls_section.dart';
import 'package:artbooking/screens/licenses/license_usage_section.dart';
import 'package:artbooking/types/illustration/license.dart';
import 'package:beamer/beamer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:unicons/unicons.dart';

class LicensePage extends StatefulWidget {
  const LicensePage({Key? key, required this.licenseId}) : super(key: key);

  final String licenseId;

  @override
  State<LicensePage> createState() => _LicensePageState();
}

class _LicensePageState extends State<LicensePage> {
  bool _isLoading = false;
  var _license = IllustrationLicense.empty();

  @override
  void initState() {
    super.initState();
    fetchLicense();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverEdgePadding(),
          MainAppBar(),
          header(),
          body(),
          SliverEdgePadding(
            padding: const EdgeInsets.only(bottom: 200),
          ),
        ],
      ),
    );
  }

  Widget body() {
    return SliverPadding(
      padding: const EdgeInsets.all(60.0),
      sliver: SliverList(
        delegate: SliverChildListDelegate.fixed(
          [
            if (_isLoading) ...loadingView() else ...idleView(),
          ],
        ),
      ),
    );
  }

  Widget header() {
    return SliverPadding(
      padding: const EdgeInsets.only(top: 68.0, left: 50.0),
      sliver: SliverList(
        delegate: SliverChildListDelegate.fixed([
          Row(
            children: [
              IconButton(
                tooltip: "back".tr(),
                onPressed: Beamer.of(context).popRoute,
                icon: Icon(UniconsLine.arrow_left),
              ),
            ],
          ),
        ]),
      ),
    );
  }

  List<Widget> idleView() {
    return [
      Opacity(
        opacity: 0.4,
        child: Text(
          "version: ${_license.version}".toUpperCase(),
          style: Utilities.fonts.style(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      Text(
        _license.name,
        style: Utilities.fonts.style(
          fontSize: 32.0,
          fontWeight: FontWeight.w700,
        ),
      ),
      Opacity(
        opacity: 0.6,
        child: Text(
          _license.description,
          style: Utilities.fonts.style(
            fontSize: 18.0,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      datesWidget(),
      Padding(
        padding: const EdgeInsets.only(top: 42.0),
        child: LicenseUsageSection(
          usage: _license.usage,
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 42.0),
        child: LicenseUrlSection(
          urls: _license.urls,
        ),
      ),
    ];
  }

  Widget datesWidget() {
    return Padding(
      padding: const EdgeInsets.only(top: 32.0),
      child: Opacity(
        opacity: 0.4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Icon(UniconsLine.play),
                  ),
                  Text(
                    "created ${Jiffy(_license.createdAt).fromNow()}",
                    style: Utilities.fonts.style(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Icon(UniconsLine.arrow_circle_up),
                ),
                Text(
                  "updated ${Jiffy(_license.updatedAt).fromNow()}",
                  style: Utilities.fonts.style(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> loadingView() {
    return [
      LoadingView(
        title: Text("Loding license"),
      )
    ];
  }

  void fetchLicense() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('licenses')
          .doc(widget.licenseId)
          .get();

      if (!snapshot.exists) {
        return;
      }

      final data = snapshot.data();
      if (data == null) {
        return;
      }

      data['id'] = snapshot.id;

      setState(() {
        _license = IllustrationLicense.fromJSON(data);
      });
    } catch (error) {
      Utilities.logger.e(error);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}