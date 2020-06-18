import 'package:artbooking/screens/home.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';

class WebRouteHandlers {
  static Handler home = Handler(
    handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
      Home());
}
