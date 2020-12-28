import 'package:artbooking/components/app_icon.dart';
import 'package:artbooking/components/upload_manager.dart';
import 'package:artbooking/screens/dashboard.dart';
import 'package:artbooking/screens/signin.dart';
import 'package:artbooking/state/colors.dart';
import 'package:artbooking/state/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SliverAppHeader extends StatefulWidget {
  final bool showBackButton;

  SliverAppHeader({
    this.showBackButton = true,
  });

  @override
  _SliverAppHeaderState createState() => _SliverAppHeaderState();
}

class _SliverAppHeaderState extends State<SliverAppHeader> {
  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        return SliverAppBar(
          floating: true,
          snap: true,
          backgroundColor: stateColors.softBackground,
          expandedHeight: 120.0,
          automaticallyImplyLeading: false,
          flexibleSpace: Stack(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(40.0),
                child: Row(
                  children: <Widget>[
                    if (widget.showBackButton)
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        tooltip: 'Back',
                        icon: Icon(Icons.arrow_back),
                      ),
                    AppIcon(),
                    VerticalDivider(
                      thickness: 1.0,
                      width: 32.0,
                    ),
                    headerButton(
                      onPressed: () {},
                      title: 'Challenges',
                    ),
                    headerButton(
                      onPressed: () {},
                      title: 'Contests',
                    ),
                  ],
                ),
              ),
              rightSection(),
            ],
          ),
        );
      },
    );
  }

  Widget headerButton({
    @required String title,
    VoidCallback onPressed,
  }) {
    return Opacity(
      opacity: 0.6,
      child: FlatButton(
        onPressed: onPressed,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 20.0,
          ),
        ),
      ),
    );
  }

  Widget rightSection() {
    if (stateUser.isUserConnected) {
      return Positioned(
        right: 50.0,
        top: 30.0,
        child: Row(
          children: <Widget>[
            Material(
              elevation: 4.0,
              shape: CircleBorder(),
              clipBehavior: Clip.hardEdge,
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => Dashboard()),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Opacity(
                    opacity: 0.6,
                    child: Icon(
                      Icons.person_outline,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Tooltip(
                message: "Upload",
                child: Material(
                  elevation: 4.0,
                  shape: CircleBorder(),
                  clipBehavior: Clip.hardEdge,
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      appUploadManager.pickImage(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Opacity(
                        opacity: 0.6,
                        child: Icon(
                          Icons.upload_outlined,
                          size: 24.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      );
    }

    return Positioned(
      right: 50.0,
      top: 30.0,
      child: Row(
        children: [
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => Signin()),
              );
            },
            icon: Icon(FontAwesomeIcons.signInAlt),
            label: Text(
              'Signin',
              style: TextStyle(
                fontSize: 16.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
