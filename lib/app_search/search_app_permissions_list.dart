import 'package:flutter/material.dart';
import 'package:privacywind/constants/loading.dart';
import 'package:privacywind/constants/permissions_icon_data.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:url_launcher/url_launcher.dart';

class SearchAppPermissionList extends StatefulWidget {
  final String packageName, appName, iconString, appSummary, playURL;

  SearchAppPermissionList(
      {this.packageName,
      this.appName,
      this.iconString,
      this.appSummary,
      this.playURL});

  @override
  _SearchAppPermissionListState createState() =>
      _SearchAppPermissionListState();
}

class _SearchAppPermissionListState extends State<SearchAppPermissionList> {
  List<dynamic> permissionsList = [];
  bool hasPermissions = false;

  @override
  void initState() {
    super.initState();
    getSearchAppPermissions(
        widget.packageName, widget.appName, widget.iconString);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("App Search"),
        centerTitle: true,
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, value) => [
          SliverToBoxAdapter(
            child: Container(
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(15.0),
                    child: CircleAvatar(
                      backgroundImage: NetworkImage("${widget.iconString}"),
                      radius: 60.0,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(
                        top: 10.0, bottom: 10.0, left: 15.0, right: 15.0),
                    child: Text(
                      widget.appName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 25.0,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        EdgeInsets.only(bottom: 10.0, left: 15.0, right: 15.0),
                    child: Flexible(
                      child: Text(
                        widget.appSummary,
                        maxLines: 2,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15.0,
                        ),
                      ),
                    ),
                  ),
                  Container(
                      padding: EdgeInsets.only(bottom: 5.0),
                      child: OutlineButton(
                        borderSide:
                            BorderSide(color: Theme.of(context).primaryColor),
                        child: Text("Open in Play Store"),
                        onPressed: () async {
                          try {
                            await openAppInPlayStore(widget.playURL);
                          } catch (e) {
                            Scaffold.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text("Could not open app in Play Store !"),
                                action: SnackBarAction(
                                  label: "Close",
                                  onPressed: () {},
                                ),
                              ),
                            );
                          }
                        },
                      )),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    child: Divider(thickness: 2.0),
                  ),
                ],
              ),
            ),
          ),
        ],
        body: Container(
          child: !hasPermissions
              ? Loading()
              : permissionsList.length != 0
                  ? ListView.builder(
                      itemCount: permissionsList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          title: Text(permissionsList[index]),
                          leading: PermissionIconData(context: context)
                              .getPermissionIcon(permissionsList[index]),
                        );
                      },
                    )
                  : Center(child: Text("This app requires no permission")),
        ),
      ),
    );
  }

  Future<void> getSearchAppPermissions(
      String packageName, String appName, String iconString) async {
    try {
      var url =
          "https://permission-api.herokuapp.com/api/permission/$packageName";
      var client = http.Client();
      var response = await client.get(url);

      var parsed = json.decode(response.body);
      permissionsList = parsed;
      hasPermissions = true;
    } catch (e) {
      debugPrint(e);
    }
    setState(() {});
  }

  Future<void> openAppInPlayStore(String url) async {
    if (await (canLaunch(url))) {
      try {
        await launch(url);
      } catch (e) {
        debugPrint(e.toString());
      }
    } else {
      debugPrint("Could Not launch app");
    }
  }
}
