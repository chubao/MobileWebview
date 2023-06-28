import 'dart:async';
import 'package:flutter/material.dart';
import 'package:oa_webview/webview.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //runApp(const MaterialApp(home: MyApp()));
  //OAWebView
  runApp(const MaterialApp(home: OAWebView()));
}


