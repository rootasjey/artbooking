import 'package:flutter/material.dart';

class FullPageLoading extends StatelessWidget {
  final String title;

  FullPageLoading({
    this.title = 'Loading...',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Column(
        children: <Widget>[
          CircularProgressIndicator(),

          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Text(
              this.title,
              style: TextStyle(
                fontSize: 30.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
