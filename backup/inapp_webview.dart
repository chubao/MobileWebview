
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:oa_webview/webview.dart';
import 'package:permission_handler/permission_handler.dart';

enum ProgressIndicatorType { circular, linear }

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey webViewKey = GlobalKey();
  bool _visible = true;
  InAppWebViewController? webViewController;
  double progress = 0;
  ProgressIndicatorType type = ProgressIndicatorType.linear;


  @override
  void initState() {
    super.initState();
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
       InAppWebViewController.setWebContentsDebuggingEnabled(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _visible
          ? null
          : AppBar(
        title: Text("DAOL MUN Onboarding",
            style: const TextStyle(fontSize: 18)),
        actions: [
          IconButton(
              onPressed: () async {
                _showDialogWithFields(context, webViewController!);
              },
              icon: const Icon(Icons.person)),
          IconButton(
              onPressed: () async {
                await webViewController?.clearCache();
                await webViewController?.reload();
              },
              icon: const Icon(Icons.refresh)),
        ],
      ),
      body: SafeArea(
          child: Column(children: <Widget>[
            Expanded(
                child: Stack(children: [
                  InAppWebView(
                    key: webViewKey,
                    initialUrlRequest: URLRequest(
                        url: WebUri(
                            "https://dev-oa-web-daolmun.daolsecurities.co.th/oa?deviceId=123456&userId=11111&mobile=0970911963&email=kobpeapoo@gmail.com")),
                    initialSettings: InAppWebViewSettings(
                      mediaPlaybackRequiresUserGesture: false,
                      allowsInlineMediaPlayback: true,
                    ),
                    onWebViewCreated: (controller) {
                      webViewController = controller;
                    },
                    onProgressChanged: (controller, progress) {
                      setState(() {
                        this.progress = progress / 100;
                      });
                    },
                    onPermissionRequest: (controller, request) async {
                      final resources = <PermissionResourceType>[];
                      if (request.resources.contains(PermissionResourceType.CAMERA)) {
                        final cameraStatus = await Permission.camera.request();
                        if (!cameraStatus.isDenied) {
                          resources.add(PermissionResourceType.CAMERA);
                        }
                      }
                      if (request.resources
                          .contains(PermissionResourceType.MICROPHONE)) {
                        final microphoneStatus = await Permission.microphone.request();
                        if (!microphoneStatus.isDenied) {
                          resources.add(PermissionResourceType.MICROPHONE);
                        }
                      }
                      // only for iOS and macOS
                      if (request.resources
                          .contains(PermissionResourceType.CAMERA_AND_MICROPHONE)) {
                        final cameraStatus = await Permission.camera.request();
                        final microphoneStatus = await Permission.microphone.request();
                        if (!cameraStatus.isDenied && !microphoneStatus.isDenied) {
                          resources.add(PermissionResourceType.CAMERA_AND_MICROPHONE);
                        }
                      }
                      return PermissionResponse(
                          resources: resources,
                          action:
                          // resources.isEmpty
                          //     ? PermissionResponseAction.DENY
                          //     :
                          PermissionResponseAction.GRANT);
                    },
                  ),
                  progress < 1.0 ? getProgressIndicator(type) : Container(),
                ])),
          ])),
      floatingActionButton: favoriteButton(),
    );
  }

  Widget getProgressIndicator(ProgressIndicatorType type) {
    switch (type) {
      case ProgressIndicatorType.circular:
        return Center(
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: Colors.white.withAlpha(70),
            ),
            child: const CircularProgressIndicator(),
          ),
        );
      case ProgressIndicatorType.linear:
      default:
        return LinearProgressIndicator(
          value: progress,
        );
    }
  }

  Widget favoriteButton() {
    return FloatingActionButton(
      onPressed: () {
        setState(() {
          _visible = !_visible;
        });
      },
      child: const Icon(Icons.home),
    );
  }

  void _showDialogWithFields(BuildContext context, InAppWebViewController _controller) {
    final con_id = TextEditingController();
    final con_device = TextEditingController();
    final con_email = TextEditingController();
    final con_mobile = TextEditingController();

    con_id.text = "123456";
    con_device.text = "123456";
    con_email.text = "kobpeapoo@gmail.com";
    con_mobile.text = "0970911963";
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(
                  20.0,
                ),
              ),
            ),
            contentPadding: EdgeInsets.only(
              top: 10.0,
            ),
            title: Text(
              "Start request",
              style: TextStyle(fontSize: 20.0),
            ),
            content: Container(
              height: 400,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(6.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(6.0),
                      child: TextField(
                        controller: con_id,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Enter User ID here',
                            labelText: 'User ID'),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6.0),
                      child: TextField(
                        controller: con_device,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Enter Device ID here',
                            labelText: 'Device ID'),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6.0),
                      child: TextField(
                        controller: con_mobile,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Enter Mobile here',
                            labelText: 'Mobile'),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6.0),
                      child: TextField(
                        controller: con_email,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Enter Email here',
                            labelText: 'Email'),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      height: 60,
                      padding: const EdgeInsets.all(6.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          await webViewController?.loadUrl(
                              urlRequest: URLRequest(
                                  url: WebUri(
                                      "https://dev-oa-web-daolmun.daolsecurities.co.th/oa?deviceId=123456&userId=11111&mobile=0970911963&email=kobpeapoo@gmail.com")));
                        },
                        style: ElevatedButton.styleFrom(
                          // primary: Colors.black,
                          // fixedSize: Size(250, 50),
                        ),
                        child: Text(
                          "Submit",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}