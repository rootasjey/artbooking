import 'package:artbooking/router/route_names.dart';
import 'package:artbooking/state/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_fonts/google_fonts.dart';

class SliverAppHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        return SliverAppBar(
          floating: true,
          snap: true,
          elevation: 4.0,
          forceElevated: true,
          backgroundColor: stateColors.softBackground,
          expandedHeight: 120.0,
          automaticallyImplyLeading: false,
          flexibleSpace: Stack(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(40.0),
                child: Row(
                  children: <Widget>[
                    IconButton(
                      onPressed: () {},
                      tooltip: 'Back',
                      icon: Icon(Icons.arrow_back),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: FlatButton(
                        onPressed: () {},
                        child: Text(
                          'Art Booking',
                          style: GoogleFonts.amaticSc(
                            color: stateColors.primary,
                            fontSize: 30.0,
                          ),
                        ),
                      ),
                    ),
                    VerticalDivider(
                      thickness: 1.0,
                      width: 32.0,
                    ),
                    FlatButton(
                      onPressed: () {
                        // FluroRouter.router.navigateTo(context, RootRoute);
                      },
                      child: Text(
                        'News',
                        style: TextStyle(
                          fontSize: 20.0,
                        ),
                      ),
                    ),
                    FlatButton(
                      onPressed: () {
                        // FluroRouter.router.navigateTo(context, RootRoute);
                      },
                      child: Text(
                        'Events',
                        style: TextStyle(
                          fontSize: 20.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Positioned(
                right: 50.0,
                top: 30.0,
                child: Row(
                  children: <Widget>[
                    Material(
                      elevation: 4.0,
                      shape: CircleBorder(),
                      clipBehavior: Clip.hardEdge,
                      color: Colors.transparent,
                      child: Ink.image(
                        image: NetworkImage(
                            'https://drawinghowtos.com/wp-content/uploads/2019/04/fox-colored.png'),
                        fit: BoxFit.cover,
                        width: 60.0,
                        height: 60.0,
                        child: InkWell(
                          onTap: () {},
                        ),
                      ),
                    ),
                    Padding(
                        padding: const EdgeInsets.only(
                      left: 30.0,
                    )),
                    RaisedButton(
                      onPressed: () {
                        if (ModalRoute.of(context).settings.name ==
                            UploadRoute) {
                          return;
                        }
                      },
                      color: stateColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(7.0),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          'Upload',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              // Divider(thickness: 2.0,),
            ],
          ),
        );
      },
    );
  }
}
