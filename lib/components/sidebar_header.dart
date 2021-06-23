import 'package:artbooking/router/route_names.dart';
import 'package:artbooking/screens/signin_page.dart';
import 'package:artbooking/state/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class SideBarHeader extends StatefulWidget {
  @override
  _SideBarHeaderState createState() => _SideBarHeaderState();
}

class _SideBarHeaderState extends State<SideBarHeader> {
  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      return stateUser.isUserConnected ? authenticatedView() : guestView();
    });
  }

  Widget authenticatedView() {
    return ListTile(
      leading: Icon(Icons.person_outline_rounded),
      title: Tooltip(
        message: stateUser.username!,
        child: Text(
          stateUser.username!,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget guestView() {
    return Row(
      children: <Widget>[
        ElevatedButton(
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => SigninPage()));
          },
          style: ElevatedButton.styleFrom(
            primary: Colors.black12,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(7.0),
              ),
            ),
          ),
          child: Container(
            width: 100.0,
            padding: const EdgeInsets.all(15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'SIGN IN',
                  style: TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        Spacer(),
        PopupMenuButton<String>(
          icon: Icon(Icons.keyboard_arrow_down),
          tooltip: 'Menu',
          onSelected: (value) {
            // Rerouter.push(
            //   context: context,
            //   value: value,
            // );
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem(
                value: RootRoute,
                child: ListTile(
                  leading: Icon(Icons.home),
                  title: Text(
                    'Home',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                )),
            const PopupMenuItem(
              value: AccountRoute,
              child: ListTile(
                leading: Icon(Icons.settings),
                title: Text(
                  'Settings',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
