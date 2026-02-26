import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final AppBar? appBar;
  // 他の Scaffold プロパティも必要に応じて追加

  const AppScaffold({super.key, required this.body, this.appBar});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: SafeArea(
        bottom: false, // SafeArea の bottom は自前で管理
        child: Padding(
          padding: EdgeInsets.only(
            bottom:
                MediaQuery.of(context).padding.bottom + 10, // SafeArea分 + 10px
          ),
          child: body,
        ),
      ),
    );
  }
}
