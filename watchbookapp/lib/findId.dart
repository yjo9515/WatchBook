import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:async';

class FindId extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _FindId();
  }
}
class _FindId extends State<FindId> {
  WebViewController? _webViewController;
  final Completer<WebViewController> _controllerCompleter =
  Completer<WebViewController>();
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            child: WebView(
              key: UniqueKey(),
              initialUrl: 'http://watchbook.tv',
              onWebViewCreated: (WebViewController webViewController) {
                _controllerCompleter.future
                    .then((value) => _webViewController = value);
                _controllerCompleter.complete(webViewController);
              },
              javascriptMode: JavascriptMode.unrestricted,
            ),
          ),
        );
  }
  }

