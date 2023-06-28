import 'dart:async';
import 'package:flutter/material.dart';
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
  bool _visible = true;

  @override
  void initState() {
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
      ..setBackgroundColor(const Color(0x00000000))
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
      )
      ..loadRequest(Uri.parse(
          'https://dev-oa-web-daolmun.daolsecurities.co.th/oa?deviceId=123456&userId=11111&mobile=0970911963&email=kobpeapoo@gmail.com'));

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
  }
  // Future<void> requestCameraPermission() async {
  //   final status = await Permission.camera.request();
  //   debugPrint('Permission Status ${status}');
  //   if (status == PermissionStatus.granted) {
  //     // Permission granted.
  //   } else if (status == PermissionStatus.denied) {
  //     // Permission denied.
  //   } else if (status == PermissionStatus.permanentlyDenied) {
  //     // Permission permanently denied.
  //   }
  // }

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
                      _showDialogWithFields(context, _controller!);
                    },
                    icon: const Icon(Icons.person)),
                //SampleMenu(webViewController: _controller),
              ],
            ),
      body: SafeArea(child: WebViewWidget(controller: _controller)),
      floatingActionButton: favoriteButton(),
    );
  }

  Widget favoriteButton() {
    return FloatingActionButton(
      onPressed: () async {
        setState(() {
          _visible = !_visible;
        });
      },
      child: const Icon(Icons.favorite),
    );
  }

  void _showDialogWithFields(
      BuildContext context, WebViewController _controller) {
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
                          await _controller.loadRequest(Uri.parse(
                              "https://dev-oa-web-daolmun.daolsecurities.co.th/oa?deviceId=123456&userId=11111&mobile=0970911963&email=kobpeapoo@gmail.com"));
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
