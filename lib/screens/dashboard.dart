import 'package:artbooking/components/sidebar_header.dart';
import 'package:artbooking/screens/books.dart';
import 'package:artbooking/screens/illustrations.dart';
import 'package:artbooking/screens/settings.dart';
import 'package:artbooking/screens/stats_overview.dart';
import 'package:artbooking/state/colors.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Dashboard extends StatefulWidget {
  final int initialIndex;

  Dashboard({this.initialIndex = 0});

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  bool smallViewVisible = false;
  bool isLoading = false;

  int _sectionIndex = 0;

  List<Widget> _sectionsChildren = [
    StatsOverview(),
    Illustrations(),
    Books(),
    Settings(),
  ];

  @override
  void initState() {
    super.initState();

    setState(() {
      _sectionIndex = widget.initialIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return wideView();
  }

  Widget leftSide() {
    return ListView(
      children: <Widget>[
        if (!smallViewVisible)
          Padding(
            padding: const EdgeInsets.only(
              top: 30.0,
              bottom: 100.0,
              left: 20.0,
              right: 20.0,
            ),
            child: SideBarHeader(),
          ),
        sectionTileItem(
          index: 0,
          title: 'Activity',
          leading: Icon(Icons.show_chart_rounded),
        ),
        sectionTileItem(
          index: 1,
          title: 'Illustrations',
          leading: Icon(Icons.image),
        ),
        sectionTileItem(
          index: 2,
          title: 'Books',
          leading: Icon(Icons.my_library_books),
        ),
        sectionTileItem(
          index: 3,
          title: 'Galleries',
          // leading: Icon(Icons.home_work_rounded),
          leading: Icon(FontAwesomeIcons.landmark),
        ),
        sectionTileItem(
          index: 4,
          title: 'Challenges',
          leading: Icon(FontAwesomeIcons.award),
        ),
        sectionTileItem(
          index: 5,
          title: 'Contests',
          leading: Icon(FontAwesomeIcons.trophy),
        ),
        Divider(
          thickness: 0.5,
          color: stateColors.foreground,
          height: 40.0,
          indent: 60.0,
          endIndent: 60.0,
        ),
        sectionTileItem(
          index: 6,
          title: 'Settings',
          leading: Icon(Icons.settings),
        ),
        sectionTileItem(
          index: 7,
          title: 'About',
          leading: Icon(Icons.help),
        ),
        Padding(padding: const EdgeInsets.only(bottom: 60.0)),
      ],
    );
  }

  Widget sectionTileItem({
    @required String title,
    Widget leading,
    @required index,
  }) {
    return ListTile(
      selected: _sectionIndex == index,
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
          _sectionIndex == index ? Icon(Icons.keyboard_arrow_right) : null,
      onTap: () {
        setState(() {
          _sectionIndex = index;
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
              child: leftSide(),
            ),
          ),
          Expanded(
            flex: 3,
            child: _sectionsChildren[_sectionIndex],
          ),
        ],
      ),
    );
  }
}
