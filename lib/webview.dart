import 'dart:async';
import 'package:flutter/material.dart';
import 'package:oa_webview/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class OAWebView extends StatefulWidget {
  const OAWebView({super.key});

  @override
  State<OAWebView> createState() => _OAWebViewState();
}

class _OAWebViewState extends State<OAWebView> {
  late final WebViewController _controller;
  final bool _visible = true;

  @override
  void initState() {
    String? conId = "1";
    String? conDevice = "ABC1234";
    String? conEmail = "test@gmail.com";
    String? conMobile = "0951929299";
    String? url = "";

    super.initState();
// #docregion platform_features
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params,
            onPermissionRequest: (WebViewPermissionRequest request) async {
      final cameraStatus = await Permission.camera.request();
      request.grant();
    });
    // #enddocregion platform_features

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      //..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('WebView is loading (progress : $progress%)');
          },
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) {
            debugPrint('Page finished loading: $url');
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('''
                Page resource error:
                  code: ${error.errorCode}
                  description: ${error.description}
                  errorType: ${error.errorType}
                  isForMainFrame: ${error.isForMainFrame}
                          ''');
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              debugPrint('blocking navigation to ${request.url}');
              return NavigationDecision.prevent;
            }
            debugPrint('allowing navigation to ${request.url}');
            return NavigationDecision.navigate;
          },
          onUrlChange: (UrlChange change) {
            debugPrint('url change to ${change.url}');
          },
        ),
      )
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (JavaScriptMessage message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        },
      );
    // ..loadRequest( Uri.parse(url!));

    // #docregion platform_features
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
    if (controller.platform is WebKitWebViewController) {
      (controller.platform as WebKitWebViewController)
          .setOnPlatformPermissionRequest((request) async {
        final cameraStatus = await Permission.camera.request();
        request.grant();
      });
    }
    // #enddocregion platform_features

    _controller = controller;

    try {
      Future<Users> data = ShareData().getData();
      if (data != null) {
        data.then((value) async {
          conId = value.userid ?? conId;
          conDevice = value.deviceid ?? conDevice;
          conEmail = value.email ?? conEmail;
          conMobile = value.moible ?? conMobile;
          Users users = Users();
          users.userid = conId;
          users.deviceid = conDevice;
          users.email = conEmail;
          users.moible = conMobile;
          ShareData().setData(users);
          url =
              "https://dev-oa-web-daolmun.daolsecurities.co.th/oa?deviceId=$conDevice&userId=$conId&mobile=$conMobile&email=$conEmail";
          await _controller.loadRequest(Uri.parse(url!));
        });
      }
    } catch (e) {
      Users users = Users();
      users.userid = conId;
      users.deviceid = conDevice;
      users.email = conEmail;
      users.moible = conMobile;
      ShareData().setData(users);
      url =
          "https://dev-oa-web-daolmun.daolsecurities.co.th/oa?deviceId=$conDevice&userId=$conId&mobile=$conMobile&email=$conEmail";
      _controller.loadRequest(Uri.parse(url!));
    } finally {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _visible
          ? null
          : AppBar(
              title: const Text('DAOL MUN Onboarding'),
              // This drop down menu demonstrates that Flutter widgets can be shown over the web view.
              actions: <Widget>[
                NavigationControls(webViewController: _controller),
                IconButton(
                    onPressed: () async {
                      _showDialogWithFields(context, _controller);
                    },
                    icon: const Icon(Icons.person)),
                //SampleMenu(webViewController: _controller),
              ],
            ),
      body: SafeArea(
          child: WebViewWidget(
        controller: _controller,
      )),
      floatingActionButton: favoriteButton(),
    );
  }

  Widget favoriteButton() {
    return FloatingActionButton(
      onPressed: () async {
        // setState(() {
        //   _visible = !_visible;
        // });
        _showDialogWithFields(context, _controller);
      },
      child: const Icon(Icons.favorite),
    );
  }

  void _showDialogWithFields(
      BuildContext context, WebViewController controller) {
    final _conId = TextEditingController();
    final _conDevice = TextEditingController();
    final _conEmail = TextEditingController();
    final _conMobile = TextEditingController();

    Future<Users> data = ShareData().getData();
    data.then((value) {
      _conId.text = value.userid!;
      _conDevice.text = value.deviceid!;
      _conEmail.text = value.email!;
      _conMobile.text = value.moible!;
    });

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(
                  20.0,
                ),
              ),
            ),
            contentPadding: const EdgeInsets.only(
              top: 10.0,
            ),
            title: const Text(
              "Start request",
              style: TextStyle(fontSize: 20.0),
            ),
            content: SizedBox(
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
                        controller: _conId,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Enter User ID here',
                            labelText: 'User ID'),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6.0),
                      child: TextField(
                        controller: _conDevice,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Enter Device ID here',
                            labelText: 'Device ID'),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6.0),
                      child: TextField(
                        controller: _conMobile,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Enter Mobile here',
                            labelText: 'Mobile'),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6.0),
                      child: TextField(
                        controller: _conEmail,
                        decoration: const InputDecoration(
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
                          Users users = Users();
                          users.userid = _conId.text;
                          users.deviceid = _conDevice.text;
                          users.email = _conEmail.text;
                          users.moible = _conMobile.text;
                          ShareData().setData(users);
                          await controller.loadRequest(Uri.parse(
                              "https://dev-oa-web-daolmun.daolsecurities.co.th/oa?deviceId=${_conDevice.text}&userId=${_conId.text}&mobile=${_conMobile.text}&email=${_conEmail.text}"));
                        },
                        style: ElevatedButton.styleFrom(
                            // primary: Colors.black,
                            // fixedSize: Size(250, 50),
                            ),
                        child: const Text(
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

class NavigationControls extends StatelessWidget {
  const NavigationControls({super.key, required this.webViewController});

  final WebViewController webViewController;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () async {
            if (await webViewController.canGoBack()) {
              await webViewController.goBack();
            } else {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No back history item')),
                );
              }
            }
          },
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward_ios),
          onPressed: () async {
            if (await webViewController.canGoForward()) {
              await webViewController.goForward();
            } else {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No forward history item')),
                );
              }
            }
          },
        ),
        IconButton(
          icon: const Icon(Icons.replay),
          onPressed: () => webViewController.reload(),
        ),
      ],
    );
  }
}
