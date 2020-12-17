import 'package:artbooking/components/sliver_appbar_header.dart';
import 'package:artbooking/state/colors.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: <Widget>[
          SliverAppHeader(),
          bodyListContent(),
        ],
      ),
    );
  }

  Widget bodyListContent() {
    return SliverList(
      delegate: SliverChildListDelegate([
        Padding(
          padding: const EdgeInsets.only(
            top: 80.0,
          ),
        ),
        userIdentity(),
        Divider(
          thickness: 1.0,
          height: 200.0,
        ),
        sectionsView(),
        Padding(
            padding: const EdgeInsets.only(
          bottom: 200.0,
        ))
      ]),
    );
  }

  Widget userIdentity() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Material(
          elevation: 3.0,
          shape: CircleBorder(),
          clipBehavior: Clip.hardEdge,
          color: Colors.transparent,
          child: Ink.image(
            image: NetworkImage(
                'https://drawinghowtos.com/wp-content/uploads/2019/04/fox-colored.png'),
            fit: BoxFit.cover,
            width: 150.0,
            height: 150.0,
            child: InkWell(
              onTap: () {
                showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        content: Container(
                          child: Image(
                            image: AssetImage(
                                'https://drawinghowtos.com/wp-content/uploads/2019/04/fox-colored.png'),
                          ),
                        ),
                      );
                    });
              },
            ),
          ),
        ),
        Padding(padding: const EdgeInsets.only(left: 50.0)),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Username',
              style: TextStyle(
                fontSize: 30.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Opacity(
              opacity: .6,
              child: Text(
                'Paris, FR',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 25.0),
              child: FlatButton(
                onPressed: () {},
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: stateColors.foreground,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(7.0)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    'Edit Profile',
                  ),
                ),
              ),
            )
          ],
        ),
      ],
    );
  }

  Widget sectionsView() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Wrap(
        alignment: WrapAlignment.center,
        children: <Widget>[
          SizedBox(
            width: 240.0,
            height: 300.0,
            child: Card(
              child: InkWell(
                onTap: () {
                  // Go to IllustrationsRoute
                },
                child: Center(
                  child: Text(
                    'Illustrations',
                    style: TextStyle(
                      fontSize: 20.0,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
