import 'package:artbooking/components/full_page_loading.dart';
import 'package:artbooking/components/sidebar_header.dart';
import 'package:artbooking/components/sliver_appbar_header.dart';
import 'package:artbooking/screens/illustrations.dart';
import 'package:artbooking/screens/signin.dart';
import 'package:artbooking/state/colors.dart';
import 'package:artbooking/state/user.dart';
import 'package:artbooking/types/enums.dart';
import 'package:artbooking/types/user/user_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jiffy/jiffy.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  bool smallViewVisible = false;
  bool isLoading = false;

  double storageUsed = 0.0;

  ScrollController _scrollController = ScrollController();

  UserFirestore userFirestore;
  var _selectedSection = UserMenuSelect.dashboard;

  @override
  void initState() {
    super.initState();
    fetch();
  }

  @override
  Widget build(BuildContext context) {
    return wideView();
  }

  Widget mainContent() {
    if (isLoading) {
      return Center(
        child: FullPageLoading(),
      );
    }

    return CustomScrollView(
      controller: _scrollController,
      slivers: <Widget>[
        SliverAppHeader(),
        SliverList(
          delegate: SliverChildListDelegate([
            mainContentTitle(),
            squareStatsRow(),
            textsStatsRow(),
            Padding(padding: const EdgeInsets.only(bottom: 200.0)),
          ]),
        ),
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
          Opacity(
            opacity: 0.6,
            child: Text(
              'Dashboard',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w200,
              ),
            ),
          ),
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

  Widget leftSide() {
    return ListView(
      children: <Widget>[
        if (!smallViewVisible)
          Padding(
            padding: const EdgeInsets.only(
              top: 40.0,
              bottom: 100.0,
              left: 20.0,
              right: 20.0,
            ),
            child: SideBarHeader(),
          ),
        sectionTileItem(
          title: "Illustrations",
          leading: Icon(Icons.image),
          section: UserMenuSelect.illustrations,
        ),
        sectionTileItem(
          title: "Books",
          leading: Icon(Icons.my_library_books),
          section: UserMenuSelect.books,
        ),
        sectionTileItem(
          title: "Galleries",
          // leading: Icon(Icons.home_work_rounded),
          leading: Icon(FontAwesomeIcons.landmark),
          section: UserMenuSelect.galleries,
        ),
        sectionTileItem(
          title: "Challenges",
          leading: Icon(FontAwesomeIcons.award),
          section: UserMenuSelect.challenges,
        ),
        sectionTileItem(
          title: "Contests",
          leading: Icon(FontAwesomeIcons.trophy),
          section: UserMenuSelect.contests,
        ),
        // Padding(
        //   padding: const EdgeInsets.only(bottom: 20.0),
        // ),
        Divider(thickness: 1.0, color: stateColors.foreground, height: 40.0),
        sectionTileItem(
          title: "Settings",
          leading: Icon(Icons.settings),
          section: UserMenuSelect.settings,
        ),
        sectionTileItem(
          title: "About",
          leading: Icon(Icons.help),
          section: UserMenuSelect.about,
        ),
        Padding(padding: const EdgeInsets.only(bottom: 60.0)),
      ],
    );
  }

  Widget sectionTileItem({
    @required String title,
    Widget leading,
    @required UserMenuSelect section,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 24.0,
        vertical: 4.0,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
      leading: leading,
      trailing:
          section == _selectedSection ? Icon(Icons.keyboard_arrow_right) : null,
      onTap: () {
        setState(() {
          _selectedSection = section;
        });

        // final width = MediaQuery.of(context).size.width;
        // if (width < 500.0) {
        //   _innerDrawerKey.currentState.close();
        // }
      },
    );
  }

  Widget wideView() {
    return Material(
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              foregroundDecoration: BoxDecoration(
                color: Color.fromRGBO(0, 0, 0, 0.05),
              ),
              // padding: const EdgeInsets.symmetric(
              //   horizontal: 20.0,
              // ),
              child: leftSide(),
            ),
          ),
          Expanded(
            flex: 3,
            child: mainContent(),
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
            title: "Illustrations",
            count: stats.images.own,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => Illustrations()),
              );
            },
          ),
          squareStats(
            title: "Books",
            count: stats.books.own,
            onTap: () {},
          ),
          squareStats(
            title: "Galleries",
            count: stats.galleries.own,
            onTap: () {},
          ),
          squareStats(
            title: "Challenges",
            count: stats.challenges.participating,
            onTap: () {},
          ),
          squareStats(
            title: "Contests",
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
                  color: stateColors.foreground,
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
                  color: stateColors.foreground,
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
