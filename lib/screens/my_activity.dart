import 'package:artbooking/components/default_app_bar.dart';
import 'package:artbooking/components/full_page_loading.dart';
import 'package:artbooking/screens/dashboard.dart';
import 'package:artbooking/screens/signin.dart';
import 'package:artbooking/state/colors.dart';
import 'package:artbooking/state/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';

class MyActivity extends StatefulWidget {
  @override
  _MyActivityState createState() => _MyActivityState();
}

class _MyActivityState extends State<MyActivity> {
  final _scrollController = ScrollController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: <Widget>[
          DefaultAppBar(),
          SliverList(
            delegate: SliverChildListDelegate([
              mainContentTitle(),
              body(),
              Padding(padding: const EdgeInsets.only(bottom: 200.0)),
            ]),
          ),
        ],
      ),
    );
  }

  Widget body() {
    if (isLoading) {
      return Center(
        child: FullPageLoading(),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        squareStatsRow(),
        textsStatsRow(),
      ],
    );
  }

  Widget mainContentTitle() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 20.0,
        left: 60.0,
        bottom: 40.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activity',
            style: TextStyle(
              fontSize: 90.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget squareStatsRow() {
    final stats = stateUser.userFirestore.stats;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 50.0,
        vertical: 60.0,
      ),
      child: Wrap(
        spacing: 10.0,
        runSpacing: 10.0,
        alignment: WrapAlignment.start,
        children: <Widget>[
          squareStats(
            title: 'Illustrations',
            count: stats.images.own,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => Dashboard(
                    initialIndex: 1,
                  ),
                ),
              );
            },
          ),
          squareStats(
            title: 'Books',
            count: stats.books.own,
            onTap: () {},
          ),
          squareStats(
            title: 'Galleries',
            count: stats.galleries.own,
            onTap: () {},
          ),
          squareStats(
            title: 'Challenges',
            count: stats.challenges.participating,
            onTap: () {},
          ),
          squareStats(
            title: 'Contests',
            count: stats.constests.participating,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget squareStats({
    @required String title,
    @required int count,
    @required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 200.0,
      height: 200.0,
      child: Card(
        elevation: 4.0,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 32.0,
                    fontWeight: FontWeight.w200,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget textsStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 50.0,
        vertical: 60.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FlatButton.icon(
            onPressed: () {},
            icon: Icon(Icons.storage),
            label: RichText(
              text: TextSpan(
                style: TextStyle(
                  color: stateColors.foreground.withOpacity(0.6),
                  fontSize: 20.0,
                ),
                children: [
                  TextSpan(text: "Your total used space is "),
                  TextSpan(
                    text: "${getUsedSpace()}",
                    style: TextStyle(color: stateColors.accent),
                  ),
                ],
              ),
            ),
          ),
          FlatButton.icon(
            onPressed: () {},
            icon: Icon(Icons.timelapse),
            label: RichText(
              text: TextSpan(
                style: TextStyle(
                  color: stateColors.foreground.withOpacity(0.6),
                  fontSize: 20.0,
                ),
                children: [
                  TextSpan(text: "You're a member since "),
                  TextSpan(
                    text:
                        '${Jiffy(stateUser.userFirestore.createdAt).format('MMMM yyyy')}',
                    style: TextStyle(color: stateColors.accent),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void fetch() async {
    setState(() {
      isLoading = true;
    });

    try {
      final userAuth = FirebaseAuth.instance.currentUser;

      if (userAuth == null) {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => Signin()),
          );
        });

        return;
      }

      setState(() {
        isLoading = false;
      });
    } catch (err) {
      debugPrint(err.toString());

      setState(() {
        isLoading = false;
      });
    }
  }

  String getUsedSpace() {
    final usedBytes = stateUser.userFirestore.stats.storage.images.used;
    var units = 'bytes';

    if (usedBytes < 1000) {
      return '$usedBytes $units';
    }

    if (usedBytes < 1000000) {
      units = 'KB';
      return '$usedBytes $units';
    }

    if (usedBytes < 1000000000) {
      units = 'MB';
      return '$usedBytes $units';
    }

    if (usedBytes < 1000000000000) {
      units = 'GB';
      return '$usedBytes $units';
    }

    if (usedBytes < 1000000000000000) {
      units = 'TB';
      return '$usedBytes $units';
    }

    units = 'PB';
    return '$usedBytes $units';
  }
}
