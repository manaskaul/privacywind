import 'package:flutter/material.dart';
import 'package:privacywind/app_search/search_category/app_detail_model.dart';

class AppCompare extends StatefulWidget {
  final List<AppDetail> compareApps;

  AppCompare({this.compareApps});

  @override
  _AppCompareState createState() => _AppCompareState();
}

class _AppCompareState extends State<AppCompare> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("App Search"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            child: ListTile(
              title: Text("${widget.compareApps[0].appName}"),
              leading: CircleAvatar(
                backgroundImage:
                    NetworkImage("${widget.compareApps[0].iconString}"),
                backgroundColor: Colors.transparent,
              ),
            ),
          ),
          Container(
            child: ListTile(
              title: Text("${widget.compareApps[1].appName}"),
              leading: CircleAvatar(
                backgroundImage:
                    NetworkImage("${widget.compareApps[1].iconString}"),
                backgroundColor: Colors.transparent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
