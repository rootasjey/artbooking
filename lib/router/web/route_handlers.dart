import 'package:artbooking/screens/forgot_password.dart';
import 'package:artbooking/screens/home.dart';
import 'package:artbooking/screens/signin.dart';
import 'package:artbooking/screens/signup.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';

class WebRouteHandlers {
  static Handler home = Handler(
    handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
      Home());

  static Handler forgotPassword = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          ForgotPassword());

  static Handler signin = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          Signin());

  static Handler signup = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          Signup());
}
