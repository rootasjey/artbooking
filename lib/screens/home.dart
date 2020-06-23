import 'package:artbooking/router/route_names.dart';
import 'package:artbooking/router/router.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(30.0),
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              header(),
              heroContent(),
            ],
          ),
        ],
      ),
    );
  }

  Widget header() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: Text(
              'Art Booking',
              style: GoogleFonts.amaticSc(
                color: Colors.green.shade300,
                fontSize: 30.0,
              ),
            ),
          ),

          // Padding(
          //   padding: const EdgeInsets.only(
          //     left: 60.0,
          //     right: 20.0,
          //   ),
          //   child: FlatButton(
          //     onPressed: () {},
          //     child: Text(
          //       'Log In'
          //     ),
          //   ),
          // ),

          // Text(
          //   'or',
          // ),

          Padding(
            padding: const EdgeInsets.only(left: 30.0),
            child: RaisedButton(
              onPressed: () {
                FluroRouter.router.navigateTo(context, SigninRoute);
              },
              color: Colors.green.shade300,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(25.0),
                ),
              ),
              child: Text(
                'Sign in',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget heroContent() {
    return Container(
      padding: const EdgeInsets.only(
        top: 60.0,
        left: 30.0,
        right: 30.0,
        bottom: 30.0,
      ),
      height: MediaQuery.of(context).size.height - 100.0,
      child: Row(
        children: <Widget>[
          heroIllustration(),
          heroText(),
        ],
      ),
    );
  }

  Widget heroText() {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Illustration title',
            style: GoogleFonts.amaticSc(
              fontSize: 60.0,
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 40.0,
            ),
            child: Opacity(
              opacity: .6,
              child: Text(
                "Lore: It was a night of full moon. No sound around...",
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
            ),
          ),

          RaisedButton(
            onPressed: () {},
            color: Colors.green.shade300,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(25.0),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                'Read More',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget heroIllustration() {
    return Expanded(
      child: Card(
        elevation: 4.0,
        child: InkWell(
          onTap: () {},
          child: Image.network(
            'https://firebasestorage.googleapis.com/v0/b/artbooking-54d22.appspot.com/o/art%2Fjeremie_corpinot%2FFlorale%2Fflorale_0.png?alt=media&token=34ce2dee-aad4-4c4e-b9fd-ed72184f7ffa',
            // fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
