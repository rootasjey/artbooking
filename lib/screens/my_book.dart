import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

class MyBook extends StatefulWidget {
  final String bookId;

  const MyBook({
    Key key,
    @required @PathParam() this.bookId,
  }) : super(key: key);
  @override
  _MyBookState createState() => _MyBookState();
}

class _MyBookState extends State<MyBook> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Text("My Book"),
      ),
    );
  }
}
