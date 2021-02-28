import 'package:artbooking/components/app_icon.dart';
import 'package:artbooking/state/upload_manager.dart';
import 'package:artbooking/screens/dashboard.dart';
import 'package:artbooking/screens/signin.dart';
import 'package:artbooking/state/colors.dart';
import 'package:artbooking/state/user.dart';
import 'package:artbooking/types/enums.dart';
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
      return rightSectionUser();
    }

    return rightSectionGuest();
  }

  Widget rightSectionGuest() {
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

  Widget rightSectionUser() {
    return Positioned(
      right: 50.0,
      top: 30.0,
      child: Row(
        children: <Widget>[
          PopupMenuButton(
            icon: CircleAvatar(
              backgroundImage: AssetImage('assets/images/default-avatar.png'),
              radius: 42.0,
            ),
            onSelected: (userMenuSelect) {
              switch (userMenuSelect) {
                case UserMenuSelect.dashboard:
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => Dashboard()));
                  break;
                case UserMenuSelect.illustrations:
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => Dashboard(
                            initialIndex: 1,
                          )));
                  break;
                case UserMenuSelect.signout:
                  stateUser.signOut(
                    context: context,
                    redirectOnComplete: true,
                  );
                  break;
                default:
              }
            },
            itemBuilder: (_) => <PopupMenuEntry<UserMenuSelect>>[
              PopupMenuItem(
                value: UserMenuSelect.dashboard,
                child: Wrap(
                  spacing: 10.0,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Icon(Icons.dashboard),
                    Text('Dashboard'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: UserMenuSelect.illustrations,
                child: Wrap(
                  spacing: 10.0,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Icon(Icons.image),
                    Text('Illustrations'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: UserMenuSelect.settings,
                child: Wrap(
                  spacing: 10.0,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Icon(Icons.settings),
                    Text('Settings'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: UserMenuSelect.signout,
                child: Wrap(
                  spacing: 10.0,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Icon(FontAwesomeIcons.signOutAlt),
                    Text('Sign out'),
                  ],
                ),
              ),
            ],
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
}
