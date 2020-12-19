library webapp;

import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebApp extends StatelessWidget {
  final String title;
  final String initialUrl;
  final String containsUrl;
  final controller = Completer<WebViewController>();

  WebApp(this.title, this.initialUrl, this.containsUrl, {Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: title,
      home: WillPopScope(
        onWillPop: () async {
          var ctr = await controller.future;
          if (await ctr.canGoBack()) {
            ctr.goBack();
            return false;
          }
          return true;
        },
        child: Scaffold(
          body: Container(
            child: Center(
              child: WebView(
                initialUrl: initialUrl,
                javascriptMode: JavascriptMode.unrestricted,
                onWebViewCreated: (WebViewController webViewController) {
                  controller.complete(webViewController);
                },
                navigationDelegate: (NavigationRequest request) {
                  if (!request.url.contains(containsUrl)) {
                    _launchURL(request.url);
                    return NavigationDecision.prevent;
                  }
                  return NavigationDecision.navigate;
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  _launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      log('Could not launch $url');
    }
  }
}
